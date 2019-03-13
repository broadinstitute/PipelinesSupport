# Arrays Ambiguous SNP Miscalling March 2019
This directory contains files to help you evaluate the effect of the Arrays Ambiguous SNP Bug on your data.

In the main directory, there is a simple shell script named `isVcfAffected.sh`. This shell script can be run on your VCF to determine if the bug has affected your data.

Example Invocations:

    ./isVcfAffected.sh affected.vcf 
    The file affected.vcf (of array type: 'MEG_AllofUs_20002558X351448_A1') is affected by the Arrays Ambiguous SNP Bug

    ./isVcfAffected.sh affected.vcf.gz 
    The file affected.vcf.gz (of array type: 'MEG_AllofUs_20002558X351448_A1') is affected by the Arrays Ambiguous SNP Bug

There are also two example VCFs here, which are subsets of original VCFs. One example is affected by the bug and one is not.

## Filtering Affected Variants out of a VCF
We've provided a script that can filter SNPs that overlap with an interval list. The resulting file will still contain all the original variants. Variants in the affected sites will have been filtered with the filter-string `ARRAY_AMBIGUOUS_SNP_BUG`

To run this script you'll need to have GATK 4.1 installed on your computer. Please refer to [this](https://software.broadinstitute.org/gatk/documentation/quickstart.php) link for installation instructions.

**Invocation:**

```
filter_vcf.sh <GATK> <INTERVAL_LIST> <VCF>
```

**Inputs**

```
<GATK> points to your gatk executable
<INTERVAL_LIST> points to one of the interval lists provided in the IntervalLists directory that corresponds to each chip type
<VCF> is a vcf that needs it's bottom-stranded ambiguous SNPs filtered out (they will ) in the VCF, but their filter field will contain the string ARRAY_AMBIGUOUS_SNP_BUG
```

For example (from within the ArraysAmbiguousSNPMiscallingMar2019 directory): 

```
./filter_vcf.sh ~/gatk/gatk IntervalLists/PsychChip_v1-1_15073391_A1.1.3.interval_list Psych_cohort.vcf.gz
```

After filtering, the script runs a sanity check to see that the correct number of sites have been filtered. If the script ran successfully, a message in the end should tell you so. The script attempts to clean up after itself but leaves log files around.


