#!/bin/bash
#PBS -S /bin/bash
#PBS -V
#PBS -l nodes=1:ppn=1
#PBS -M mdozmorov@vcu.edu
#PBS -m abe
#PBS -N genomesort
#PBS -j oe
# PBS -o /path/to/stderr-stdout/output

cd $PBS_O_WORKDIR

#Input directory for genome
DIRIN=`pwd`

#Output directory for sorted genome
GENOMEDIR=genome_dir

mkdir -p $GENOMEDIR

#Genome type
GENOMEFILE=hg38.fa

#Create order of chromosomes, create chr_ids.txt
echo -e "chr10 \nchr11 \nchr12 \nchr13 \nchr14 \nchr15 \nchr16 \nchr17 \nchr18 \nchr19 \nchr1 \nchr20 \nchr21 \nchr22 \nchr2 \nchr3 \nchr4 \nchr5 \nchr6 \nchr7 \nchr8 \nchr9 \nchrM \nchrX \nchrY" >> $GENOMEDIR/chr_ids.txt

#Sort genome file based on chr_ids.txt
samtools faidx $DIRIN/$GENOMEFILE $(cat $GENOMEDIR/chr_ids.txt) > $GENOMEDIR/$GENOMEFILE

#Gathering size of chromosomes, filtering out alt, random and Un
./fetchChromSizes hg38 | grep -v -E -- "random|alt|Un" > $GENOMEDIR/hg38.list

#Gene Annotation
GENEFILE=hg38.ensGene.gtf

mv $DIRIN/$GENEFILE $GENOMEDIR/