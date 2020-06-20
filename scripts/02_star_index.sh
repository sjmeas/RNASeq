#Genome Directory
GENOMEDIR=genome_dir

#Genome Type
GENOMETYPE=hg38.fa

#Number of logical processors - 1
CORES=7

STAR --runThreadN $CORES --runMode genomeGenerate --genomeDir $GENOMEDIR  --genomeFastaFiles $GENOMEDIR/$GENOMETYPE --sjdbGTFfile $FGENOMEDIR/hg38.ensGene.gtf