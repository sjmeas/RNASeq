#!/bin/bash
#PBS -S /bin/bash
#PBS -V
#PBS -l nodes=1:ppn=12
#PBS -M mdozmorov@vcu.edu
#PBS -m abe
#PBS -N trimgalore
#PBS -j oe
# PBS -o /path/to/stderr-stdout/output

cd $PBS_O_WORKDIR

#Input directory
DIRIN=00_raw_merged

#Output directory
DIROUT=01_trimmed

mkdir -p $DIROUT

#For loop to performing trim_galore on all fastq.gz files in current directory
for file in `find $DIRIN -name "*.fastq.gz" -type f | sort`; do
	trim_galore $file --fastqc -o $DIROUT/ --cores 12
done
