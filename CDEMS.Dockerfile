FROM apache/superset:5.0.0rc3

USER root

# Install packages using uv into the virtual environment
# Superset started using uv after the 4.1 branch; if you are building from apache/superset:4.1.x,
# replace the first two lines with RUN pip install \
RUN . /app/.venv/bin/activate && \
    uv pip install \
    # install psycopg2 for using PostgreSQL metadata store - could be a MySQL package if using that backend:
    psycopg2-binary

# Switch back to the superset user
USER superset

CMD ["/app/docker/entrypoints/run-server.sh"]

