#!/bin/bash
#PBS -S /bin/bash
#PBS -V
#PBS -l nodes=1:ppn=1
#PBS -M mdozmorov@vcu.edu
#PBS -m abe
#PBS -N splitfa
#PBS -j oe
# PBS -o /path/to/stderr-stdout/output

cd $PBS_O_WORKDIR

# Input file
FILEIN=results.fasta

# https://www.biostars.org/p/13270/
awk 'BEGIN {n_seq=0;} /^>/ {if(n_seq%10==0){file=sprintf("myseq%d.fa",n_seq);} print >> file; n_seq++; next;} { print >> file; }' < $FILEIN
