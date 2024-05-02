git clone ...
cd new_esic
cd backend
/root/dart-sdk-2.18.3/bin/dart pub get
/root/dart-sdk-2.18.3/bin/dart compile exe ./bin/prod.dart -o ./bin/esic
touch /var/log/esic_backend.log
#touch .env
cp .env.example .env
ln -s /var/www/dart/esic/backend/supervisor_esic_backend.conf /etc/supervisor/conf.d/supervisor_esic_backend.conf
#ln -s ./supervisor_bluefin_backend.conf /etc/supervisor/conf.d/supervisor_bluefin_backend.conf
cd ../
cd frontend
/root/dart-sdk-2.18.3/bin/dart pub pub get
/root/dart-sdk-2.18.3/bin/dart webdev build


