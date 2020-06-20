#Input directory for genome
DIRIN=pwd

#Output directory for sorted genome
DIROUT=genome_dir

mkdir -p $DIROUT

#Genome type
GENOMETYPE=hg38.fa

#Create order of chromosomes, create chr_ids.txt
echo -e "10 \n11 \n12 \n13 \n14 \n15 \n16 \n17 \n18 \n19 \n1 \n20 \n21 \n22 \n2 \n3 \n4 \n5 \n6 \n7 \n8 \n9 \nM \nX \nY" >> $DIROUR/chr_ids.txt

#Sort genome file based on chr_ids.txt
samtools faidx $DIRIN/$GENOME $(cat chr_ids.txt) > #DIROUT/$GENOME

#Gathering size of chromosomes, filtering out alt, random and Un
fetchChromSizes hg38 | grep -v -E -- "random|alt|Un" > $DIROUT/hg38.list