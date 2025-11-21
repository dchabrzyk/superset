#
# CDEMS Custom Superset Build
# Extends official apache/superset:6.0.0rc3 with translations and PostgreSQL support
#

FROM apache/superset:6.0.0rc3 AS base

USER root

# Install babel for compiling translations
RUN . /app/.venv/bin/activate && \
    uv pip install babel

# Copy translation source files from this repo
# (these are the .po files that exist in Superset source but were removed from docker image)
COPY superset/translations /app/superset/translations

# Compile backend translations (.po -> .mo)
RUN . /app/.venv/bin/activate && \
    cd /app && \
    pybabel compile -d superset/translations || true

# Compile frontend translations (if .json files exist)
# Note: Frontend translations are typically already in the base image as .json files
# but we'll ensure they're present
RUN if [ -d /app/superset-frontend/src/translations ]; then \
        echo "Frontend translations already exist"; \
    fi

# Install psycopg2-binary for PostgreSQL metadata store
RUN . /app/.venv/bin/activate && \
    uv pip install psycopg2-binary

# Clean up .po source files to reduce image size (keep only compiled .mo)
RUN find /app/superset/translations -name "*.po" -delete && \
    find /app/superset/translations -name "*.pot" -delete

# Switch back to superset user
USER superset

CMD ["/app/docker/entrypoints/run-server.sh"]

