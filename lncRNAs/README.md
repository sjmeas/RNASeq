# The role of mouse long noncoding RNAs

## Goal

Map mouse lncRNA regions to the homologous regions in the human genome, understand functional annotations of the corresponding human regions.

## Strategy

- Data: `data/Analysis4_up.csv` - most upregulated lncRNAs, Ensembl IDs
- [01_xlstobed.R](scripts/01_xlstobed.R) - Extract mm10/GRcM38 genomic coordinates of lncRNAs in BED format
    - Use https://github.com/stephenturner/annotables
    - Save the results in BED format, https://genome.ucsc.edu/FAQ/FAQformat.html#format1. Use "." placeholders for 'name' and 'score'. Convert 1/-1 for 'strand' to "+/-"
    - Output - `sorted.bed` file

- [02_bedtofasta.sh](scripts/02_bedtofasta.sh) - Extract mouse genomic sequences for the corresponding coordinates 
    - Download FASTA mouse genome, http://hgdownload.cse.ucsc.edu/goldenpath/mm10/bigZips/mm10.fa.gz 
    - Install BedTools using homebrew, use https://bedtools.readthedocs.io/en/latest/content/tools/getfasta.html to extract genomic sequences of mouse lncRNAs
    - Output - `results.fasta`

- [04_blat_align.sh](scripts/04_blat_align.sh) - Find best match using BLAT     
    - Download FASTA human genome, http://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/hg38.fa.gz
    - Install miniconda, https://docs.conda.io/projects/conda/en/latest/user-guide/install/macos.html
    - Activate the environment `conda create --name blat`
    - Install blat, https://shanguangyu.com/articles/install-blat-on-mac-with-one-liner-command/
    - Install pslScore, https://bioconda.github.io/recipes/ucsc-pslscore/README.html
    - Output - `blat_results.psl` and `blat_results_scored`

- [05_sorting.R](scripts/05_sorting.R) Annotate human genomic regions associated with mouse lncRNAs
    - Having a BED file of coordinates, use `ChIPpeakAnno` to annotate them with nearby or overlapping human transcripts, https://www.bioconductor.org/packages/release/bioc/vignettes/ChIPpeakAnno/inst/doc/pipeline.html
    - Sort the resulting data frame by multiple columns: https://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-multiple-columns
        - Max score
        - Max identity
        - Min distance
    - Save the results in separate files for each lncRNA
        - Name each file as, e.g., `001_ENSMUSG00000097709_2810429I04Rik.csv`
            - The counts are in the order of the original lncRNA file
            - The EnsemblIDs and the lncRNA names will help to identify results of interest
    - Legend: Each folder is named after the analysis. Annotations for each lncRNA are stored in individual files because one lncRNA can have multiple matches in the target genome. Files are named as `001_ENSMUSG00000097709_2810429I04Rik.csv` - numbers are in the order of highest differential expression, Ensembl IDs and symbols are to recognize a lncRNA. Columns include 1) differential expression section, 2) genomic coordinates of the lncRNA and the corresponding matches, "alignment.score" - overall alignment quality, higher the better, "identity" - percent identity to the target genome, higher the better, 3) annotation block, "distance" - closest distance to the feature, "insideFeature" - where the alignment is located, "gene_name" - name of the closest transcript. Each lncRNA-specific data is sorted by largest "alignment.score", then by largest "identity", then by smallest "distance". The rationale is to prioritize best and closest alignments. 



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

