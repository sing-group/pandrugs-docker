#!/bin/bash

function help() {
    echo "This scripts performs the following steps:"
    echo -e "\t1. Download the CADD plugin files (whole_genome_SNVs.tsv.gz, whole_genome_SNVs.tsv.gz.tbi, InDels.tsv.gz and InDels.tsv.gz.tbi) into /path/to/vep-data"
    echo -e "\t2. Copy the ensembl-vep/homo_sapiens directory from the pandrugs2-vep Docker image. After moving it, the script tags the old image as pandrugs2-vep:original and commits the changes in pandrugs2-vep so that it does not longer contain that directory."
    echo -e "\t3. Download the VEP parser databases into /path/to/vep-data/vep-parser"
}

if [ ! $# -eq 1 ]; then
    echo -e "[Error] This script requires one argument, which is the path to the directory where the VEP and VEP parser data must be stored.\n"
    help
    exit -1
fi

if [ "$1" == "--help" ]; then
    help
    exit 0
fi

VEP_DATA_DIR="${1}/vep-data"

if [ -d "${VEP_DATA_DIR}" ]; then
    echo "[Error] ${VEP_DATA_DIR} already exists, delete it an run the script again"
    exit -1
fi

mkdir -p "${VEP_DATA_DIR}/vep-parser"

echo "[1/3] Downlading VEP parser data"

cd "${VEP_DATA_DIR}/vep-parser"

wget https://static.sing-group.org/pandrugs2/resources/2022.02.27-vep-parser_v20-dbs.zip --output-document=vep-parser.zip
unzip vep-parser.zip
rm vep-parser.zip

cd "${VEP_DATA_DIR}"

echo "[2/3] Downlading CADD plugin data"

wget https://krishna.gs.washington.edu/download/CADD/v1.5/GRCh38/whole_genome_SNVs.tsv.gz
wget https://krishna.gs.washington.edu/download/CADD/v1.5/GRCh38/whole_genome_SNVs.tsv.gz.tbi
wget https://krishna.gs.washington.edu/download/CADD/v1.5/GRCh38/InDels.tsv.gz
wget https://krishna.gs.washington.edu/download/CADD/v1.5/GRCh38/InDels.tsv.gz.tbi

echo "[3/3] Extracting pandrugs2-vep Docker image data"

DOCKER_IMAGE="pandrugs2-vep"

if [ $(docker images | grep ${DOCKER_IMAGE} | wc -l) -eq 0 ]; then 
    echo "[Error] The ${DOCKER_IMAGE} Docker image does not exist, please build it first using the given instructions"
    exit -1
fi

docker run -u "$(id -u)":"$(id -g)" --rm -v "${VEP_DATA_DIR}":/tmp/vep-data ${DOCKER_IMAGE} cp -R /opt/vep/src/ensembl-vep/homo_sapiens /tmp/vep-data/homo_sapiens

gunzip "${VEP_DATA_DIR}/homo_sapiens/109_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
