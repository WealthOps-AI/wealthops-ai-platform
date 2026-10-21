# Repository map workflow

For every repository exploration or implementation request, identify the active repository or repositories and check the persistent map cache before reading source files.

- For this repository, check `../agent-cache/maps/wealthops-ai-platform.md` before source exploration and read it if present.
- If the map is missing, use the installed `codebase-navigation` skill or the sibling `wealthops-ai-agent-skills/tools/code_map.py` utility to generate it under `../agent-cache/maps/wealthops-ai-platform.md`.
- For cross-repository work, identify the owning repositories and inspect only relevant maps or the backend/web Graphify query neighborhoods. Keep workspace-level generated data in the ignored parent `agent-cache/`.
- Graphify's code-only extraction did not produce useful queries for this repository's configuration-heavy files. Do not rely on its platform graph; verify deployment/configuration behavior directly in source and tests.
- Regenerate only when missing, clearly stale after structural changes, or explicitly requested. Confirm current behavior against source and tests.
- If the skill or generator is unavailable, report that; do not claim a map was checked or generated.
