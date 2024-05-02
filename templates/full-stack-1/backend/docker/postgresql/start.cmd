docker run --rm --name="custom_postgres_16" -e POSTGRES_PASSWORD=dart -v "C:/Program Files/PostgreSQL/docker/volumes/custom_postgres_16:/var/lib/postgresql/data:rw" -p 5435:5432 custom/postgres:16 postgres -c log_statement=all &


docker run --rm --name="custom_postgres_16" -e POSTGRES_PASSWORD=dart -v "C:/Program Files/PostgreSQL/docker/volumes/custom_postgres_16:/var/lib/postgresql/data:rw" -p 5435:5432 custom/postgres:16 postgres &