# pull postgres image
docker pull postgres:16
# para criar a imagem
docker build -t custom/postgres:16 .  
# para executar
docker run --rm --name="custom_postgres_16" -e POSTGRES_PASSWORD=dart -v "C:/Program Files/PostgreSQL/docker/volumes/custom_postgres_16:/var/lib/postgresql/data:rw" -p 5435:5432 custom/postgres:16 postgres -c log_statement=all &


# para listar containers rodando
docker ps -a 
# para entrar no container
docker exec -it custom_postgres /bin/bash 