# Codex takeoff brief: cluster-audit laptop setup

Paste everything below the line into Codex (or Claude Code) as the first message,
after filling in the two placeholders. Run the agent from your home directory.

Placeholders:
- `<REPO_URL>`: the CLI repo you were invited to on GitHub
- `<KUBECONFIG_FILE>`: path to the kubeconfig file you were sent (drag it into the terminal to get the path)

---

You are setting up my Mac so I can run a Kubernetes cluster audit CLI from my laptop.
Work step by step, run the commands yourself, show me output as you go, and stop
and ask me if anything needs a password or a decision. Do not run any cluster tests
until I say so.

## Ground rules

- Never print, echo, cat, or paste the contents of any kubeconfig, token, or password.
  Refer to them by path only.
- Do not commit anything to git. Do not push. Do not open PRs.
- Do not modify anything on the cluster. Read-only commands only (`get`, `describe`, `version`).
- If a tool needs admin rights and I'm not an admin, install it user-locally under `~/.local/bin` instead.
- Prefer `uv` for anything Python. Do not use system pip.

## Step 1. Tools

Check for `git`, `kubectl`, `uv`, `node`. Install whatever is missing:
- If `brew` exists or I'm an admin: `brew install kubectl uv node`.
- Otherwise: kubectl from `https://dl.k8s.io/release/stable.txt` into `~/.local/bin`,
  uv via `curl -LsSf https://astral.sh/uv/install.sh | sh` with `UV_INSTALL_DIR=$HOME/.local/bin`.
- Make sure `~/.local/bin` is on PATH in `~/.zprofile`.
Print versions when done.

## Step 2. Kubeconfig

- `mkdir -p ~/.kube && chmod 700 ~/.kube`
- Move `<KUBECONFIG_FILE>` to `~/.kube/cluster.yaml` and `chmod 600` it.
- Add `export KUBECONFIG=$HOME/.kube/cluster.yaml` to `~/.zprofile` and export it now.
- Run `kubectl get nodes -o wide` and `kubectl get pods -A | head -30`.
- Tell me: how many nodes, are they Ready, what GPU labels or resources you can see
  (`kubectl describe nodes | grep -i -E "nvidia|gpu|rdma|hostdev"`).

## Step 3. CLI repo

- `cd ~ && git clone <REPO_URL>` then `cd` into it.
- Read the README and any CONTRIBUTING or docs/ files. Tell me in five lines what the
  CLI does and how it's meant to be installed.
- Install it with `uv` per the README. Confirm the CLI's `--help` runs.
- Check which branch I should be on for current testing (look for `release/*` branches
  and recent tags). Tell me, don't switch yet.

## Step 4. Map the repo

Give me a one-screen mind map: top-level folders, what each is for, and where these live:
- the audit phase
- the performance tests
- the reliability tests
- where results get written locally
- how results get uploaded
- any cluster-specific notes or overrides (look for folders named after providers)
Cite file paths.

## Step 5. Pre-flight

Run the CLI's GPU/cluster status command if it has one (something like `<cli> k8s gpus`),
show me the output, and then STOP. Tell me exactly what command would start the audit
phase and what it will do to the cluster. I'll say go.
