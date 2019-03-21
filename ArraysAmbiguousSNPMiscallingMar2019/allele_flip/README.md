This subdirectory provides tools for assessing whether your PLINK format genotyping data is affected by the strand ambiguous bug, and for fixing the bug through flipping DNA strand.

## Assessing Strand Ambiguous Bug
The shell script `compare_frequencies_against_1kg.r` can be used to determine if the bug has affected your data by plotting allele frequencies against 1000 genomes allele frequencies. The file `af.pdf` is an example output. 

**Invocations:**

You can calculate the allele frequencies of your genotypes file by running `plink --freq`. Remember to add `--keep-allele-order` to forces the original A1/A2 allele encoding to be preserved.

```
plink --bfile <PLINK BFILE> --freq --keep-allele-order
```

Then you can evaluate whether or not your data is affected by running the following command (suppose your data is from European ancestry, and the genotyping platform is GSAMD). 

```
Rscript compare_frequencies_against_1kg.r \
 --frq plink.frq \
 --frq1kg 1000_Genomes_AF/GSAMD-24v1-0_20011747_A1.1.3.1000_Genomes_AF.txt
```


## Flipping Affected Varaints 
The python script `allele_flip.py` can take the PLINK bim file and inteval list file as inputs to flip the DNA strand of affected variants (swaps A↔T and C↔G)

**Invocations:**

```
usage: flip_alleles.py [-h] --bim-in <BIM_IN> --bim-out <BIM_OUT> --list <INTERVAL_LIST>
                       [--log LOG]
                       
<BIM_IN> = PLINK .bim file to be flipped 
<BIM_OUT>= PLINK .bim with flipped alleles 
<INTERVAL_LIST> = list of positions with affected SNPs from ../IntervalLists subdirectory
```

**An Example log:**

```
flip_alleles.py --list ../IntervalLists/GSAMD-24v1-0_20011747_A1.1.3.interval_list --bim-in <BIM_IN> --bim-out <BIM_OUT>

log output:
number of SNPs in interval list to flip alleles: [XXX]
number of SNPs successfully matched to map file: [XXX]
updated map file is here: <BIM_OUT>
```