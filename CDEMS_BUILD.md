# MeMOM Superset image

## Published on 2026-11-10

- Image: `masta.azurecr.io/superset:7.0.0rc2-masta-1`
- Published digest: `sha256:65e0478809189cad873adb30c66dec6e3181b317f214aced4aaca8f3eeea6979`
- Platform: `linux/amd64`
- Apache source: tag `7.0.0rc2`, commit `e4aee71493bdac25bbfb7be11084c11b1e7d31a5`
- Official base: `apache/superset:7.0.0rc2@sha256:4256ab7d7e8e72e351896297fe25610d137ab56163b6ca360379b8c30c57fa64`
- Fork build recipe: `CDEMS.Dockerfile` and `build_cdems_dockerfile.sh` from commit `261a8759d6d814605b93fc6a27f832f6fad4c0a1`

The build used a separate Apache 7 source directory and the fork's build files.
Only their default version/tag were adjusted. It did not build application code
from the local `6.1.0-masta` branch or update that branch to Superset 7.

Our image adds compiled backend/frontend translations from the matching Apache
source and `psycopg2-binary` for PostgreSQL. The application itself comes from
the official image; no application patch or full frontend rebuild was applied.

## Rebuild from this repository

Do not build version 7 using the translations from a version 6 checkout. From
this repository, prepare the matching source independently of the current branch:

```bash
build_dir=$(mktemp -d)
git fetch https://github.com/apache/superset.git e4aee71493bdac25bbfb7be11084c11b1e7d31a5
git archive e4aee71493bdac25bbfb7be11084c11b1e7d31a5 | tar -x -C "$build_dir"
git show 261a8759d6d814605b93fc6a27f832f6fad4c0a1:CDEMS.Dockerfile > "$build_dir/CDEMS.Dockerfile"
git show 261a8759d6d814605b93fc6a27f832f6fad4c0a1:build_cdems_dockerfile.sh > "$build_dir/build_cdems_dockerfile.sh"
SUPERSET_VERSION=7.0.0rc2@sha256:4256ab7d7e8e72e351896297fe25610d137ab56163b6ca360379b8c30c57fa64 \
  IMAGE_TAG=7.0.0rc2-masta-2 bash "$build_dir/build_cdems_dockerfile.sh"
```

The last command builds and pushes to ACR using the existing registry login.
Use a new tag for each rebuild; do not overwrite the published `masta-1` tag.
The recipe fetches builder packages and Python dependencies without full version
locks, so a rebuild is not guaranteed to reproduce the original digest. Use the
published digest above when the exact deployed artifact is required.

## Operator deployment

Apache operator **0.3.1** manages the Superset deployments and migration/init Jobs.
It does not build images or replace our translations/database driver. The image
build remains needed; the old Apache Superset Helm chart installation procedure
is no longer the managed-cluster deployment procedure.

Deployment values and operations are owned by the CDEMS-server repository:

- `.devops/shared/operations/superset/README.md`: operator and migration runbook.
- `.devops/cluster/manifests/superset/operator-values.yaml`: managed-cluster configuration.
- `.devops/shared/helm/superset`: shared Superset CR, Redis and initialization.

MeMOM must omit `dataset` in global guest-token RLS rules. Superset 7 rejects the
legacy `dataset: 0` payload with HTTP 400. This is a backend API-client issue,
not a missing custom image or an operator setting. Acceptance must include the
embedded dashboard through MeMOM, not only a manually constructed Superset call.
