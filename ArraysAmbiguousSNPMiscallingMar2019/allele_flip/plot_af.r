library(dplyr)
library(ggplot2)
library(optparse)


# specify input parameters 
option_list = list(
  # input allele frequencies calculated using PLINK
  make_option(c("--frq"), type="character", default=NULL, 
              help="path to PLINK .frq file", metavar="character"),
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
frq <- read.delim(opt$frq, sep='', header=FALSE, as.is=TRUE, 
                  col.names=c("chr", "position", "A1", "A2", "AF_EUR", "AF_EAS", "AF_AFR", "AF"),
                  colClasses=c("character", "numeric", "character", "character", "numeric", "numeric", "numeric", "numeric"))

# plot 

p <- ggplot(frq, aes_string(x='AF', y=paste0("AF_", opt$pop))) +
     geom_point(color='red') + 
     xlab("Allele frequencies") + 
     ylab(paste0("Allele frequencies (1KG ", opt$pop, " )")) + 
     theme_bw()

pdf(opt$out)
print(p)
dev.off()