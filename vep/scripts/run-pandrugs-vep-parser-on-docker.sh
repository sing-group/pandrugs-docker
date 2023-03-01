#!/bin/bash

INPUT_FILE=$1
OUTPUT_DIR=$2
VEP_PARSER_DBS_DATA_DIR=${3:-/opt/pandrugs2/vep-data/vep-parser/}

/bin/bash -c "docker run --rm -v $(dirname $INPUT_FILE):$(dirname $INPUT_FILE) -v $(dirname $OUTPUT_DIR):$(dirname $OUTPUT_DIR) -v $(dirname $VEP_PARSER_DBS_DATA_DIR):$(dirname $VEP_PARSER_DBS_DATA_DIR) pandrugs2-vep perl /opt/vep-parser/VEP_parser_v20_PD.pl -f=$INPUT_FILE -d=$VEP_PARSER_DBS_DATA_DIR --output=$OUTPUT_DIR --int=pandrugs2backend"
