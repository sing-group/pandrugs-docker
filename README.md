# pandrugsdb-docker
A Dockerfile to generate an all-in-one pandrugs server.

## Versions of PanDrugs components included in this image

* Front-end: 1.0.2
* Back-end: 1.0.6
* Perl variant analysis module: v18
* Database: 20180222

## Building the image

Edit the context.xml file in order to configure the mail system.

Inside the cloned repository:

```
docker build -t pandrugs .
```

This will take some time because the image will retrieve big files from internet (databases).

## Starting the server

```
docker run -d -v [your_local_dir_for_data]:/pandrugsdb-backend_data -p 80:8080 pandrugs
```
This will make your server available via the port 80 at the container machine.

## Accessing the server
The frontend will be serving at: http://yourhost/pandrugs

The backend will be serving at: http://yourhost/pandrugsdb-backend

## Accessing the database
Take the running instance ID

```
docker ps
CONTAINER ID    IMAGE   COMMAND    CREATED      STATUS                          PORTS                   NAMES
da903ab4c25d    pandrugs:latest     "/run.sh"   31 minutes ago  Up 31 minutes   0.0.0.0:8080->8080/tcp  jovial_hawking

docker exec -it da903ab4c25d /usr/bin/mysql -uroot
```

## Getting the pandrugs tomcat log
Take the running instance ID

```
docker ps
CONTAINER ID    IMAGE   COMMAND    CREATED      STATUS                          PORTS                   NAMES
da903ab4c25d    pandrugs:latest     "/run.sh"   31 minutes ago  Up 31 minutes   0.0.0.0:8080->8080/tcp  jovial_hawking

docker exec -it da903ab4c25d tail -f /pandrugsdb.log
```

## Stopping the server
Take the running instance ID

```
docker ps
CONTAINER ID    IMAGE   COMMAND    CREATED      STATUS                          PORTS                   NAMES
da903ab4c25d    pandrugs:latest     "/run.sh"   31 minutes ago  Up 31 minutes   0.0.0.0:8080->8080/tcp  jovial_hawking

docker stop da903ab4c25d
```


