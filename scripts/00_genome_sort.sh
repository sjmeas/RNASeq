#Input directory for genome
DIRIN=pwd

#Output directory for sorted genome
DIROUT=genome_dir

mkdir -p $DIROUT

#Genome type
GENOMETYPE=hg38.fa

#Create order of chromosomes, create chr_ids.txt
echo -e "chr10 \nchr11 \nchr12 \nchr13 \nchr14 \nchr15 \nchr16 \nchr17 \nchr18 \nchr19 \nchr1 \nchr20 \nchr21 \nchr22 \nchr2 \nchr3 \nchr4 \nchr5 \nchr6 \nchr7 \nchr8 \nchr9 \nchrM \nchrX \nchrY" >> $DIROUT/chr_ids.txt

#Sort genome file based on chr_ids.txt
samtools faidx $DIRIN/$GENOMETYPE $(cat $DIROUT/chr_ids.txt) > $DIROUT/$GENOMETYPE

#Gathering size of chromosomes, filtering out alt, random and Un
fetchChromSizes hg38 | grep -v -E -- "random|alt|Un" > $DIROUT/hg38.list