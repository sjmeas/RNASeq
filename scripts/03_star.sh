#!/bin/bash
#PBS -S /bin/bash
#PBS -V
#PBS -l nodes=1:ppn=12
#PBS -M mdozmorov@vcu.edu
#PBS -m abe
#PBS -N staralign
#PBS -j oe
# PBS -o /path/to/stderr-stdout/output

cd $PBS_O_WORKDIR
#Input directory
DIRIN=01_trimmed

#Output directory
DIROUT=02_aligned

mkdir -p $DIROUT

#Number of logical processors - 1
CORES=12 # Should match the `ppn` PBS setting

#Genome directory
GENOMEDIR=genome_dir

for file in $(find ./$DIRIN -name "*.fq.gz" -type f | sed s~$DIRIN/~~)
do
	output_file=`basename $file _trimmed.fq.gz`;
	STAR --runThreadN $CORES --genomeDir $GENOMEDIR --readFilesIn $DIRIN/$file --readFilesCommand zcat --outSAMtype BAM Unsorted --outReadsUnmapped Fastx --quantMode GeneCounts --outFilterMultimapNmax 10 --outFileNamePrefix $DIROUT/$output_file
done
