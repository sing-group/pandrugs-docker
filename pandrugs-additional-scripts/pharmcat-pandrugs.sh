#!/bin/bash

set -o nounset
set -o errexit


display_usage() {
    echo -e "Runs PharmCat on the input VCF file."
    echo -e "\nUsage:"
    echo -e "\t`basename $0` </path/to/input/vcf_file>"
    echo -e "\t`basename $0` </path/to/input/vcf_file> </path/to/input/optional_phenotyper_outside_call_file>"
}

if [[ ! $# -eq 2 ]] && [[ ! $# -eq 1 ]]; then
    echo -e "Error: this script requires one or two arguments\n"
    display_usage
    exit 1
fi

if [[ $1 == "--help" ]]
then
    display_usage
    exit 0
fi

INPUT_VCF=${1}

if [[ ! -f ${INPUT_VCF} ]]; then
    echo "ERROR: the input must be an VCF file (actual file: ${INPUT_VCF})"
    exit 1
fi

INPUT_OPTIONAL_FILE="unset"
if [[ $# -eq 2 ]]; then
    INPUT_OPTIONAL_FILE=${2}
fi

TMP_DIR=$(mktemp -d /tmp/pharmcat_pandrugs.XXXXXX)

echo "Running`basename $0` on:"
echo -e "\t${INPUT_VCF}"
cp "${INPUT_VCF}" ${TMP_DIR}/input.pharmcat.vcf

if [[ "${INPUT_OPTIONAL_FILE}" != "unset" ]]; then
    echo -e "\t${INPUT_OPTIONAL_FILE}"
    cp "${INPUT_OPTIONAL_FILE}" ${TMP_DIR}/phenotyper_outside_call_file.tsv
fi

echo "[1/2] Running VCF preprocessor:"
docker run --rm \
    -v ${TMP_DIR}:/pharmcat/data \
        pgkb/pharmcat:2.1.2 ./pharmcat_vcf_preprocessor.py -vcf data/input.pharmcat.vcf

echo "[2/2] Running PharmCAT:"
if [[ "${INPUT_OPTIONAL_FILE}" != "unset" ]]; then
    docker run --rm \
        -v ${TMP_DIR}:/pharmcat/data \
            pgkb/pharmcat:2.1.2 ./pharmcat \
                -vcf data/PharmCAT.preprocessed.vcf --reporter-save-json \
                --phenotyper-outside-call-file data/phenotyper_outside_call_file.tsv
else
    docker run --rm \
        -v ${TMP_DIR}:/pharmcat/data \
            pgkb/pharmcat:2.1.2 ./pharmcat \
                -vcf data/PharmCAT.preprocessed.vcf --reporter-save-json
fi

OUTPUT_DIR=$(dirname "${INPUT_VCF}")

cp ${TMP_DIR}/PharmCAT.preprocessed.report.html "${OUTPUT_DIR}/pharmcat.report.html"
cp ${TMP_DIR}/PharmCAT.preprocessed.report.json "${OUTPUT_DIR}/pharmcat.report.json"

rm -rf ${TMP_DIR}
