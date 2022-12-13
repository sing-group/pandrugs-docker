#!/bin/bash

if [[ ! -d $DATA_DIR/database ]]; then
    echo "=> No database dir found on $DATA_DIR, creating..."
    mkdir $DATA_DIR/database
fi
if [[ ! -d $DATA_DIR/database/mysql ]]; then
    echo "=> An empty or uninitialized MySQL data directory is detected in $DATA_DIR/database"
    echo "=> Installing MySQL ..."
    mysqld --initialize-insecure > /dev/null 2>&1
    echo "=> Done!"  
    #/create_mysql_admin_user.sh
    
    echo "=> Starting MySQL for initial setup..."
    mkdir -p /var/run/mysqld
    chown mysql:mysql /var/run/mysqld

    /usr/bin/mysqld_safe > /dev/null 2>&1 &
    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done

    echo "=> Running /mysql-setup.sh"
    /mysql-setup.sh
    
    mysqladmin -uroot shutdown
    
    echo "=> Done!"
else
    echo "=> Using an existing data directory of MySQL"
fi

exec supervisord -n
