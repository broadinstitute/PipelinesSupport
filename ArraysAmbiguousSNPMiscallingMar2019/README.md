This directory contains files to help you evaluate the effect of the Arrays Ambiguous SNP Bug on your data.

In the main directory, there is a simple shell script named `isVcfAffected.sh`.
This shell script can be run upon your VCF to determine if the bug has affected your data.

Example Invocations:
./isVcfAffected.sh affected.vcf 
The file affected.vcf (of array type: 'MEG_AllofUs_20002558X351448_A1') is affected by the Arrays Ambiguous SNP Bug
./isVcfAffected.sh affected.vcf.gz 
The file affected.vcf.gz (of array type: 'MEG_AllofUs_20002558X351448_A1') is affected by the Arrays Ambiguous SNP Bug

The subdirectory IntervalLists contains interval_list files for all of the Illumina genotyping arrays that 
have had chips run that are affected by the bug.  This interval list can be used to filter out the affected variants from your vcf using GATK's VariantFiltration tool:

    ./gatk VariantFiltration -V input.vcf \
          --mask IntervalLists/MEG_AllofUs_20002558X351448_A2.1.3.interval_list \
          --mask-name ARRAY_AMBIGUOUS_SNP_BUG \
          -O output.vcf`

The resulting file will still contain all the original variants. Variants in the affected sites will have been filtered with the filter-string `ARRAY_AMBIGUOUS_SNP_BUG`

Please note that GATK needs to have been installed on your system. Please refer to [this](https://software.broadinstitute.org/gatk/documentation/quickstart.php) link for installation instructions.
