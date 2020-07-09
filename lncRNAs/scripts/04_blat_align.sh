#set up directories
DIRIN=~/Projects/lncRNA
DIRIN=/Users/mdozmorov/Documents/Work/GitHub/RNA-seq/misc/RNASeq/lncRNAs
# Genome directory
genome_dir=$DIRIN/genome_dir
mkdir -p $genome_dir
# Results directory
DIROUT=$DIRIN/data
mkdir -p $DIROUT
# Input file
FILEIN=$DIROUT/results.fasta
# Output file
FILEOUT=$DIROUT/blat_results.psl
FILEOUT2=$DIROUT/blat_results_scored

# Install blat
# https://shanguangyu.com/articles/install-blat-on-mac-with-one-liner-command/
# Install pslScore
# https://bioconda.github.io/recipes/ucsc-pslscore/README.html

# Download and unzip the target genome
wget http://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fa.gz
mv hg38.fa $genome_dir

#run blat
blat -t=dna -q=dna $genome_dir/hg38.fa $FILEIN $FILEOUT
# Run pslScore
pslScore $FILEOUT > $FILEOUT2
