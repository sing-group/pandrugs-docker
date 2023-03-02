# pandrugs2-vep

In order to build the `pandrugs2-vep` and make it functional, please follow these steps carefully:

1. Create a directory named `/opt/pandrugs2/vep-data/`. This directory will be used to store the databases and files required by the `pandrugs2-vep` programs. If you create it in another location, please mind that you will need to add a third parameter to the `run-pandrugs-vep-*-on-docker.sh` scripts. 
   
2. Run `docker build ./ -f Dockerfile.vep -t pandrugs2-vep` to create the base Docker image.

3. Run `download-vep-parser-data.sh /opt/pandrugs2/vep-data/` (or the path to the directory created in step 1). This script performs the following steps:
   
   1. Download the CADD plugin files (whole_genome_SNVs.tsv.gz, whole_genome_SNVs.tsv.gz.tbi, InDels.tsv.gz and InDels.tsv.gz.tbi) into `/opt/pandrugs2/vep-data/.`

   2. Copy the `ensembl-vep/homo_sapiens directory` from the `pandrugs2-vep` Docker image.
   
   3. Download the VEP parser databases into `/opt/pandrugs2/vep-data/vep-parser`.

After running these three steps, you must:

- Have a Docker image named `pandrugs2-vep` that takes about 29GB.
- Have the following tree directory at `/opt/pandrugs2/vep-data/` (it takes 224GB):

```
/opt/pandrugs2/vep-data/
├── homo_sapiens
│   └── 109_GRCh38
├── InDels.tsv.gz
├── InDels.tsv.gz.tbi
├── vep-parser
│   ├── cancer_domain.db
│   ├── clinvar.db
│   ├── cosmic00.db
│   ├── cosmic01.db
│   ├── cosmic02.db
│   ├── cosmic03.db
│   ├── cosmic04.db
│   ├── cosmic05.db
│   ├── cosmic06.db
│   ├── cosmic07.db
│   ├── cosmic08.db
│   ├── cosmic09.db
│   ├── cosmic10.db
│   ├── cosmic11.db
│   ├── cosmic12.db
│   ├── cosmic13.db
│   ├── cosmic14.db
│   ├── cosmic15.db
│   ├── cosmic16.db
│   ├── cosmic17.db
│   ├── cosmic18.db
│   ├── cosmic19.db
│   ├── cosmic20.db
│   ├── cosmic21.db
│   ├── cosmic22.db
│   ├── cosmic23.db
│   ├── cosmic24.db
│   ├── cosmic25.db
│   ├── cosmic_gene_freq.db
│   ├── essential.db
│   ├── gene_pathway.db
│   ├── generole.db
│   ├── genesids.db
│   ├── gscore.db
│   ├── interpro_a.db
│   ├── last_domain.db
│   ├── pathways_desc.db
│   ├── pfam.db
│   └── uniprot_b.db
├── whole_genome_SNVs.tsv.gz
└── whole_genome_SNVs.tsv.gz.tbi

3 directories, 43 files
```

And if you run `dh --max-depth=1 /opt/pandrugs2/vep-data/` you should obtain:

```
85G     /opt/pandrugs2/vep-data/homo_sapiens
58G     /opt/pandrugs2/vep-data/vep-parser
224G    /opt/pandrugs2/vep-data/
```

## Test data

To check that the  `pandrugs2-vep` Docker image is working properly, you may run the following commands using the `test-data/TCGA-BF-A1PU-01A-11D-A19A-08_hg38` file:

```
scripts/run-pandrugs-vep-on-docker.sh $(pwd)/test-data/TCGA-BF-A1PU-01A-11D-A19A-08_hg38.vcf /tmp/test-vep/TCGA-BF-A1PU-01A-11D-A19A-08_hg38.vep.vcf.gz /opt/pandrugs2/vep-data/vep-parser

scripts/run-pandrugs-vep-parser-on-docker.sh /tmp/test-vep/TCGA-BF-A1PU-01A-11D-A19A-08_hg38.vep.vcf.gz /tmp/test-vep/output-vep-parser /opt/pandrugs2/vep-data/vep-parser/vep-data
```

Note that the last parameters may be omitted if data is located at `/opt/pandrugs2/vep-data/vep-parser`.