#!/bin/bash

if [ -z $1 ]; then
	echo "Usage: isVcfAffected.sh <vcf_file>"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "File $1 not found"
	exit 1
fi

if [[ $1 == *.gz ]]; then
	gunzip -c $1 | sed '/^#CHROM/q;' | grep "extendedIlluminaManifestVersion=1.[012]" > /dev/null
elif [[ $1 == *.vcf ]]; then
	sed  '/^#CHROM/q;'  $1 | grep "extendedIlluminaManifestVersion=1.[012]" > /dev/null
else
	echo "Unrecognized file type $1"
	exit 1
fi

if [ $? != 0 ]; then 
	echo "The file $1 is NOT affected by the Arrays Ambiguous SNP Bug"
	exit 0
fi

if [[ $1 == *.gz ]]; then
	ARRAY_TYPE=`gunzip -c $1 | sed '/^#CHROM/q;' | grep arrayType | cut -d '=' -f 2`
else
	ARRAY_TYPE=`sed '/^#CHROM/q;' $1 | grep arrayType | cut -d '=' -f 2`
fi

if [ $? == 0 ]; then
	echo "The file $1 (of array type: '$ARRAY_TYPE') is affected by the Arrays Ambiguous SNP Bug"
fi
