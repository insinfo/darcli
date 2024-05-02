cd /var/www/dart/app/
git pull

#ln -s /var/www/dart/app/backend/app_supervisor_dev_backend.conf /etc/supervisor/conf.d/app_supervisor_dev_backend.conf
#ln -s /var/www/dart/app/backend/app_dev_nginx.conf /etc/nginx/sites-enabled/app_dev_nginx.conf

echo /var/log/app_backend.log
echo -n > /var/log/app_backend.log

cd frontend
/root/dart-sdk-3.2.1/bin/dart pub get
#/root/dart-sdk-3.2.1/bin/dart pub upgrade
/root/dart-sdk-3.2.1/bin/dart /root/webdev-3.2.0/bin/webdev.dart-3.2.1.snapshot build
cd ../frontend_site
/root/dart-sdk-3.2.1/bin/dart pub get
#/root/dart-sdk-3.2.1/bin/dart pub upgrade
/root/dart-sdk-3.2.1/bin/dart /root/webdev-3.2.0/bin/webdev.dart-3.2.1.snapshot build

# backend
/etc/init.d/nginx restart
cd ../
cd backend
/root/dart-sdk-3.2.1/bin/dart pub get
#/root/dart-sdk-3.2.1/bin/dart pub upgrade
/root/dart-sdk-3.2.1/bin/dart compile exe ./bin/prod.dart  --output /var/www/dart/app/backend/bin/app_new
/root/dart-sdk-3.2.1/bin/dart compile exe ./bin/public_backend.dart  --output /var/www/dart/app/backend/bin/app_public_new
/etc/init.d/supervisor stop
mv /var/www/dart/app/backend/bin/app_new /var/www/dart/app/backend/bin/app
mv /var/www/dart/app/backend/bin/app_public_new /var/www/dart/app/backend/bin/app_public
/etc/init.d/supervisor start


