// vadd_cpu.c  —  gcc -O2 -o vadd_cpu vadd_cpu.c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1e3 + ts.tv_nsec / 1e6;
}

void vector_add(const float *a, const float *b, float *c, int n) {
    for (int i = 0; i < n; i++) {
        c[i] = a[i] + b[i];
    }
}

int main(int argc, char **argv) {
    int n     = (argc > 1) ? atoi(argv[1]) : (1 << 20);  // default ~1M
    int iters = (argc > 2) ? atoi(argv[2]) : 1;
    size_t bytes = (size_t)n * sizeof(float);

    float *a = (float *)malloc(bytes);
    float *b = (float *)malloc(bytes);
    float *c = (float *)malloc(bytes);
    for (int i = 0; i < n; i++) { a[i] = 1.0f; b[i] = 2.0f; }

    vector_add(a, b, c, n);                 // warm-up: fault in pages

    double t0 = now_ms();
    for (int k = 0; k < iters; k++) {
        vector_add(a, b, c, n);
    }
    double t1 = now_ms();

    int ok = 1;
    for (int i = 0; i < n; i++) if (c[i] != 3.0f) { ok = 0; break; }

    printf("CPU  n=%-10d iters=%-4d total=%9.3f ms  per_iter=%9.3f ms  %s\n",
           n, iters, t1 - t0, (t1 - t0) / iters, ok ? "OK" : "WRONG");

    free(a); free(b); free(c);
    return 0;
}
