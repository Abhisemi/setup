// vadd_gpu.cu  —  nvcc -O2 -o vadd_gpu vadd_gpu.cu
#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

// [S1] Wrap every CUDA call. CUDA errors are silent unless you check.
#define CUDA_CHECK(call)                                                  \
    do {                                                                  \
        cudaError_t err__ = (call);                                       \
        if (err__ != cudaSuccess) {                                       \
            fprintf(stderr, "CUDA error: %s (%s:%d)\n",                   \
                    cudaGetErrorString(err__), __FILE__, __LINE__);       \
            exit(EXIT_FAILURE);                                           \
        }                                                                 \
    } while (0)

// [S1] The kernel. Runs once per thread. No loop.
__global__ void vector_add(const float *a, const float *b, float *c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

int main(int argc, char **argv) {
    int n     = (argc > 1) ? atoi(argv[1]) : (1 << 20);
    int iters = (argc > 2) ? atoi(argv[2]) : 1;
    size_t bytes = (size_t)n * sizeof(float);

    // [S2] Host (CPU) arrays.
    float *h_a = (float *)malloc(bytes);
    float *h_b = (float *)malloc(bytes);
    float *h_c = (float *)malloc(bytes);
    for (int i = 0; i < n; i++) { h_a[i] = 1.0f; h_b[i] = 2.0f; }

    // [S2] Device (GPU) arrays. Separate memory. Separate pointers.
    float *d_a, *d_b, *d_c;
    CUDA_CHECK(cudaMalloc(&d_a, bytes));
    CUDA_CHECK(cudaMalloc(&d_b, bytes));
    CUDA_CHECK(cudaMalloc(&d_c, bytes));

    int threads = 256;
    int blocks  = (n + threads - 1) / threads;   // ceil(n / threads)

    // [S3] Warm-up: first CUDA use initializes the context (~100s of ms).
    //      Never let that land in your timing.
    vector_add<<<blocks, threads>>>(d_a, d_b, d_c, n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    // [S3] CUDA events: timestamps on the GPU's timeline.
    cudaEvent_t e0, e1, e2, e3;
    CUDA_CHECK(cudaEventCreate(&e0));
    CUDA_CHECK(cudaEventCreate(&e1));
    CUDA_CHECK(cudaEventCreate(&e2));
    CUDA_CHECK(cudaEventCreate(&e3));

    CUDA_CHECK(cudaEventRecord(e0));
    // [S2] Host -> device.
    CUDA_CHECK(cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaEventRecord(e1));

    // [S2] Launch. [S4] Repeat `iters` times with data resident on the GPU.
    for (int k = 0; k < iters; k++) {
        vector_add<<<blocks, threads>>>(d_a, d_b, d_c, n);
    }
    CUDA_CHECK(cudaGetLastError());           // catches launch-config errors
    CUDA_CHECK(cudaEventRecord(e2));

    // [S2] Device -> host.
    CUDA_CHECK(cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaEventRecord(e3));
    CUDA_CHECK(cudaEventSynchronize(e3));     // wait for everything above

    // [S3] Read the timestamps.
    float ms_h2d, ms_kernel, ms_d2h, ms_total;
    CUDA_CHECK(cudaEventElapsedTime(&ms_h2d,    e0, e1));
    CUDA_CHECK(cudaEventElapsedTime(&ms_kernel, e1, e2));
    CUDA_CHECK(cudaEventElapsedTime(&ms_d2h,    e2, e3));
    CUDA_CHECK(cudaEventElapsedTime(&ms_total,  e0, e3));

    // [S2] Verify on the host.
    int ok = 1;
    for (int i = 0; i < n; i++) if (h_c[i] != 3.0f) { ok = 0; break; }

    printf("GPU  n=%-10d iters=%-4d h2d=%8.3f ms  kernel=%8.3f ms (%8.4f/iter)"
           "  d2h=%8.3f ms  total=%8.3f ms  %s\n",
           n, iters, ms_h2d, ms_kernel, ms_kernel / iters, ms_d2h, ms_total,
           ok ? "OK" : "WRONG");

    CUDA_CHECK(cudaEventDestroy(e0)); CUDA_CHECK(cudaEventDestroy(e1));
    CUDA_CHECK(cudaEventDestroy(e2)); CUDA_CHECK(cudaEventDestroy(e3));
    CUDA_CHECK(cudaFree(d_a)); CUDA_CHECK(cudaFree(d_b)); CUDA_CHECK(cudaFree(d_c));
    free(h_a); free(h_b); free(h_c);
    return 0;
}
