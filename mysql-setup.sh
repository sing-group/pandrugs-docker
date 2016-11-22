#!/bin/bash
mysql -uroot -e "CREATE USER 'pandrugsdb'@'%' IDENTIFIED BY 'pandrugsdb'"
mysql -uroot -e "CREATE DATABASE pandrugsdb"
mysql -uroot -e "GRANT ALL PRIVILEGES ON pandrugsdb.* TO 'pandrugsdb'@'%' WITH GRANT OPTION"

echo "=> Importing Pandrugs database"
apt-get install -y wget
wget $PANDRUGSDB_SQL_URL -O - | gunzip | mysql -uroot pandrugsdb
echo "=> Done importing Pandrugs database"

