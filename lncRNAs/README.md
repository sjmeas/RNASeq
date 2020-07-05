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
- Outcome 3: Map extracted genomic sequences to hg38/GRcH38 human genome, get genomic coordinates of top matches in BED format [align.sh](align.sh)
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

