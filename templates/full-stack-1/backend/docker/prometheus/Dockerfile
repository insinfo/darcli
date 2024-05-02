FROM prom/prometheus:v2.47.2 as image-prometheus-base
COPY ./prometheus.yml /etc/prometheus


VOLUME ./data
EXPOSE 9090

#docker build -t image-prometheus-base C:\MyDartProjects\new_sali\backend\docker\prometheus

#docker run --rm --name=prometheus -v "C:/MyDartProjects/new_sali/backend/docker/prometheus/data:/prometheus:rw" -p 9090:9090 image-prometheus-base &