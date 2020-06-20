#Genome directory
GENOMEDIR=genome_dir

#Genome type
GENOMETYPE=hg38.fa

#Output directory
PILEUPDIR=genome_fasta_pileup


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
	samtools view $bam_file | BAFExtract -generate_compressed_pileup_per_SAM stdin $GENOMDIR/hg38.list $DIROUT 50 0;
	BAFExtract -get_SNVs_per_pileup $GENOMEDIR/hg38.list $DIROUT $PILEUPDIR 20 4 0.1 $output_baf_file;
done
