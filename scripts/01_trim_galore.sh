#Input directory
DIRIN=00_raw

#Output directory
DIROUT=01_trimmed

mkdir -p $DIROUT

#For loop to performing trim_galore on all fastq.gz files in current directory
for file in `find $DIRIN -name "*.fastq.gz" -type f | sort`; do
	trim_galore $file --fastqc -o $DIROUT/
done