# The role of mouse long noncoding RNAs

## Goal

Map mouse lncRNA regions to the homologous regions in the human genome, understand functional annotations of the corresponding human regions.

## Strategy

- Data: `data/Analysis4_up.csv` - most upregulated lncRNAs, Ensembl IDs
- Outcome 1: Extract mm10/GRcM38 genomic coordinates of lncRNAs in BED format
    - Use https://github.com/stephenturner/annotables
    - Save the results in BED format, https://genome.ucsc.edu/FAQ/FAQformat.html#format1. Use "." placeholders for 'name' and 'score'. Convert 1/-1 for 'strand' to "+/-"
- Outcome 2: Extract mouse genomic sequences for the corresponding coordinates
    - Download FASTA mouse genome, http://hgdownload.cse.ucsc.edu/goldenpath/mm10/bigZips/, mm10.fa.gz 
    - Install BedTools using homebrew, use https://bedtools.readthedocs.io/en/latest/content/tools/getfasta.html to extract genomic sequences of mouse lncRNAs
- Outcome 3: Map extracted genomic sequences to hg38/GRcH38 human genome, get genomic coordinates of top matches in BED format
    - The critical part - need to scrutinize each setting of the STAR aligner to select the most appropriate. Mostly for me, but make sure to understand why and correct, if needed.
    - Ideally, we want a perfect match between the mouse sequence and the human sequence. It will rarely be the case, as there will be point mismatches, insertions, or deletions. Thus, we need to make educated guesses how much wiggle room to allow for the alignment.
    - Each mouse read will likely map to multiple regions in the human genome. These regions can be prioritized by the alignment score. We may want to select the top best match, or top two.
- Outcome 4: Annotate human genomic regions associated with mouse lncRNAs
    - Having a BED file of coordinates, use `ChIPpeakAnno` to annotate them with nearby or overlapping human transcripts, https://www.bioconductor.org/packages/release/bioc/vignettes/ChIPpeakAnno/inst/doc/pipeline.html
    - Also, use http://bioconductor.org/packages/release/bioc/html/LOLA.html to characterize functional enrichments. The web version also can be used http://lolaweb.databio.org/
