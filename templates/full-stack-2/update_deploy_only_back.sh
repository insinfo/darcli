cd /var/www/dart/esic
git pull
cd backend/
echo 'Atualizando backend'

supervisorctl stop esic
/root/dart-sdk-2.18.3/bin/dart compile exe ./bin/prod.dart -o ./bin/esic
supervisorctl start esic

