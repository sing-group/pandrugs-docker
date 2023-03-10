
# PanDrugs2 additional scripts

This folder contains two additional scripts used by the PanDrugs2 backend to perform two tasks before running VEP:

- `check-and-preprocess-vcf.sh </path/to/input.vcf> <pharmcat>`: checks the input VCF files and uses `bcftools` to create two new VCF files to be used in VEP and in PharmCat respectively. The PharmCat official Docker image (`pgkb/pharmcat:2.1.2`) is used as it contains `bcftools`.
- `pharmcat-pandrugs.sh </path/to/input.pharmcat.vcf>`: runs PharmCat using the official image (`pgkb/pharmcat:2.1.2`).

These two scripts are added to the PanDrugs2 Docker image (at `/pandrugs-additional-scripts`) and configured in the `context.xml` file.

You may run the following commands using the VCF file at `test-data` to check they are working properly:

```
./check-and-preprocess-vcf.sh test-data/pharmcat_positions.vcf yes

./pharmcat-pandrugs.sh test-data/pharmcat_positions.pharmcat.vcf
```