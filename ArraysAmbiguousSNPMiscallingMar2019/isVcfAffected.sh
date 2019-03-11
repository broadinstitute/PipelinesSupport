#!/bin/bash

if [ -z $1 ]; then
	echo "Usage: isVcfAffected.sh <vcf_file>"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "File $1 not found"
	exit 1
fi

if [ $1 == *.gz ]; then
	zcat $1 | sed '/^#CHROM/q;' | grep "extendedIlluminaManifestVersion=1.[012]" > /dev/null
else
	sed  '/^#CHROM/q;'  $1 | grep "extendedIlluminaManifestVersion=1.[012]" > /dev/null
fi
if [ $? == 0 ]; then
	echo "The file $1 is affected by the Arrays Ambiguous SNP Bug"
else
	echo "The file $1 is NOT affected by the Arrays Ambiguous SNP Bug"
fi
