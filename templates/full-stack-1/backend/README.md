
# Informações para desenvolvedores

### iniciar backend modo produção
```
cd /backend
dart .\bin\prod.dart -p 3350 -a 192.168.66.123 -j 12
```

### iniciar backend modo developer
```
cd /backend
dart .\bin\dev.dart 
```

### iniciar frontend modo developer
```
cd /frontdend
webdev serve web:8005 --auto refresh --hostname 192.168.66.123
```
### iniciar frontend modo release
```
cd /frontdend
webdev serve web:8005 --release --hostname 192.168.66.123
```
### DICA: para ver log postgreSQL local
```console
PS C:\> Set-content -path "C:\Program Files\PostgreSQL\8.2\data\log\postgresql.log.1673892575"  -value ""
PS C:\> tail -f "C:\Program Files\PostgreSQL\8.2\data\log\postgresql.log.1673892575"
```
### DICA: para cria link sinbolicos no linux
```console
ln -s /var/www/dart/new_sali/backend/app_supervisor_backend.conf /etc/supervisor/conf.d/app_supervisor_backend.conf
ln -s /var/www/dart/new_sali/backend/app_nginx.conf /etc/nginx/sites-enabled/app_nginx.conf
```
## instalação no linux

###  para adiciona as locale 
```console
pt_BR.UTF-8 UTF-8
pt_BR ISO-8859-1


https://serverfault.com/questions/54591/how-to-install-change-locale-on-debian
Edit /etc/default/locale and set the contents to:

LANG="nl_NL.UTF-8"
You can check which locales you currently have generated using:

locale -a
You can generate more by editing /etc/locale.gen and uncommenting the lines for the locales that you want to enable. Then you can generate them by running the command:

locale-gen
You can find a list of supported locales in /usr/share/i18n/SUPPORTED

There is more information available on the Debian wiki.
```

#### 1 - apt-get install apt-transport-https
#### 2 - wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub |  gpg --dearmor -o /usr/share/keyrings/dart.gpg
#### 3 - echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' |  tee /etc/apt/sources.list.d/dart_stable.list
#### 4 - apt update
#### 5 - apt-get install dart=2.18.*

#### 6 - apt install nginx

#### 7 - apt install supervisor

#### 8 - dart pub global activate webdev

#### 9 - echo  export PATH="$PATH":"$HOME/.pub-cache/bin" >> .bashrc

#### 10 - apt install git

#### 11 - mkdir /var/www/dart

#### 12 - entrar no https://git....
```console
logar com o usuario `x` clicar em `Preferencias` ir para Chaves SSH
e cadastrar uma chave SSH a chave deste servidor linux 
usando 
ssh-keygen -t rsa -b 2048 -C "comment"
depois enter em tudo
depois de um 
cat /root/.ssh/id_rsa.pub
copie a chave cole no https://git....
```
#### 13 - cd /var/www/dart

#### 14 - git clone git...

#### 15 - cd new_sali/backend

#### 16 - touch .env

#### 17 - cp /var/www/dart/new_sali/backend/.env.linux.example  /var/www/dart/new_sali/backend/.env

#### 18 - cd /var/www/dart/new_sali/backend

#### 19 - dart pub get

#### 20 - cd /var/www/dart/new_sali/frontend

#### 21 - dart pub get

#### 22 - webdev build

#### 23 - ln -s /var/www/dart/new_sali/backend/app_supervisor_backend.conf /etc/supervisor/conf.d/app_supervisor_backend.conf
ou ln -s /var/www/dart/new_sali/backend/app_supervisor_dev_backend.conf /etc/supervisor/conf.d/app_supervisor_dev_backend.conf

#### 24 - ln -s /var/www/dart/new_sali/backend/app_producao_nginx.conf /etc/nginx/sites-enabled/app_producao_nginx.conf
ou ln -s /var/www/dart/new_sali/backend/app_dev_nginx.conf /etc/nginx/sites-enabled/app_dev_nginx.conf

#### 25 - teste o servidor web nginx com
```console
 nginx -t -c /etc/nginx/nginx.conf 
```
#### 26 
```console
 /etc/init.d/nginx restart
 ```

#### 27 - add configuração para monitorar o serviço
```console
coloque isso no arquivo /etc/supervisor/supervisord.conf
[inet_http_server]
port=9001
username = coloque o nome de usario aqui
password = coloque a senha de usario aqui 
```

#### 28 - /etc/init.d/supervisor restart

#### 29 - (somente para teste) copia o dart do servidor 0.72
```console
scp -r root@10.0.0.72:/root/dart-sdk-2.18.3 /root
```

#### 30 - add no 10.0.0.25  /etc/postgresql/8.2/main/pg_hba.conf
```console
 host    all         all         10.0.0.66/32          md5 #servidor app
```

#### 31 - mkdir /backup/sali_664/

#### 32 - para copiar a base do Sali
```console
scp root@10.0.0.25:/backup/sali_664/sali_all.gz /backup/sali_664/sali_all.gz
```
#### 33 - add to /etc/apt/sources.list  
```console
deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg  main

 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7FCC7D46ACCC4CF8
```
#### 34 - apt-get install postgresql-15 postgresql-client-15

#### 35 use nano para editar o arquivo /etc/locale.gen e adicione
```console
pt_BR.UTF-8 UTF-8
pt_BR.CP1252 CP1252
pt_BR ISO-8859-1
```
depois execute
```console
run locale-gen
```
#### 36 - su postgres 
psql 
CREATE USER dart WITH SUPERUSER PASSWORD 'dart';

nano /etc/postgresql/15/main/postgresql.conf    
adicione  
listen_addresses = '*'

su root 
gunzip -f sali_all.gz
dropdb -U postgres siamweb
ou psql -U postgres -c drop database siamweb;
psql -U postgres -c CREATE DATABASE siamweb TEMPLATE = template0 ENCODING = 'SQL_ASCII' LC_COLLATE = 'pt_BR.cp1252' LC_CTYPE = 'pt_BR.cp1252';
a ser testado da forma abaixo
psql -U postgres -c CREATE DATABASE siamweb TEMPLATE = template0 ENCODING = 'SQL_ASCII' LC_COLLATE = 'pt_BR' LC_CTYPE = 'pt_BR';

psql -U postgres -d siamweb < sali_all 

#### 37 corrigir função fn_atualiza_ultimo_andamento em siamweb public
trocar  To_Date(tTimestamp,'YYYY-MM-DD')    >= To_Date(rUltimoAndamento.timestamp,'YYYY-MM-DD') 

para  To_Date(tTimestamp::text,'YYYY-MM-DD')    >= To_Date(rUltimoAndamento.timestamp::text,'YYYY-MM-DD') 

#### 38 - instalar o libreoffice-core-nogui para uso de converção de docx para pdf

apt-get install default-jre libreoffice-java-common
apt-get install libreoffice-writer --no-install-recommends
https://askubuntu.com/questions/519082/how-to-install-libre-office-without-gui
https://stackoverflow.com/questions/20787712/start-openoffice-process-with-python-to-use-with-pyuno-using-subprocess
soffice --accept="socket,host=localhost,port=8100;urp;StarOffice.Service" --headless --nofirststartwizard

para poder usar este comando abaixo
soffice.exe --headless --convert-to pdf --outdir C:\MyDartProjects\new_sali\backend C:\MyDartProjects\new_sali\backend\docx_example.docx
apt install libreoffice-core-nogui

