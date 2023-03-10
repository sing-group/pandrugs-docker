# pandrugsdb-docker

Version: 2021.04.27

A Dockerfile to generate an all-in-one PanDrugs server. 

To be fully functional, this PanDrugs server requires:

- An additional Docker image for running VEP. Check [this instructions](vep/README.md) to build and configure the image and see how
- An additional Docker image for running PharmCat. The official image `pgkb/pharmcat:2.1.2` is used to run [the additional scripts](pandrugs-additional-scripts/README.md).

## Versions of PanDrugs components included in this image

* Front-end: 1.2.3
* Back-end: 1.1.7
* Perl variant analysis module: v19
* Database: 20210427

## Versions of databases used by PanDrugs and included this image

* DGIdb: 2020-Feb
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
* KEGG: Release 93.0

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

Inside the cloned repository:

```
docker build -t pandrugs2 .
```

This will take some time because the image will retrieve big files from internet (databases).

## Starting the server

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp -v [your_local_dir_for_data OR volume_name]:/pandrugs2-backend_data -p 80:8080 --name pandrugs2 pandrugs2
```
This command will:
- Make your server available via the port 80 at the container machine.
- Allow the container executing Docker.
- Share the host `/tmp` directory with the container.

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
