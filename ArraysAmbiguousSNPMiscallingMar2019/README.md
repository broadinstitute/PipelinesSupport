This directory contains files to help you evaluate the effect of the Arrays Ambiguous SNP Bug on your data.

In the main directory, there is a simple shell script named 'isVcfAffected.sh'.
This shell script can be run upon your VCF to determine if the bug has affected your data.

Example Invocation:
`./isVcfAffected.sh test.vcf`
`The file test.vcf is NOT affected by the Arrays Ambiguous SNP Bug`

The subdirectory IntervalLists contains interval_list files for all of the Illumina genotyping arrays that 
have had chips run that are affected by the bug.  This interval list can be used to for instance,
selectively pull the variants in the interval list from your vcf
here, using GATK's SelectVariants tool:
`./gatk SelectVariants -V test.vcf -L IntervalLists/MEG_AllofUs_20002558X351448_A2.1.3.interval_list -O out.vcf`
