#!/usr/bin/env bash


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --bim)
    BIM="$2"
    shift # past argument
    shift # past value
    ;;
    --frq)
    FRK="$2"
    shift # past argument
    shift # past value
    ;;
    --frq1kg)
    FRK1KG="$2"
    shift # past argument
    shift # past value
    ;;
    --pop)
    POP="$2"
    shift # past argument
    shift # past value
    ;;
    --out)
    OUT="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -z ${FRK1KG} ]]; then FRK1KG="1kg.frq"; fi
if [[ -z ${POP} ]]; then POP="EUR"; fi
if [[ -z ${OUT} ]]; then OUT="af.pdf"; fi


# raise an error if population outside
if [[ $POP != 'EUR' && $POP != 'EAS' && $POP != 'AFR' ]]; then
    echo "the input value for --pop should be EUR or EAS or AFR"
    exit 1
fi

# merge PLINK allele frequencies with PLINK bim file
awk 'NR==FNR{coord[$2]=$4; next }
     FNR>1 && ($2 in coord){print $1,coord[$2],$3,$4,$5}' $BIM $FRK > merged.frq


# merge merged.frq with 1000 genomes allele frequencies
awk 'NR==FNR{locus=$1$2$3$4; maf[locus]=$5; next }
     FNR>1 && ($1$2$5$4 in maf){print $1,$2,$5,$4,$6,$7,$8,maf[$1$2$5$4]}' merged.frq $FRK1KG > merged.1kg.frq


# run plot_af.r script
Rscript plot_af.r --frq merged.1kg.frq --pop $POP --out $OUT


# remove temporary files
rm merged.frq
rm merged.1kg.frq