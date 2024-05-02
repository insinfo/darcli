cd /var/www/dart/new_sali/
git pull
echo /var/log/new_sali_backend.log
echo /var/log/new_sali_public_backend.log
cd frontend
dart pub get
webdev build

cd ../
cd frontend_site
dart pub get
webdev build

# backend
/etc/init.d/nginx restart
cd ../
cd backend
dart pub get
dart compile exe ./bin/prod.dart  --output /var/www/dart/new_sali/backend/bin/app_new
dart compile exe ./bin/public_backend.dart  --output /var/www/dart/new_sali/backend/bin/app_public_new
/etc/init.d/supervisor stop
mv /var/www/dart/new_sali/backend/bin/app_new /var/www/dart/new_sali/backend/bin/app
mv /var/www/dart/new_sali/backend/bin/app_public_new /var/www/dart/new_sali/backend/bin/app_public
/etc/init.d/supervisor start


