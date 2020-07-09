#bowtie build index
bowtie2-build -f --threads 7 ~/Projects/RNASeq/genome_dir/hg38.fa hg38

#bowtie run alignment
bowtie2 -f -x hg38 -U ~/Projects/lncRNA/01_bedtools/results.fasta -S ~/Projects/lncRNA/02_aligned/aligned

#with multiple threads
bowtie2 -f --threads 7 -x hg38 -U ~/Projects/lncRNA/01_bedtools/results.fasta -S ~/Projects/lncRNA/02_aligned/aligned