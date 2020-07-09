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
FILEIN=$DIROUT/sorted.bed
# Output file
FILEOUT=$DIROUT/results.fasta

# Download and unzip the sour genome
wget http://hgdownload.cse.ucsc.edu/goldenpath/mm10/bigZips/mm10.fa.gz
gunzip mm10.fa.gz
mv mm10.fa $genome_dir

#need to convert sorted.bed to UNIX format (https://groups.google.com/g/bedtools-discuss/c/Uzs1y5H70EY)
dos2unix $FILEIN 

#add # to column names
echo -e "#$(cat $FILEIN)" > $FILEIN

#run bedtools
bedtools getfasta -fi $genome_dir/mm10.fa -bed $FILEIN -fo $FILEOUT
