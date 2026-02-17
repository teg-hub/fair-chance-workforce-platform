<!-- Copilot instructions for AI coding agents working on this repository -->
# Copilot Instructions — fair-chance-workforce-platform

Purpose: Give AI coding agents the concrete, repository-specific context they need to be immediately productive.

1) Repo snapshot
- Minimal project scaffold; root currently contains: `README.md`.
- Current branch used for development: `setup/foundation` (compare to `main`).

2) Big-picture guidance
- This repository currently has a lightweight foundation. Expect typical expansions to include services (API, worker), a frontend, and infra/config under `./deploy` or `./infra`.
- When adding or modifying components, keep them discoverable under top-level folders named `api`, `web`, `worker`, or `infra`.

3) Files and locations to check first
- `README.md`: project entry point (currently minimal).
- `.github/` (CI/workflows): create or update GitHub Actions here for tests/builds.

4) Developer workflows (what an agent should try)
- Ask before running or modifying CI workflows. If none exist, propose a single GitHub Actions workflow that runs lint and tests.
- Local dev commands: none are defined yet. When adding language-specific code, add `Makefile` or top-level npm/pip/poetry manifest and document `make dev` and `make test` in `README.md`.

5) Conventions and patterns to follow
- Keep public APIs and configuration files in clear, top-level folders. Prefer explicit file names (`api/server.py`, `web/src/`) rather than implicit nesting.
- Use a single source of truth for dependency management: `package.json`, `pyproject.toml`, or `go.mod` depending on stack introduced.
- Branching: keep feature branches off `setup/foundation` while this branch is active; target `main` for release-ready merges.

6) Integration points & external dependencies
- No external services are defined yet. When adding integrations (DB, Auth, queues), add a `docs/integrations.md` describing required env vars, ports, and test doubles/mocks.

7) How to propose changes
- Create focused PRs that add one logical thing (example: "Add Python API skeleton and Makefile").
- Include a short README in any new top-level folder explaining how to run and test that component.

8) Example patterns (what to generate)
- If adding a Python API, include: `pyproject.toml`, `app/__init__.py`, `app/main.py`, `tests/`, and a `Makefile` with `dev`, `lint`, `test` targets.
- If adding a web app, include: `web/package.json`, `web/src/`, `web/README.md`, and an npm `start`/`build` script.

9) Safety and review notes for agents
- Don't run or modify workflows that execute external commands (deploy, publish) without explicit human approval.
- Add clear commit messages and PR descriptions; avoid broad sweeping changes in a single PR.

10) If you (agent) need more info
- Look for added files that indicate a language or framework (package.json, pyproject.toml, go.mod, Dockerfile).
- If the repo remains minimal, ask the maintainers whether they want a skeleton for a specific stack (Python/Node/Go).

If any of these sections are unclear or you'd like the file expanded with examples for a particular stack, tell me which stack and I'll update the instructions.
