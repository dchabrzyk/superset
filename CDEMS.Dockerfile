FROM apache/superset:4.1.1

USER root

# Copy the custom translations into the Docker image
COPY superset/translations/pl /app/superset/translations/pl

RUN rm /app/superset/translations/pl/LC_MESSAGES/*.po

RUN pip install psycopg2-binary==2.9.6

USER superset
