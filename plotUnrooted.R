#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
library(ape)
print(paste("now printing an unrooted tree from",args[1],"for user:`",Sys.getenv("MYGIT"),"`... Output is in ", args[2]))
tree <- unroot(read.tree(args[1]))
fsize <- 0.4
if(!(is.na((as.numeric(args[3])>0)))){fsize <- as.numeric(args[3])}
pdf(args[2])
plot.phylo(tree,type="unrooted",cex=fsize)
dev.off()
