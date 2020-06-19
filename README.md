# Copy Number Variation Analysis Pipeline

This repository provides scripts for a copy number variation (CNV) of RNASeq data.

## 1. Quality Control and Trimming

Reads are processed by `<trim_galore>` to remove adapters and analyze quality

## 2. Alignment

Reads are aligned to UCSC reference genome using [STAR](https://github.com/alexdobin/STAR)

## 3. B-Allele Frequency Calculation

B-Allele frequencies are computed using [BAFExtract](https://github.com/akdess/BAFEXtract)

## 4. CaSpER

BAF and aligned reads are used to perform [CaSPER](https://github.com/akdess/CaSPER)
