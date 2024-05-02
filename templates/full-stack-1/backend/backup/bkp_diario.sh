#!/bin/sh



OUT_DIR="/backup/"
BKP_NAME="app_"
HORA=`date +%H`
BKP_EXT="_all.sql.gz"

touch ${OUT_DIR}${BKP_NAME}${HORA}${BKP_EXT}

echo "start backup ..."
#PGOPTIONS="-c statement_timeout=0"
pg_dumpall -U postgres | gzip -9 > ${OUT_DIR}${BKP_NAME}${HORA}${BKP_EXT}

