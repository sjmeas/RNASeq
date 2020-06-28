#!/bin/bash
#PBS -S /bin/bash
#PBS -V
#PBS -l nodes=1:ppn=12
#PBS -M mdozmorov@vcu.edu
#PBS -m abe
#PBS -N starindex
#PBS -j oe
# PBS -o /path/to/stderr-stdout/output

cd $PBS_O_WORKDIR

#Genome Directory
GENOMEDIR=genome_dir

#Genome Type
GENOMEFILE=hg38.fa

#Gene Annotation
GENEFILE=hg38.ensGene.gtf

#Number of logical processors - 1
CORES=12 # Should match the `ppn` PBS setting

STAR --runThreadN $CORES --runMode genomeGenerate --genomeDir $GENOMEDIR  --genomeFastaFiles $GENOMEDIR/$GENOMEFILE --sjdbGTFfile $GENOMEDIR/$GENEFILE
