#Copy Number Variation Analysis Pipeline

This repository provides scripts for a copy number variation (CNV) of RNASeq data.

## Part One: Installation of Dependencies

### Terminal
Install Homebrew  
`xcode-select --install`  
`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

Set up pyenv  
`brew install pyenv`   
`pyenv install 3.8.2`  
`pyenv global 3.8.2`  
`echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc`

Install cutadapt  
`pip install cutadapt`  

Download [trim_galore](https://github.com/FelixKrueger/TrimGalore/releases)  
`chmod +x trim_galore`  
`ln -s /path/to/trim_galore /usr/local/bin/trim_galore`  

Download [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/download.html#fastqc) (Make sure to select .zip even on macOS)  
`chmod +x fastqc`  
`ln -s /path/to/fastqc /usr/local/bin/fastqc`  

Download [STAR](https://github.com/alexdobin/STAR/releases)  
`chmod +x STAR`  
`ln -s /path/to/STAR /usr/local/bin/STAR`  

Download [BAFExtract](https://github.com/akdess/BAFExtract.git)  
`make BAFExtract`  
`chmod +x BAFExtract`  
`ln -s /path/to/BAFExtract /usr/local/bin/BAFExtract`  

Download [samtools](http://www.htslib.org/)  
`make`  
`make install`  
`chmod +x samtools`  
`ln -s /path/to/samtools /usr/local/bin/samtools`

### R
Download and install [R](https://cloud.r-project.org/)

Download and install [RStudio](https://rstudio.com/products/rstudio/)

Update BioCManager  

```
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install()
```

Install CaSpER dependencies  
`BiocManager::install(c('HMMcopy', 'GenomeGraphs', 'biomaRt', 'limma', 'GO.db', 'org.Hs.eg.db', 'GOstats'))`  

Install devtools
`install.packages("devtools")`  

Windows users will need to download and install [Rtools](https://cran.r-project.org/bin/windows/Rtools/)

Install CaSpER  
```
require(devtools)
install_github("akdess/CaSpER")
````

## Part Two: Download Genome Files

Download hg38 genome sequence in FASTA format https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips

Download hg38 gene annotation GTF file
– ensGene from https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/

Download cytoband information from http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/cytoBand.txt.gz

Download centromere information   
`curl -s "http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/cytoBand.txt.gz" | gunzip -c | grep acen > centromere.tab`
Copy to project directory

## Part Three: Pipeline

### 1. Quality Control and Trimming

Reads are processed by `<trim_galore>` to remove adapters and analyze quality

### 2. Alignment

Reads are aligned to UCSC reference genome using [STAR](https://github.com/alexdobin/STAR)

### 3. B-Allele Frequency Calculation

B-Allele frequencies are computed using [BAFExtract](https://github.com/akdess/BAFEXtract)

### 4. CaSpER

BAF and aligned reads are used to perform [CaSPER](https://github.com/akdess/CaSPER)

The output from STAR will have the following columns in the *ReadsPerGene.out.tab files:
V1 - genes, V2 - non-stranded, V3 - positive, V4 - negative

Select the column with the most reads to create the new dataframe `newdata`

Please refer to [CaSpER](https://rpubs.com/akdes/578955) documentation for functions to create output graphs.
