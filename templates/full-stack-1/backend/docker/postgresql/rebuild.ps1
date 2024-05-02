docker rm --force custom_postgres_16beta3
docker rmi --force  custom/postgres:16beta3

docker build -t custom/postgres:16beta3 C:\MyDartProjects\new_sali\backend\docker\postgresql
docker run --rm --name="custom_postgres_16beta3" -e POSTGRES_PASSWORD=dart -v "C:/Program Files/PostgreSQL/docker/volumes/custom_postgres_16beta3:/var/lib/postgresql/data:rw" -p 5435:5432 custom/postgres:16beta3 postgres -c log_statement=all &


docker run --rm --name="custom_postgres_16beta3" -e POSTGRES_PASSWORD=dart -v "C:/Program Files/PostgreSQL/docker/volumes/custom_postgres_16beta3:/var/lib/postgresql/data:rw" -p 5432:5432 custom/postgres:16beta3 postgres -c log_statement=all -c password_encryption=md5 &
