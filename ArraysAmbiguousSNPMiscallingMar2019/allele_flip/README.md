This subdirectory provides tools for assessing whether your PLINK format genotyping data is affected by the strand ambiguous bug, and for fixing the bug by flipping the designated alleles in the binary map (or .bim) file at each affected SNP.

## Assessing Strand Ambiguous Bug
The shell script `compare_frequencies_against_1kg.r` can be used to determine if the bug has affected your data by plotting allele frequencies against 1000 genomes allele frequencies. The output of the script is a scatter plot, where the x-axis and y-axis are allele frequencies of your data and of 1000 genomes respectively. The subdirectory `1000_Genomes_AF subdirectory` contains 1000 genomes allele frequencies of strand ambiguous SNPs affected by the bug.

- If your data has SNPs affected by the bug, you'll observe a negative slope (i.e. y=-x pattern) in your output plot (see `pre_flip.pdf`)
- If your data doesn't suffer strand ambiguous bug, you'll observe a positive slope (i.e. y=x pattern) in your output plot (see `post_flip.pdf`)

**Invocations:**

```
usage: Rscript compare_frequencies_against_1kg.r \
  --frq <PLINK_FRK_FILE> \
  --frq1kg <1KG_FRK_FILE> \
  [--pop <POP>] \
  [--out <OUT>]
                       
<PLINK_FRK_FILE> = allele frequencies calculated using `PLINK --freq` command.
<1KG_FRK_FILE> = allele frequencies of 1000 genomes from ./1000_Genomes_AF subdirectory
<POP> = population name choosing from EUR, EAS and AFR. default is EUR
<OUT> = output plot name. default is `af.pdf`
```

To run this R script, package `dplyr`, `ggplot2` and `optparse` should be installed.

**Examples:**

You can calculate the allele frequencies of your genotypes file by running `plink --freq`. Remember to add `--keep-allele-order` to forces the original A1/A2 allele encoding to be preserved. Both [PLINK 1.07](http://zzz.bwh.harvard.edu/plink/) and [1.9](https://www.cog-genomics.org/plink2) support these commands. 

```
plink --bfile <BFILE> --freq --keep-allele-order
```

Running the command above will generate a `plink.frq` file. Then you can evaluate whether or not your data is affected by running the command below. In this example, your data is of European ancestry, and the genotyping platform is GSAMD. If not output filename is specified, a `af.pdf` file whill be generated in the current directory. 

```
Rscript compare_frequencies_against_1kg.r \
 --frq plink.frq \
 --frq1kg 1000_Genomes_AF/GSAMD-24v1-0_20011747_A1.1.3.1000_Genomes_AF.txt \
 --pop EUR
```
Suppose your genotyping platform used is PsychChip_v1-1, the ancestry of your cohort is East Asian, and you want your output file to be named as `af_eas.pdf`. You should run: 

```
Rscript compare_frequencies_against_1kg.r \
 --frq plink.frq \
 --frq1kg 1000_Genomes_AF/PsychChip_v1-1_15073391_A1.1.3.1000_Genomes_AF.txt \
 --pop EAS \
 --out af_eas.pdf 
```


## Flipping Affected SNPs 
The python script `allele_flip.py` can take the PLINK .bim file and interval list file as inputs to flip the alleles of affected SNPs (i.e. swaps A↔T and C↔G alleles, but does not flip strand). In the absence of a specified log file, the log will be output to stdout.

**Invocations:**

```
usage: flip_alleles.py [-h] --bim-in <BIM_IN> --bim-out <BIM_OUT> --list <INTERVAL_LIST>
                       [--log LOG]
                       
<BIM_IN> = PLINK .bim file to be flipped 
<BIM_OUT>= PLINK .bim with flipped alleles 
<INTERVAL_LIST> = list of positions with affected SNPs from ../IntervalLists subdirectory
```
To run this script, module `pandas` should be installed. The script can be run in either Python-2.7 or Python-3.

**An Example log:**

```
python flip_alleles.py --list ../IntervalLists/GSAMD-24v1-0_20011747_A1.1.3.interval_list --bim-in <BIM_IN> --bim-out <BIM_OUT>

log output:
number of SNPs in interval list to flip alleles: [XXX]
number of SNPs successfully matched and alleles flipped in map file: [XXX]
updated map file is here: <BIM_OUT>
```
