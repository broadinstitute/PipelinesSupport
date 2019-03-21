This subdirectory provides tools for assessing whether your PLINK format genotyping data is affected by the strand ambiguous bug, and for fixing the bug through flipping DNA strand.

## Assessing Strand Ambiguous Bug
The shell script `compare_frequencies_against_1kg.sh` can be used to determine if the bug has affected your data by plotting allele frequencies against 1000 genomes allele frequencies. The file `af.pdf` is an example output. 

**Invocations:**

```
plink --bfile <BFILE> --freq --keep-allele-order
./compare_frequencies_against_1kg.sh --bim <BIM FILE> --frq <FRK FILE> 
```

## Flipping Affected Varaints 
The python script `allele_flip.py` can take the PLINK bim file and inteval list file as inputs to flip the DNA strand of affected variants (swaps A↔T and C↔G)

**Invocations:**

```
usage: flip_alleles.py [-h] --bim-in BIM_IN --bim-out BIM_OUT --list SNPS_LIST
                       [--log LOG]
```

**Log**

```
flip_alleles.py --list GSAMD-24v1-0_20011747_A1.1.3.interval_list --bim_in <BIM_IN> --bim_out <BIM_OUT>

log output:
number of SNPs in interval list to flip alleles: [XXX]
number of SNPs successfully matched to map file: {XXX}
updated map file is here: <BIM_OUT>
```