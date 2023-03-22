# pandrugs2-vep

The `pandrugs2-vep` Docker image contains an installation of [VEP](https://www.ensembl.org/info/docs/tools/vep/index.html) ready to be used with PanDrugs2.

In order to build the `pandrugs2-vep` and make it functional, please follow these steps carefully:

1. Create a directory named `/opt/pandrugs2/`. This directory will be used to store the databases and files required by the `pandrugs2-vep` programs. If you create it in another location, please mind that you will need to add a third parameter to the `run-pandrugs-vep-*-on-docker.sh` scripts. 
   
2. Run `docker-compose build` to create the base Docker image.

3. Run `scripts/download-vep-parser-data.sh /opt/pandrugs2/ pandrugs2-vep:vep_109.3_with_vep_parser_v20 bash` (or the path to the directory created in step 1). This script performs the following steps:
   
   1. Download the [CADD](https://github.com/Ensembl/VEP_plugins/blob/release/109/CADD.pm) plugin files (`whole_genome_SNVs.tsv.gz`, `whole_genome_SNVs.tsv.gz.tbi`, `InDels.tsv.gz` and `InDels.tsv.gz.tbi`) into `/opt/pandrugs2/vep-data/.`

   2. Copy the `ensembl-vep/homo_sapiens` directory from the `pandrugs2-vep:vep_109.3_with_vep_parser_v20 bash` Docker image.
   
   3. Download the VEP parser databases into `/opt/pandrugs2/vep-data/vep-parser`.

   4. Create the following symbolic link in the host: `ln -s /var/lib/docker/volumes/pandrugs2-dev-data/_data /pandrugs2-backend_data`. This is because the Docker run commands (created in the `run-pandrugs-vep-*-on-docker.sh` scripts) will use references to directories inside `/pandrugs2-backend_data`. As these commands are executed in the host, such path must exist and point to the actual location of the data (which in this case is the location of the corresponding managed Docker volume).

After running these steps, you must:

- Have a Docker image named `pandrugs2-vep:vep_109.3_with_vep_parser_v20` that takes about 29GB.
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

And if you run `du -h --max-depth=1 /opt/pandrugs2/vep-data/` you should obtain:

```
85G     /opt/pandrugs2/vep-data/homo_sapiens
58G     /opt/pandrugs2/vep-data/vep-parser
224G    /opt/pandrugs2/vep-data/
```

## Test data

To check that the `pandrugs2-vep` Docker image is working properly, you may run the following commands using the `test-data/TCGA-BF-A1PU-01A-11D-A19A-08_hg38` file:

```
scripts/run-pandrugs-vep-on-docker.sh $(pwd)/test-data/TCGA-BF-A1PU-01A-11D-A19A-08_hg38.vcf /tmp/test-vep/TCGA-BF-A1PU-01A-11D-A19A-08_hg38.vep.vcf.gz /opt/pandrugs2/vep-data

scripts/run-pandrugs-vep-parser-on-docker.sh /tmp/test-vep/TCGA-BF-A1PU-01A-11D-A19A-08_hg38.vep.vcf.gz /tmp/test-vep/output-vep-parser /opt/pandrugs2/vep-data/vep-parser
```

Note that the last parameters may be omitted if data is located at `/opt/pandrugs2/vep-data/vep-parser`.
