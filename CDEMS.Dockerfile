#
# CDEMS Custom Superset Build
# Extends the official apache/superset image with compiled translations
# and PostgreSQL metadata store support.
#

ARG SUPERSET_VERSION=6.1.0

FROM apache/superset:${SUPERSET_VERSION} AS translations-builder

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install builder-only tools for translation compilation.
RUN apt-get update && \
    apt-get install -y --no-install-recommends nodejs npm && \
    rm -rf /var/lib/apt/lists/*

RUN . /app/.venv/bin/activate && \
    uv pip install --no-cache-dir Babel

RUN npm install -g po2json

# Compile backend .mo files and frontend .json files in a temporary build location.
COPY superset/translations /tmp/superset-translations

RUN set -eux; \
    . /app/.venv/bin/activate; \
    pybabel compile -d /tmp/superset-translations || true; \
    test -f /tmp/superset-translations/en/LC_MESSAGES/messages.mo; \
    test -f /tmp/superset-translations/pl/LC_MESSAGES/messages.mo; \
    find /tmp/superset-translations -name "*.po" -print0 | while IFS= read -r -d '' file; do \
    json_file="${file%.po}.json"; \
    po2json --domain superset --format jed1.x --fuzzy "$file" "$json_file"; \
    done; \
    find /tmp/superset-translations -name "*.po" -delete; \
    find /tmp/superset-translations -name "*.pot" -delete

FROM apache/superset:${SUPERSET_VERSION} AS runtime

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Runtime-only dependency for PostgreSQL metadata store.
RUN . /app/.venv/bin/activate && \
    uv pip install --no-cache-dir psycopg2-binary

COPY --from=translations-builder /tmp/superset-translations /app/superset/translations

USER superset

CMD ["/app/docker/entrypoints/run-server.sh"]

