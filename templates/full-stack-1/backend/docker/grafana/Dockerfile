FROM grafana/grafana:7.3.1 as ap-grafana
COPY  ./config/grafana.ini /etc/grafana
COPY  ./provisioning /etc/grafana/provisioning
COPY  ./dashboards /var/lib/grafana/dashboards
EXPOSE 3000


#docker build -t grafana C:\MyDartProjects\new_sali\backend\docker\grafana

#docker run --rm --name=grafana -v "C:/MyDartProjects/new_sali/backend/docker/grafana/data:/var/lib/grafana:rw" -v "C:/MyDartProjects/new_sali/backend/docker/grafana/provisioning:/etc/grafana/provisioning/datasources:rw" -p 3000:3000 grafana &

#docker run --rm --name=grafana -v "C:/MyDartProjects/new_sali/backend/docker/grafana/data:/var/lib/grafana:rw" -p 3000:3000 grafana &

#docker run --rm --name=grafana -p 3000:3000 grafana &