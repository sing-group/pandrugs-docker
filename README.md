# PanDrugs Docker ![release](https://img.shields.io/badge/latest-2024.06-green)

A Dockerfile to generate an all-in-one [PanDrugs](pandrugs.org) server. 

Latest version available: `2024.06`

## Requirements

To be fully functional, in addition to building the `pandrugs2` Docker image as explained below, this PanDrugs server requires:

- An additional Docker image for running VEP. Check [this instructions](vep/README.md) to build and configure the image and see how
- An additional Docker image for running PharmCat. The official image `pgkb/pharmcat:2.1.2` is used to run [the additional scripts](pandrugs-additional-scripts/README.md).

## Versions of PanDrugs components included in this image

* Front-end: 2.2.0
* Back-end: 2.3.0
* Perl variant analysis module: [v20](https://github.com/cnio-bu/pandrugs-db)
* Database: 20240612

These versions are packed into the `2024.06` release.

## Versions of databases used by PanDrugs and included this image

The database sources can be found in the [`pandrugs-db` project](https://github.com/cnio-bu/pandrugs-db).

## Building the image

Edit the `context.xml` file in order to configure the mail system (see [SMTP Configuration Properties](http://connector.sourceforge.net/doc-files/Properties.html) for configuration details).

```
<Resource name="mail/session"
        auth="Container"
        type="javax.mail.Session"
        mail.smtp.host="sing.ei.uvigo.es"
        mail.smtp.port="25"
        mail.smtp.auth="false"
/>
```

Note that the versions of the PanDrugs components are  are taken from the following environment variables declared in the Dockerfile:
- `APP_BACKEND_VERSION`
- `APP_FRONTEND_VERSION`
- `APP_DB_SCHEMA_VERSION`
- `APP_DB_DATA_VERSION`

The available releases for these versions are:
- `latest` (points to `2024.06`)
- `2024.06`
- `2024.05`
- `2023.03`

Then, inside the cloned repository:

```
docker build -t pandrugs2 .
```

This process should be relatively fast as database files are downloaded when the server is started for the first time and VEP database files are part of the [pandrugs2-vep](vep/README.md) Docker image. The `pandrugs2` image should be about 1.41GB.

## Starting the server

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp -v [your_local_dir_for_data OR volume_name]:/pandrugs2-backend_data -p 80:8080 --name pandrugs2 pandrugs2
```

This command will:
- Make your server available via the port `80` at the container machine.
- Allow the container executing Docker.
- Share the host `/tmp` directory with the container.
- Create a Docker managed volume named `pandrugs2-backend_data` if using `-v pandrugs2-backend_data:/pandrugs2-backend_data`

The first time the container is started, it will download the database files and import them into the MySQL DB. Therefore, this process may take a while and its progress can be monitored with:

```
docker logs -f pandrugs2
```

As noted in the VEP configuration, create the following symbolic link in the host: `ln -s /var/lib/docker/volumes/pandrugs2-backend_data/_data /pandrugs2-backend_data` (replace `pandrugs2-backend_data` with the actual name of your Docker managed volume). This is because the Docker run commands (created in the `run-pandrugs-vep-*-on-docker.sh` scripts) will use references to directories inside `/pandrugs2-backend_data`. As these commands are executed in the host, such path must exist and point to the actual location of the data (which in this case is the location of the corresponding managed Docker volume).

## Accessing the server

The frontend will be serving at: http://yourhost

The backend will be serving at: http://yourhost/pandrugs-backend

## Accessing the database

```
docker exec -it pandrugs2 /usr/bin/mysql -uroot
```

## Getting the pandrugs tomcat log

```
docker exec -it pandrugs2 tail -f /pandrugsdb.log
```

## Stopping the server

```
docker stop pandrugs2
```
