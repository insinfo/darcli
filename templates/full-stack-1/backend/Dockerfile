FROM dart:2.18.7 as app-build
WORKDIR /
ADD core/ /core/
WORKDIR /app
ADD backend/pubspec.* /app/
RUN dart pub get --no-precompile
ADD backend/ /app/
RUN dart pub get --offline
ADD backend/.env.docker.local.example /app/.env
RUN dart compile exe bin/prod.dart -o bin/app

FROM debian:bookworm-slim as appserver-aot

COPY --from=app-build /app/.env /.env 
COPY --from=app-build /app/bin/app /app/app

EXPOSE 3350
CMD ["/app/app","-p","3350","-a", "0.0.0.0","-j","1"]

# cria a imagem 
# docker build -f backend/Dockerfile -t appserver-aot .
# executa a imagem
# docker run --rm --name="appserver-aot" -v "../backend/.cache:/app/.cache:rw" -v "../backend/.certificates:/app/.certificates:rw" -v "../backend/storage/storage/app:/app/storage/app:rw" -p 3350:3350 saliserver-aot 



