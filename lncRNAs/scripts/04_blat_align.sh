#genome file that queries are matched to
GENOME=~/Projects/RNASeq/genome_dir/hg38.fa

#list of query files in fasta format
ls . | grep "myseq" > sequence.list 

#run blat
blat ~/Projects/RNASeq/genome_dir/hg38.fa sequence.list blat_results.psl

#calculate scores
pslScore blat_results.psl > blat_results_scored