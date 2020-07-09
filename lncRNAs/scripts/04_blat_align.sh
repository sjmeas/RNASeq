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
#Create order of chromosomes, create chr_ids.txt
echo -e "chr10 \nchr11 \nchr12 \nchr13 \nchr14 \nchr15 \nchr16 \nchr17 \nchr18 \nchr19 \nchr1 \nchr20 \nchr21 \nchr22 \nchr2 \nchr3 \nchr4 \nchr5 \nchr6 \nchr7 \nchr8 \nchr9 \nchrM \nchrX \nchrY" >> $genome_dir/chr_ids.txt
#Sort genome file based on chr_ids.txt (remove alt, Un, random)
samtools faidx hg38.fa $(cat $genome_dir/chr_ids.txt) > $genome_dir/hg38.fa
#mv hg38.fa $genome_dir


#run blat
blat -t=dna -q=dna $genome_dir/hg38.fa $FILEIN $FILEOUT
# Run pslScore
pslScore $FILEOUT > $FILEOUT2
