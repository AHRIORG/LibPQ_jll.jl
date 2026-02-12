# Prompt for work in `AHRIORG/LibPQ_jll.jl`

Use the following prompt when I switch to the `AHRIORG/LibPQ_jll.jl` repository.

---

You are working in my forked `AHRIORG/LibPQ_jll.jl` repository.

## Goal
Integrate my newly built `LibPQ` tarballs (from GitHub CI) into this JLL fork so my forked `LibPQ.jl` uses them.

## Important background
- Tarballs were built from Yggdrasil changes for `LibPQ v18.1.0` and can be found in the `products` folder in this repository.
- OAuth support is enabled where PostgreSQL supports it:
  - Linux + macOS: OAuth enabled via `--with-libcurl`.
  - Linux: GSSAPI enabled via `--with-gssapi`.
  - Windows: OAuth intentionally disabled because PostgreSQL reports: `client-side OAuth is not supported on this platform`.
- Platform scope targeted: x86_64 + aarch64 (with FreeBSD excluded in our current branch).

## What I need you to do
1. Inspect current `Artifacts.toml`, `Project.toml`, and wrapper files in this JLL repo.
2. Update `Artifacts.toml` to point to my new release tarballs and checksums.
3. Ensure all expected platform entries are present and correctly mapped.
4. Bump JLL version in `Project.toml` (e.g., `18.1.0+1` or next appropriate build revision).
5. Keep compatibility bounds sensible and minimal; do not broaden unrelated compat.
6. Validate that artifact names and platform triplets match BinaryBuilder/JLL conventions.
7. Run tests/smoke checks if available.
8. Summarize exactly what changed and what command I should run in `LibPQ.jl` to consume this JLL fork.

## Inputs you should ask me for (if missing)
- The GitHub release URL containing the new tarballs.
- The exact list of tarball filenames and SHA256 values.
- Whether to publish as a tag now or prepare a PR branch first.

## Constraints
- Make minimal, surgical edits only.
- Do not rename products/APIs unless absolutely required.
- Do not add unrelated refactors.
- Preserve style and structure already used in this repo.

## Acceptance criteria
- `Artifacts.toml` entries resolve to my uploaded tarballs.
- Version bump is present and consistent.
- JLL loads on at least one local platform test.
- I receive explicit `Pkg` commands to pin this fork from my `LibPQ.jl` environment.

## Final output format
Provide:
1. A concise change summary.
2. Files changed.
3. Exact commands to test from `LibPQ.jl`:
   - `Pkg.develop` / `Pkg.add` against my fork/tag.
   - `Pkg.resolve` and `Pkg.test` steps.
4. Any remaining manual steps (release/tag/registry).

---

## Optional add-on prompt (if I want fully reproducible local pinning)
Also update instructions for pinning by commit SHA in `Manifest.toml`, and include rollback commands to return to upstream `LibPQ_jll`.
