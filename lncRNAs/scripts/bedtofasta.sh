#need to convert sorted.bed to UNIX format (https://groups.google.com/g/bedtools-discuss/c/Uzs1y5H70EY)
dos2unix sorted.bed 

#add # to column names
echo -e "#$(cat sorted.bed)" > sorted.bed

#set up directories
genome_dir=~/Projects/lncRNA/genome_dir
DIRIN=~/Projects/lncRNA
DIROUT=~/Projects/lncRNA/01_bedtools
mkdir 01_bedtools

#run bedtools
bedtools getfasta -fi $genome_dir/mm10.fa -bed $DIRIN/sorted.bed -fo $DIROUT/results