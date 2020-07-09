# The role of mouse long noncoding RNAs

## Goal

Map mouse lncRNA regions to the homologous regions in the human genome, understand functional annotations of the corresponding human regions.

## Strategy

- Data: `data/Analysis4_up.csv` - most upregulated lncRNAs, Ensembl IDs
- Extract mm10/GRcM38 genomic coordinates of lncRNAs in BED format, [01_xlstobed.R](scripts/01_xlstobed.R)
    - Use https://github.com/stephenturner/annotables
    - Save the results in BED format, https://genome.ucsc.edu/FAQ/FAQformat.html#format1. Use "." placeholders for 'name' and 'score'. Convert 1/-1 for 'strand' to "+/-"
    - Output - `sorted.bed` file

- Extract mouse genomic sequences for the corresponding coordinates [02_bedtofasta.sh](scripts/02_bedtofasta.sh)
    - Download FASTA mouse genome, http://hgdownload.cse.ucsc.edu/goldenpath/mm10/bigZips/mm10.fa.gz 
    - Install BedTools using homebrew, use https://bedtools.readthedocs.io/en/latest/content/tools/getfasta.html to extract genomic sequences of mouse lncRNAs
    - Output - `results.fasta`

- Find best match using the BLAT tool at http://genome.ucsc.edu/cgi-bin/hgBlat?hgsid=855906545_xLt1HgMeSGZinsMVUai4xeV7IN0K&command=start
    - Download FASTA human genome, http://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/hg38.fa.gz
    - Submit `results.fasta` to BLAT [04_blat_align.sh](scripts/04_blat_align.sh)
    - Output - `blat_results.psl` and `blat_results_scored`
    - The output will have multiple matches per mouse sequence
    - Save the coordinates of all hits for each mouse sequence in BED format, considering strand
        - Tab-separated BED format: CHROM, START, END, QUERY, SCORE, STRAND, QSIZE, IDENTITY, SPAN
            - We may need columns after strand for later filtering at step 4

- Outcome 4: Annotate human genomic regions associated with mouse lncRNAs
    - Having a BED file of coordinates, use `ChIPpeakAnno` to annotate them with nearby or overlapping human transcripts, https://www.bioconductor.org/packages/release/bioc/vignettes/ChIPpeakAnno/inst/doc/pipeline.html
    - Sort the resulting data frame by multiple columns: https://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-multiple-columns
        - Max score
        - Max identity
        - Min distance
    - Save the results in separate files for each lncRNA
        - Name each file as, e.g., `01_ENSMUSG00000097709_2810429I04Rik.csv`
            - The counts are in the order of the original lncRNA file
            - The EnsemblIDs and the lncRNA names will help to identify results of interest

## Notes

- What is the length of the extracted lncRNAs?
- The number of CPUs increases memory. With 12 CPU, run fails at 80Gb of memory. Currently running on 2 CPUs.
    - Running the full `results.fasta` file fails. Splitting it into chunks of 10 FASTA records each allows for the run to be completed.
- Tested: Use --very-sensitive-local. Decrease minimum alignment score from --score-min G,20,8 to --score-min G,1,8 (http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#setting-function-options)
- Check specifications of the SAM format, http://zyxue.github.io/2017/09/26/sam-format-example.html. Important fields:
    - "FLAG" - numbers can be understood using https://broadinstitute.github.io/picard/explain-flags.html
    - "CIGAR" string, https://drive5.com/usearch/manual/cigar.html
    - "RNAME" and "POS"

- Outcome 3 (skip): Map extracted genomic sequences to hg38/GRcH38 human genome, get genomic coordinates of top matches in BED format [align.sh](align.sh)
    - Install `brew install bowtie2`. Read about bowtie2 at http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml
```
# Build index
bowtie-build2 <path to index>/hg38.fa <path to index> 
# Alignment
bowtie2 -x <path to index>/hg38 -U <fasta file> -S <output file.sam> -p <# of CPUs> --very-fast-local -k 3 --met-file <metrics_file.txt>
```
	- This command will perform alignment allowing mismatches, and report top three (-k 3) best matching for each input read
    - Each mouse read will likely map to multiple regions in the human genome. These regions can be prioritized by the alignment score. We may want to select the top best match, or top two.

