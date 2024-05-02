cd /var/www/dart/esic
git pull
cd backend/
echo 'Atualizando backend'
/root/dart-sdk-2.18.3/bin/dart pub get
supervisorctl stop esic
/root/dart-sdk-2.18.3/bin/dart compile exe ./bin/prod.dart -o ./bin/esic
supervisorctl start esic

cd ../frontend
echo 'Atualizando frontend administrativo'
/root/dart-sdk-2.18.3/bin/dart pub get
/root/dart-sdk-2.18.3/bin/dart /root/webdev/bin/webdev.dart-2.18.3.snapshot build

cd ../frontend-site
echo 'Atualizando frontend-site para o municipe'
/root/dart-sdk-2.18.3/bin/dart pub get
/root/dart-sdk-2.18.3/bin/dart /root/webdev/bin/webdev.dart-2.18.3.snapshot build