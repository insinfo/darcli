cd /var/www/dart/esic/
git pull
touch /var/log/esic_backend.log
cd frontend
pub get
webdev11 build

# backend
ln -s /var/www/dart/esic/backend/supervisor_esic.conf /etc/supervisor/conf.d/supervisor_esic.conf
ln -s /var/www/dart/esic/backend/nginx_esic.conf /etc/nginx/modules/sites-enable/nginx_esic.conf
/etc/init.d/nginx restart
cd ../
cd backend
pub get
/etc/init.d/supervisor restart
 
#mkdir /var/www/html/storage/notifis
