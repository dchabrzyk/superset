#
# CDEMS Custom Superset Build
# Extends official apache/superset:6.0.0rc3 with translations and PostgreSQL support
#

FROM apache/superset:6.1.0 AS base

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

# Install Node.js and npm for frontend translation compilation
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install po2json for frontend translation compilation
RUN npm install -g po2json

# Compile frontend translations (.po -> .json)
# This generates messages.json files that the React frontend uses
RUN for file in $(find /app/superset/translations -name "*.po"); do \
    extension="${file##*.}"; \
    filename="${file%.*}"; \
    if [ "$extension" = "po" ]; then \
    echo "Converting $file to $filename.json"; \
    po2json --domain superset --format jed1.x --fuzzy "$file" "$filename.json" || true; \
    fi; \
    done

# Verify translations were compiled successfully
RUN echo "=== Checking compiled translations ===" && \
    find /app/superset/translations/pl/LC_MESSAGES/ -type f -exec ls -lh {} \; && \
    echo "=== Translation check complete ==="

# Install psycopg2-binary for PostgreSQL metadata store
RUN . /app/.venv/bin/activate && \
    uv pip install psycopg2-binary

# Clean up .po source files to reduce image size (keep compiled .mo and .json)
# Temporarily disabled to debug
# RUN find /app/superset/translations -name "*.po" -delete && \
#     find /app/superset/translations -name "*.pot" -delete

# Switch back to superset user
USER superset

CMD ["/app/docker/entrypoints/run-server.sh"]

