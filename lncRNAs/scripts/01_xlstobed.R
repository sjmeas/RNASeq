library(annotables)
library(dplyr)
library(tibble)

#reading file
data <- read.csv("D:/Users/steve/Documents/Projects/RNASeq/lncRNAs/data/Analysis4_up.csv")


#create function to detect genes using annotables and create BED output
sort_data <- function(data){
	data %>% 
	inner_join(grcm38, by = c("genes" = "ensgene")) %>% 
	select (chr, start, end, strand) %>%
	#changing strand variable from +1/-1 to +/-
	mutate(strand = replace(strand, strand == "1", "+")) %>%
    mutate(strand = replace(strand, strand == "-1", "-")) %>%
    #adding name and score placeholder columns
    add_column(name = ".", .after = "end") %>%
    add_column(score = ".", .after = "name") %>%
    rename (chrom = chr) %>%
    rename (chromStart = start) %>%
    rename (chromEnd = end) %>%
    #append "chr" to chromosome number (e.g. "7" to "chr7")
    mutate(chrom = paste0("chr",chrom))
}

#making subset
newdata <- sort_data(data=data)
write.table(newdata, "sorted.bed", row.names=FALSE,sep="\t", quote = FALSE)
