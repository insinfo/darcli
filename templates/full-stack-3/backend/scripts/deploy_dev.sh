cd /var/www/dart/bancoemprego
git pull

ln -s /var/www/dart/bancoemprego/backend/supervisor_sibem_dev_backend.conf /etc/supervisor/conf.d/supervisor_sibem_dev_backend.conf
ln -s /var/www/dart/bancoemprego/backend/nginx_sibem_dev_backend.conf /etc/nginx/sites-enabled/nginx_sibem_dev_backend.conf

echo /var/log/banco_emprego_backend.log
echo -n > /var/log/banco_emprego_backend.log

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
#SET SEARCH_PATH = public; CREATE EXTENSION IF NOT EXISTS "unaccent" schema pg_catalog;
psql -U postgres -c "SET SEARCH_PATH = public; CREATE EXTENSION IF NOT EXISTS "unaccent" schema pg_catalog;"  sistemas

/root/dart-sdk-3.2.1/bin/dart pub get
#/root/dart-sdk-3.2.1/bin/dart pub upgrade
echo compilando
/root/dart-sdk-3.2.1/bin/dart compile exe ./bin/prod.dart  --output /var/www/dart/bancoemprego/backend/bin/sibem_new

/etc/init.d/supervisor stop
echo subistituindo
mv /var/www/dart/bancoemprego/backend/bin/sibem_new /var/www/dart/bancoemprego/backend/bin/sibem

/etc/init.d/supervisor start


