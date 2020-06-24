#Input directory
DIRIN=01_trimmed

#Output directory
DIROUT=02_aligned

mkdir -p $DIROUT

#Genome directory
GENOMEDIR=genome_dir

for file in $(find ./$DIRIN -name "*.fq.gz" -type f | sed s~$DIRIN/~~)
do
	output_file=`basename $file _trimmed.fq.gz`;
	STAR --genomeDir $GENOMEDIR --readFilesIn $DIRIN/$file --readFilesCommand zcat --outSAMtype BAM Unsorted --outReadsUnmapped Fastx --quantMode GeneCounts --outFilterMultimapNmax 10 --outFileNamePrefix $DIROUT/$output_file
done