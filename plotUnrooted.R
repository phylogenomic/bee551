#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
library(ape)
print(paste("now printing an unrooted tree from",args[1],"for user:`",Sys.getenv("MYGIT"),"`... Output is in ", args[2]))
tree <- unroot(read.tree(args[1]))

pdf(args[2])
plot.phylo(tree,type="unrooted",cex=as.numeric(args[3]))
dev.off()

