#!/bin/bash
mysql -uroot -e "CREATE USER 'pandrugsdb'@'%' IDENTIFIED BY 'pandrugsdb'"
mysql -uroot -e "CREATE DATABASE pandrugsdb"
mysql -uroot -e "GRANT ALL PRIVILEGES ON pandrugsdb.* TO 'pandrugsdb'@'%' WITH GRANT OPTION"

echo "=> Importing Pandrugs database"
wget $PANDRUGSDB_SCHEMA_SQL_URL -O - | gunzip | mysql -uroot pandrugsdb
wget $PANDRUGSDB_DATA_SQL_URL -O - | gunzip | mysql -uroot pandrugsdb
echo "INSERT INTO user (login, email, password, role) VALUES ('guest', 'guest@email.com', MD5('guest'), 'GUEST')" | mysql -u root pandrugsdb
echo "=> Done importing Pandrugs database"

