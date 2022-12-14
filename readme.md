# Phylogeny Lab
[Piacentini and Ramírez](https://pubmed.ncbi.nlm.nih.gov/30953780/) studied the phylogeny of species in the family Lycosidae. They also included representatives from closely related families Trechaleidae and Pisauridae. They studied 5 genes; we will look only at 28S today.  

## Lab Objective
The objective of the lab is to replicate part of the phylogenetic reconstruction from [Piacentini and Ramírez](https://pubmed.ncbi.nlm.nih.gov/30953780/). This will demonstrate the following aspects: gene alignment, model selection, tree building, bootstrap analysis, rooted vs. unrooted trees.  
During the lab, please answer the questions that are posed and turn these in, along with your trees, for credit. 

## Get logged in to one of the instances set up for this lab on AWS: 
Instance1: ssh root@3.211.209.68  
Instance2: ssh root@3.228.114.165  
Instance3: ssh root@3.94.175.88  
Instance4: ssh root@3.95.116.238  
Passwords: bio_312_2022  

Then login again:  
```
ssh ec2-user@localhost  
```
password: bee551

### once you are in, get set up
put your name in here! (oneword)
```bash
mkdir yourname 
cd yourname
```

## Obtain 28S sequences
Now, let's download the 28S accessions from Table 2.
They are available in the file "geneids.txt" as part of this repository. 

To download this file to your instance:   
```
wget https://raw.githubusercontent.com/phylogenomic/bee551/main/geneids.txt
```

Question: What is 28S? Why is it appropriate to use for phylogenetics of species?  


Then Make a directory to store the sequences  
```bash
mkdir seqs
cd seqs
```
In that script:
```bash!
cat ../geneids.txt | xargs -n1 ncbi-acc-download --format fasta | read -t 0.5
```
Put these all into one file
```bash!
cat *.fa > ../wolf28s.fas
```
Replace spaces with underscores:  
```bash!
cd ../
sed -i 's/ /_/g' wolf28s.fas
```

### If you had trouble downloading the sequences directly from NCBI, you can skip the above steps, and download the mutli-fasta file here:
```bash
wget -O https://raw.githubusercontent.com/phylogenomic/bee551/main/wolf28s.fas
```
## Sequence alignment and alignment evaluation
Align these sequences with muscle
```bash!
muscle -in wolf28s.fas -out wolf28s.al.fas
```
Look at the aligment:
```bash
alv -kli --majority wolf28s.al.fas | less -RS
```
Try this with and without the --majority option. What is the difference?  
What do you observe about the alignment?  

### What is the width of the aligment?
```bash!
alignbuddy  -al  wolf28s.al.fas
```

Here is how to calculate the length of the alignment after removing any column with gaps:
```bash
alignbuddy -trm all  wolf28s.al.fas | alignbuddy  -al
```
How many columns in the alignment contain gaps?  

Here is how to calculate the length of the alignment after removing invariant (completely conserved) positions:
```
alignbuddy -dinv 'ambig' wolf28s.al.fas | alignbuddy  -al
```
How many columns in the alignment are invariant?  

### Calculate the average percent identity
Calculate the average percent identity among all sequences in the alignment using t_coffee,which excludes gapped positions from the denominator.
```bash!
t_coffee -other_pg seq_reformat -in wolf28s.al.fas -output sim
```

What is the average percent identity among all sequences according to t_coffee?  
Hint: this is a number on the last line of the output on the line that contains "TOT TOT".  

Repat calculating the average percent identity using alignbuddy, which includes gapped positions in the denominator.
```bash
 alignbuddy -pi wolf28s.al.fas | awk ' (NR>2)  { for (i=2;i<=NF  ;i++){ sum+=$i;num++} } END{ print(100*sum/num) } '
```

What is the average percent identity according to alignbuddy?  

## Maximum likelihood phylogeny inference
Use IQ-TREE to find the maximum likehood tree estimate. First, it will calculate the optimal substitution model (we will tell it to use a model: GTR+F+I to save time) and nucleotide frequencies. Then, it will perform a tree search, estimating branch lengths as it goes.  
(Simultaneously, we are going to have IQ-TREE estimate ultrafast bootstrap support levels using the flag -bb 1000. We'll talk more about this later.)  

Please review the tutorial: http://www.iqtree.org/doc/Tutorial  
Rather than evaluating different models, we will specify the model. This will help us to save time.  
What is the GTR+F+I model? (See http://www.iqtree.org/doc/Substitution-Models )  

```bash
iqtree -s wolf28s.al.fas -bb 1000 -nt 1 -m GTR+F+I
```
Are there any identical sequences? What are they?  
How many sites are parsimony-informative?  
How many sites contain singletons?   
How many sites are constant?  

What is the log likelihood of the optimal tree that IQ-TREE found? 
Hints: look at the output on your screen for "BEST SCORE FOUND" or in the file   wolf28s.al.fas.iqtree file for "Log-likelihood of the tree:".  

Look under the section State frequencies: (empirical counts from alignment) to answer the following two questions.  
What is the least nucloetide in the alignment?  
What is the most frequent nucleotide in the alignment?  

## Rooted vs. unrooted trees
### Look at the unrooted tree
The .iqtree file includes an ASCII graphics (text graphics) version of the tree. You can also display it by reading the .treefile (which is newick formatted) into the nw_display program:
```bash
nw_display wolf28s.al.fas.treefile
```
But, note the important warning in the IQTREE file:  
NOTE: Tree is UNROOTED although outgroup taxon ... is drawn at root  
(This is actually a basal polytomy, which is a way to say "I'm unrooted".)  

So, this is an unrooted tree, but it is being shown with an arbitrary root.  

So, let's look at it unrooted. nw_display can't do this, so... Let's use an R script . Because there are so many genes, we will make the size of the text labels smaller (0.4).  
```bash
wget https://raw.githubusercontent.com/phylogenomic/bee551/main/plotUnrooted.R
Rscript --vanilla plotUnrooted.R  wolf28s.al.fas.treefile wolf28s.al.fas.treefile.unrooted.pdf 0.3
```
To get the file, use sftp. From ANOTHER terminal window on YOUR computer.
Change the IP to that of the instance you are using. For example:
```
first, find out where you are on YOUR computer: pwd  

Instance1: sftp root@3.211.209.68  
Instance2: sftp root@3.228.114.165  
Instance3: sftp root@3.94.175.88  
Instance4: sftp root@3.95.116.238  
Passwords: bio_312_2022  

cd /home/ec2-user/yourname
(or cd /home/ec2-user/yourname/seqs if that is where you are)
get wolf28s.al.fas.treefile.unrooted.pdf
```
replace yourname as appropriate.  
Now, you will be able to find the file wolf28s.al.fas.treefile.unrooted.pdf on your own computers.  

### Midpoint rooting
We will use a type of rooting called midpoint - we'll hope that the root is halfway along the longest branch on the tree. (Note: this may not be true, in which case the root will be wrong.)  
We will use the software gotree to reroot the tree.  

-i specifies your input file  
-o specifies your output file  
Here is the command:  
```bash
gotree reroot midpoint -i wolf28s.al.fas.treefile -o wolf28s.al.fas.midpoint.treefile
```
Now, we can look at the rooted tree at the command line:
```
nw_order -c n wolf28s.al.fas.treefile  | nw_display -
```
Also, output it as a graphic:
```
nw_order -c n wolf28s.al.fas.midpoint.treefile | nw_display -w 1000 -b 'opacity:0' -s  >  wolf28s.al.fas.midpoint.treefile.svg -
```
Use the command for sftp above to grab it.


### Branch lengths  
The tree shown by default in nw_display (and most other programs) is a phylogram. This means that the lengths of each branch are proportional to the number of substitutions that have accumulated in the sequence along that branch.  

If there are very short branch lengths, clades can be hard to visualize on a phylogram. Try switching the view to a cladogram, using the following command:
```bash
nw_order -c n wolf28s.al.fas.midpoint.treefile | nw_topology - | nw_display -s  -w 1000 > wolf28s.al.fas.midpointCL.treefile.svg  -
```

## Summary Questions 
* How does your tree compare to the tree in Piacentini and Ramírez?
* Which nodes are well supported? Which are not?
* What is different about our methods and their methods?


