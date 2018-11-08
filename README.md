# pandrugsdb-docker

Version: 2018.10.18

A Dockerfile to generate an all-in-one pandrugs server.

## Versions of PanDrugs components included in this image

* Front-end: 1.2.1
* Back-end: 1.1.0
* Perl variant analysis module: v19
* Database: 20180328

## Versions of databases used by PanDrugs and included this image

* DGIdb: v3.0.2
* moAb (from [Carter PJ & Lazar GA. Next generation antibody drugs: pursuit of the 'high-hanging fruit'. Nat Rev Drug Discov. 2017 Dec 1](https://doi.org/10.1038/nrd.2017.227))
* TARGET database: v3
* CTRP: v1
* GDSC Results of data analysis (from [A landscape of pharmacogenomic interactions in cancer, Iorio F et al. Cell. 2016](https://doi.org/10.1016/j.cell.2016.06.017))
* Variant Effect Predictor Ensembl: Release 90
* COSMIC: Release v84 for HG19 assembly
* Pfam: 31.0
* UniProt: Release 2018_02
* InterPro: 66.0
* ClinVar: Release 2018_02
* Cancer Gene Census for Cosmic: v84
* APPRIS: (gencode19/ensembl74)
* KEGG: Release 85.1

## Building the image

Edit the context.xml file in order to configure the mail system (see [SMTP Configuration Properties](http://connector.sourceforge.net/doc-files/Properties.html) for configuration details).

```
<Resource name="mail/session"
        auth="Container"
        type="javax.mail.Session"
        mail.smtp.host="sing.ei.uvigo.es"
        mail.smtp.port="25"
        mail.smtp.auth="false"
/>
```

Inside the cloned repository:

```
docker build -t pandrugs .
```

This will take some time because the image will retrieve big files from internet (databases).

## Starting the server

```
docker run -d -v [your_local_dir_for_data OR volume_name]:/pandrugs-backend_data -p 80:8080 pandrugs
```
This will make your server available via the port 80 at the container machine.

## Accessing the server
The frontend will be serving at: http://yourhost

The backend will be serving at: http://yourhost/pandrugs-backend

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


