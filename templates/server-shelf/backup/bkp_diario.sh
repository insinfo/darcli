#!/bin/sh

#nice bkp_diario.sh &
#ps -eo pid,ni,comm

echo "Backup de sobreposicao diaria do banco de dados do sistema rava..."
#Backup diario do Rava
#00 11,14,17,21          * * 1-6         root            /var/www/dart/rava/backend/backup/bkp_diario.sh
#nano /etc/crontab

OUT_DIR="/var/backups"
BKP_NAME="rava_"
HORA=`date +%H`
BKP_EXT="_.sql.gz"

touch ${OUT_DIR}${BKP_NAME}${HORA}${BKP_EXT}

echo "Iniciando o backup ..."
#PGOPTIONS="-c statement_timeout=0"
pg_dump -U postgres cracha | gzip -9 > ${OUT_DIR}${BKP_NAME}${HORA}${BKP_EXT}


echo "Fim do backup."
