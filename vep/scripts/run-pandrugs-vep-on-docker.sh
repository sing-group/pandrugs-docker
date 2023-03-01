#!/bin/bash

INPUT_FILE=$1
OUTPUT_FILE=$2
VEP_DATA_DIR=${3:-/opt/pandrugs2/vep-data/}

/bin/bash -c "docker run --rm -v $(dirname $INPUT_FILE):$(dirname $INPUT_FILE) -v $(dirname $OUTPUT_FILE):$(dirname $OUTPUT_FILE) -v $(dirname $VEP_DATA_DIR):$(dirname $VEP_DATA_DIR) pandrugs2-vep vep -i $INPUT_FILE -o $OUTPUT_FILE --format 'vcf' --vcf --compress_output gzip --force_overwrite --sift b --polyphen b --ccds --uniprot --hgvs --symbol --numbers --domains --regulatory --canonical --protein --biotype --tsl --af --variant_class --xref_refseq --af_1kg --af_gnomad --appris --plugin CADD,$VEP_DATA_DIR/whole_genome_SNVs.tsv.gz,$VEP_DATA_DIR/InDels.tsv.gz --cache --dir_cache $VEP_DATA_DIR --offline --assembly GRCh38 --fasta $VEP_DATA_DIR/homo_sapiens/109_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa --fork 4"
