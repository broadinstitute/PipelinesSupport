# Arrays Ambiguous SNP Miscalling March 2019
This directory contains files to help you evaluate the effect of the Arrays Ambiguous SNP Bug on your data. If you have questions, please contact BroadArraysPipelineHelp@broadinstitute.org.

In the main directory, there is a simple shell script named `isVcfAffected.sh`. This shell script can be run on your VCF to determine if the bug has affected your data.

Example Invocations:

    ./isVcfAffected.sh affected.vcf 
    The file affected.vcf (of array type: 'MEG_AllofUs_20002558X351448_A1') is affected by the Arrays Ambiguous SNP Bug

    ./isVcfAffected.sh unaffected.vcf.gz 
    The file unaffected.vcf.gz is NOT affected by the Arrays Ambiguous SNP Bug

The subdirectory IntervalLists contains interval_list files for all of the Illumina genotyping arrays that 
have had chips run that are affected by the bug.  This interval list can be used to filter out the affected variants from your vcf using the `filter_vcf.sh` script (see below).
There are also two example VCFs here, which are subsets of original VCFs. One example is affected by the bug, `affected.vcf.gz` and one is not, `unaffected.vcf.gz`.

## Filtering Affected Variants out of a VCF
We've provided a script that can filter SNPs that overlap with an interval list. The resulting file (named <ORGINAL_NAME>.filtered.vcf.gz) will still contain all the original variants. 
Affected variants will have been filtered with the filter-string `ARRAY_AMBIGUOUS_SNP_BUG`

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

After filtering, the script runs a sanity check to see that the correct number of sites have been filtered. If the script ran successfully, a message in the end should tell you so. 
The script attempts to clean up after itself but leaves log files around.

## Assessing and Fixing Miscalling Bugs in PLINK files

The subdirectory `allele_flip` provides tools for assessing whether your PLINK format genotyping data is affected by the strand ambiguous bug, and for fixing the bug through flipping DNA strand. Please refer to `allele_flip/README.md` for details.
