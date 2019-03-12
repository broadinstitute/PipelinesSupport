 

###################################################################################################
#                                                                                                 #
#  A script to filter SNPs that overlap with an interval list.                                    #
#                                                                                                 #
#  This is for the ARRAYs ambiguous SNP bug. To run this script you'll need to have gatk 4.1      #
#  installed on your computer.                                                                    #
#                                                                                                 #
#  invocation:                                                                                    #
#  filter_vcf.sh <GATK> <INTERVAL_LIST> <VCF>                                                     #
#                                                                                                 #
#  where:                                                                                         #
#     <GATK> points to your gatk executable                                                       #
#     <INTERVAL_LIST> points to one of the interval lists provided in the IntervalLists directory #
#     <VCF> is a vcf that needs it's bottom-stranded ambiguous SNPs filtered out (they will )     #
#           in the VCF, but their filter field will contain the string ARRAY_AMBIGUOUS_SNP_BUG    #
#                                                                                                 #
#  After filtering, the script runs a sanity check to see that the correct number of sites        #
#  have been filtered. If the script ran successfully, A message in the end should tell you so.   #                                                                                                #
#                                                                                                 #
#  The script attempts to clean up after itself but leaves log files around.                      #
#                                                                                                 #
###################################################################################################

set -eo pipefail

GATK=$1
INTERVAL_LIST=$2
VCF=$3

FILTER=ARRAY_AMBIGUOUS_SNP_BUG
DICT=$(basename ${INTERVAL_LIST%interval_list}dict)
BED=$(basename ${INTERVAL_LIST%interval_list}bed)
VCF_OUT=$(basename ${VCF%vcf*}filtered.vcf${VCF##*vcf})
VCF_OUT_SNPS=$(basename ${VCF%vcf*}filtered.SNPs.vcf${VCF##*vcf})
VCF_SNPS=$(basename ${VCF%vcf*}SNPs.vcf${VCF##*vcf})
VCF_NONSNPS=$(basename ${VCF%vcf*}NONSNPs.vcf${VCF##*vcf})
VCF_UNMERGED_IL=vcf_unmerged.interval_list
VCF_MERGED_IL=vcf_merged.interval_list
FILTERED_VARIANTS=filtered.variants.vcf.gz

echo "indexing vcf"
$GATK IndexFeatureFile -F $VCF 2> index.vcf.log || (cat index.vcf.log && exit 1)

echo "grabbing dictionary from interval list"
grep -e '@HD' -e '@SQ' $INTERVAL_LIST > $DICT 

echo "converting interval list to BED"
$GATK IntervalListToBed -I $INTERVAL_LIST -O $BED 2> intervallist.to.bed.log || (cat intervallist.to.bed.log && exit 1)

echo "indexing bed file"
$GATK IndexFeatureFile -F $BED  2> index.bed.log || (cat index.bed.log && exit 1)

echo "splitting out SNPs"
$GATK SelectVariants \
    -V $VCF \
    --select-type-to-include SNP \
    -O $VCF_SNPS 2> select.snps.log || (cat select.snps.log && exit 1)

echo "splitting out non-SNPs"
$GATK SelectVariants \
    -V $VCF \
    --select-type-to-exclude SNP \
    -O $VCF_NONSNPS 2> select.nonsnps.log || (cat select.nonsnps.log && exit 1)

echo "filtering buggy variants from SNPs"
$GATK VariantFiltration \
   --sequence-dictionary $DICT \
   -V $VCF_SNPS \
   --mask $BED \
   --mask-name $FILTER \
   -O $VCF_OUT_SNPS 2> variantfiltration.log || (cat variantfiltration.log && exit 1)

echo "merging SNPs and non-SNPs"
$GATK MergeVcfs \
   --INPUT $VCF_OUT_SNPS \
   --INPUT $VCF_NONSNPS \
   --OUTPUT $VCF_OUT 2> merge.vcf.log || (cat merge.vcf.log && exit 1)

echo "selecting filtered variants"
$GATK SelectVariants \
   -V $VCF_OUT \
   -OVI false \
   -selectExpressions " $FILTER == 1 " \
   -O $FILTERED_VARIANTS 2> filter.variants.log || (cat filter.variants.log && exit 1)

echo "converting filtered variants to interval list"
 $GATK VcfToIntervalList \
   	--INPUT $FILTERED_VARIANTS \
   	--OUTPUT $VCF_UNMERGED_IL \
   	--INCLUDE_FILTERED true 2> vcf.to.interval_list.log || (cat vcf.to.interval_list.log && exit 1)

echo "uniquifing (vcf) interval list"
 $GATK IntervalListTools \
 	--UNIQUE true \
   	--INPUT $VCF_UNMERGED_IL \
   	--OUTPUT $VCF_MERGED_IL 2> unique.interval_list.log || (cat unique.interval_list.log && exit 1)

echo "counting territory in (vcf) interval list"
 ($GATK IntervalListToBed \
    -I $VCF_MERGED_IL \
    -O /dev/stdout 2> vcf.intervallist.to.bed.log || (cat vcf.intervallist.to.bed.log && exit 1 )) | \
 awk 'BEGIN{total=0}{total+=$3-$2}END{print total}' > filtered_variants.count

echo "counting territory in filter intervals"
awk 'BEGIN{total=0}{total+=$3-$2}END{print total}' $BED > interval_list.count

echo Resulting vcf contains `cat filtered_variants.count` filtered variants
echo Interval list contain `cat interval_list.count` sites

if [ $(cat filtered_variants.count) == $(cat interval_list.count) ]; then 
    echo "******************************************************"
    echo "*                                                    *"
	echo "* These two numbers should be the same and they are. *"
    echo "*                                                    *"
    echo "******************************************************"
else
	echo "**************************************************************************"
    echo "*                                                                        *"
	echo "These two numbers should be the same BUT THEY ARE NOT. Please seek help! *"
    echo "*                                                                        *"
    echo "**************************************************************************"
fi


rm -f $DICT $BED $VCF_OUT $VCF_OUT_SNPS $VCF_SNPS 
rm -f $VCF_NONSNPS $VCF_UNMERGED_IL $VCF_MERGED_IL 
rm -f $FILTERED_VARIANTS  $BED.idx $VCF.{tbi,idx}
rm -f $VCF_OUT_SNPS.{tbi,idx} $VCF_SNPS.{tbi,idx} $VCF_NONSNPS.{tbi,idx} 
rm -f $VCF_UNMERGED_IL $VCF_MERGED_IL interval_list.count filtered_variants.count

