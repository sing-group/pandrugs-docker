#!/bin/bash

if [[ ! $# -eq 2 ]]; then
    echo "ERROR: this script requires two arguments."
    exit 1
fi

INPUT_VCF=$1

if [[ ! -f ${INPUT_VCF} ]]; then
    echo "ERROR: the input must be an VCF file (actual file: ${INPUT_VCF})"
    exit 1
fi

INPUT_VCF_NAME=$(basename ${INPUT_VCF})
INPUT_VCF_NAME=${INPUT_VCF_NAME/.vcf/}

PHARMCAT=$2

if [[ "${PHARMCAT}" != "yes" && "${PHARMCAT}" != "no" ]]; then
    echo "ERROR: <pharmcat> must be \"yes\" or \"no\""
    exit 1
fi

OUTPUT_DIR=$(dirname ${INPUT_VCF})

OUTPUT_VCF_TOVEP="${OUTPUT_DIR}/${INPUT_VCF_NAME}.vep.vcf"
OUTPUT_VCF_TOPHARMCAT="${OUTPUT_DIR}/${INPUT_VCF_NAME}.pharmcat.vcf"

TMP_DIR=$(mktemp -d /tmp/vcf_pandrugs.XXXXXX)

echo "Running `basename $0` on: ${INPUT_VCF}"
cp "${INPUT_VCF}" ${TMP_DIR}/input.vcf.original

bcftools="docker run --rm -v ${TMP_DIR}:/pharmcat/data -w /pharmcat/data pgkb/pharmcat:2.1.2 bcftools"

${bcftools} sort -o input.vcf input.vcf.original

# Number of samples. It must be max 2 and their names "normal" and "tumor", in any order.
${bcftools} query -l input.vcf | sort > ${TMP_DIR}/samples.txt
NUM_SAMPLES=$(cat ${TMP_DIR}/samples.txt | grep -ch "^")
if [[ ${NUM_SAMPLES} -gt 2 ]]; then
    echo "ERROR: VCF must contain 11 columns max" | tee ${OUTPUT_DIR}/${INPUT_VCF_NAME}.err.log
    exit 1
elif [[ ${NUM_SAMPLES} -eq 2 ]]; then
    echo -e "normal\ntumor" > ${TMP_DIR}/sample_names.txt
    cmp -s ${TMP_DIR}/samples.txt ${TMP_DIR}/sample_names.txt
    if [[ $? -gt 0 ]]; then
        echo "ERROR: samples must be named 'tumor' and 'normal'" | tee ${OUTPUT_DIR}/${INPUT_VCF_NAME}.err.log
        exit 1
    fi
elif [[ "${PHARMCAT}" == "yes" && ${NUM_SAMPLES} -eq 0 ]]; then
    echo "ERROR: PharmCAT requires at least one sample and the genotype column" | tee ${OUTPUT_DIR}/${INPUT_VCF_NAME}.err.log
    exit 1
fi

echo "PharmCAT" > ${TMP_DIR}/sample_rename.txt
if [[ ${NUM_SAMPLES} -eq 2 ]]; then
    if [[ "${PHARMCAT}" == "yes" ]]; then
        ${bcftools} view -Ov -s "normal" input.vcf > ${TMP_DIR}/input.vcf.normal.1
        ${bcftools} annotate -x INFO,^FORMAT/GT input.vcf.normal.1 > ${TMP_DIR}/input.vcf.normal.2
        ${bcftools} reheader -s sample_rename.txt input.vcf.normal.2 > ${OUTPUT_VCF_TOPHARMCAT}
    fi

    ${bcftools} view -c1 -Ov -s "tumor" input.vcf > ${TMP_DIR}/input.vcf.tumor
    ${bcftools} annotate -x INFO,^FORMAT/GT input.vcf.tumor > ${OUTPUT_VCF_TOVEP}
elif [[ ${NUM_SAMPLES} -eq 1 ]]; then
    if [[ "${PHARMCAT}" == "yes" ]]; then
        ${bcftools} annotate input.vcf -x INFO,^FORMAT/GT > ${TMP_DIR}/input.vcf.pharmcat
        ${bcftools} reheader -s sample_rename.txt input.vcf.pharmcat > ${OUTPUT_VCF_TOPHARMCAT}
    fi
    ${bcftools} annotate input.vcf -x INFO,^FORMAT/GT > ${OUTPUT_VCF_TOVEP}
else
    cat ${INPUT_VCF} > ${OUTPUT_VCF_TOVEP}
fi

rm -rf ${TMP_DIR}
