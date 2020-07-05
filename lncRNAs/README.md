# The role of mouse long noncoding RNAs

## Goal

Map mouse lncRNA regions to the homologous regions in the human genome, understand functional annotations of the corresponding human regions.

## Strategy

- Data: `data/Analysis4_up.csv` - most upregulated lncRNAs, Ensembl IDs
- Outcome 1: Extract mm10/GRcM38 genomic coordinates of lncRNAs in BED format, [xlstobed.R](xlstobed.R)
    - Use https://github.com/stephenturner/annotables
    - Save the results in BED format, https://genome.ucsc.edu/FAQ/FAQformat.html#format1. Use "." placeholders for 'name' and 'score'. Convert 1/-1 for 'strand' to "+/-"
- Outcome 2: Extract mouse genomic sequences for the corresponding coordinates [bedtofasta.sh](bedtofasta.sh)
    - Download FASTA mouse genome, http://hgdownload.cse.ucsc.edu/goldenpath/mm10/bigZips/, mm10.fa.gz 
    - Install BedTools using homebrew, use https://bedtools.readthedocs.io/en/latest/content/tools/getfasta.html to extract genomic sequences of mouse lncRNAs
- Outcome 3 (simplified): Find best match using the BLAT tool at http://genome.ucsc.edu/cgi-bin/hgBlat?hgsid=855906545_xLt1HgMeSGZinsMVUai4xeV7IN0K&command=start
    - Split the original FASTA file into a series of small (10 sequences each) FASTA files [00_split_fa.sh](00_split_fa.sh)
    - Submit each file to BLAT, with the default settings for hg38
    - Save output into a text file
    - The output will have multiple matches per mouse sequence
    - Save the coordinates of top hits for each mouse sequence in BED format, considering strand
        - Tentative algorithm:
            - Filter out matches to non-canonical chromosomes
            - Select top 10 matches, keeping the order (BLAT guesses are most accurate)
                - Also, save just top hits, one hit per sequence. This is the starting point for step 4
        - Tab-separated BED format: CHROM, START, END, QUERY, SCORE, STRAND, QSIZE, IDENTITY, SPAN
            - We may need columns after strand for later filtering at step 4

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
- Outcome 4: Annotate human genomic regions associated with mouse lncRNAs
    - Having a BED file of coordinates, use `ChIPpeakAnno` to annotate them with nearby or overlapping human transcripts, https://www.bioconductor.org/packages/release/bioc/vignettes/ChIPpeakAnno/inst/doc/pipeline.html
    - Also, use http://bioconductor.org/packages/release/bioc/html/LOLA.html to characterize functional enrichments. The web version also can be used http://lolaweb.databio.org/

## Notes

- What is the length of the extracted lncRNAs?
- The number of CPUs increases memory. With 12 CPU, run fails at 80Gb of memory. Currently running on 2 CPUs.
    - Running the full `results.fasta` file fails. Splitting it into chunks of 10 FASTA records each allows for the run to be completed.
- Tested: Use --very-sensitive-local. Decrease minimum alignment score from --score-min G,20,8 to --score-min G,1,8 (http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#setting-function-options)
- Check specifications of the SAM format, http://zyxue.github.io/2017/09/26/sam-format-example.html. Important fields:
    - "FLAG" - numbers can be understood using https://broadinstitute.github.io/picard/explain-flags.html
    - "CIGAR" string, https://drive5.com/usearch/manual/cigar.html
    - "RNAME" and "POS"
