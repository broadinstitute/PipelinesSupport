library(dplyr)
library(ggplot2)
library(optparse)


# specify input parameters 
option_list = list(
  # input allele frequencies calculated using PLINK
  make_option(c("--frq"), type="character", default=NULL, 
              help="path to PLINK .frq file", metavar="character"),
  # 1000 Genomes allele frequencies 
  make_option(c("--frq1kg"), type="character", default=NULL, 
              help="path to 1000 Genomes allele freqeunecies", metavar="character"),
  # continential ancestries, choosing between EUR, EAS and AFR 
  make_option(c("--pop"), type="character", default='EUR', 
              help="path to 1000 genomes allele frequencies", metavar="character"),
  # output plot path
  make_option(c("--out"), type="character", default="af.pdf", 
              help="output file name [default= %default]", metavar="character")
); 

# make options 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# error check 
if (! opt$pop %in% c("EUR", "EAS", "AFR")) {stop("The population can only be EUR, EAS and AFR!")}

# import allele frq
cat("Start importing allele frequencies!\n")
#  1                   rs113288277    T    A       0.9609      486
frq <- read.delim(opt$frq, sep='', header=TRUE, as.is=TRUE,
                  colClasses=c('character', 'character', 'character', 'character', 'numeric', 'numeric'))

# import 1KG allele frequencies 
cat("Starting importing allele frequencies of 1KG!\n")
# chr	position	ID	A1	A2	af_eur	af_eas	af_afr
# 1	979748	rs113288277	A	T	0.0467	0.0079	0.0008
# 1	980824	seq-rs112039851	G	C	0.003	0.0268	0.0726
frq1kg <- read.delim(opt$frq1kg, sep='', header=TRUE, as.is=TRUE, 
                  colClasses=c("character", "numeric", "character", "character", "character", "numeric", "numeric", "numeric"))
colnames(frq1kg) <- c("chr", "position", "SNP",	"A1", "A2", "AF_EUR",	"AF_EAS", "AF_AFR")

# merge 
n_tmp1 <- nrow(inner_join(frq, frq1kg, by = c("SNP" = "SNP", "A1" = "A2", "A2" = "A1")))
n_tmp2 <- nrow(inner_join(frq, frq1kg, by = c("SNP" = "SNP", "A1" = "A1", "A2" = "A2")))

if (n_tmp1 > n_tmp2) {
  frq <- frq %>% inner_join(frq1kg, by = c("SNP" = "SNP", "A1" = "A2", "A2" = "A1"))
} else {
  frq <- frq %>% 
    inner_join(frq1kg, by = c("SNP" = "SNP", "A1" = "A1", "A2" = "A2")) %>%
    mutate(MAF = 1 - MAF)
}

# plot
p <- ggplot(frq, aes_string(x='MAF', y=paste0("AF_", opt$pop))) +
     geom_point(color='red') + 
     xlab("Allele frequencies") + 
     ylab(paste0("Allele frequencies (1KG ", opt$pop, " )")) + 
     theme_bw()

pdf(opt$out)
print(p)
dev.off()