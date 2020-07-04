#!/bin/bash
#PBS -S /bin/bash
#PBS -V
#PBS -l nodes=1:ppn=1
#PBS -M mdozmorov@vcu.edu
#PBS -m abe
#PBS -N BAFExtrac
#PBS -j oe
# PBS -o /path/to/stderr-stdout/output

cd $PBS_O_WORKDIR

#Genome directory
GENOMEDIR=genome_dir

#Genome type
GENOMETYPE=hg38.fa

#Output directory
PILEUPDIR=genome_fasta_pileup

mkdir -p $PILEUPDIR

#BAFEXtract Pre-processing to create genome_fasta_pileup_dir
BAFExtract -preprocess_FASTA $GENOMEDIR/$GENOMETYPE $PILEUPDIR

#Inpute directory
DIRIN=02_aligned

#Output directory
DIROUT=03_BAFExtract

mkdir -p $DIROUT

for file in $(find $DIRIN/ -type f -name "*Aligned.out.bam")
do
	bam_file=$file;
	output_baf_file=$DIROUT"/"`basename $file _001_trimmed.fq.gzAligned.out.bam`".snp";
	samtools view $bam_file | BAFExtract -generate_compressed_pileup_per_SAM stdin $GENOMEDIR/hg38.list $DIROUT 50 0;
	BAFExtract -get_SNVs_per_pileup $GENOMEDIR/hg38.list $DIROUT $PILEUPDIR 20 4 0.1 $output_baf_file;
done