# Copy Number Variation Analysis Pipeline

This repository provides scripts for copy number variation (CNV) analysis of RNASeq data. Currently, works with human genome and single-end bulk RNA-seq data.

## Part One: Installation of Dependencies

### Terminal
Install Homebrew  
`xcode-select --install`  
`ruby -e "$(curl -fsSL httgit ps://raw.githubusercontent.com/Homebrew/install/master/install)"`

Set up pyenv  
`brew install pyenv`   
`pyenv install 3.8.2`  
`pyenv global 3.8.2`  
`echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc`

Install cutadapt  
`pip install cutadapt`  

Download [fetchChromSizes](https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes), `wget https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes; chmod +x fetchChromSizes`

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

The pipeline assumes the files are downloaded in the project folder. 

Download hg38 genome sequence in FASTA format 

```
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fa.gz
```

Download hg38 gene annotation GTF file from 

```
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ensGene.gtf.gz
gunzip hg38.ensGene.gtf.gz
```

Download cytoband and centromere information   

```
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/cytoBand.txt.gz
gunzip cytoBand.txt.gz
curl -s "http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/cytoBand.txt.gz" | gunzip -c | grep acen > centromere.tab
```

## Part Three: Pipeline

### 1. Quality Control and Trimming

Run [scripts/00_genome_sort.sh](scripts/00_genome_sort.sh) to prepare the genome file with chromosomes sorted in the right order

Run [scripts/01_trim_galore.sh](scripts/01_trim_galore.sh) to remove adapters and analyze quality of RNA-seq reads

### 2. Alignment

Index the genome using [scripts/02_star_index.sh](scripts/02_star_index.sh)

Reads are aligned to UCSC reference genome using [STAR](https://github.com/alexdobin/STAR)

### 3. B-Allele Frequency Calculation

B-Allele frequencies are computed using [BAFExtract](https://github.com/akdess/BAFEXtract)

### 4. CaSpER

BAF and aligned reads are used to perform [CaSPER](https://github.com/akdess/CaSPER)

The output from STAR will have the following columns in the *ReadsPerGene.out.tab files:
V1 - genes, V2 - non-stranded, V3 - positive, V4 - negative

Select the column with the most reads to create the new dataframe `newdata`

Please refer to [CaSpER](https://rpubs.com/akdes/578955) documentation for functions to create output graphs.
