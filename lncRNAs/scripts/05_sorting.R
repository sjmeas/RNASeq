# Settings
# data_dir <- "D:/Users/steve/Documents/Projects/RNASeq/lncRNAs/data" # Steve
data_dir <- "/Users/mdozmorov/Documents/Work/GitHub/RNA-seq/misc/RNASeq/lncRNAs/data" # Mikhail
fileNameIn1 <- file.path(data_dir, "Analysis4_dn.csv")
fileNameIn2 <- file.path(data_dir, "blat_results.psl")
fileNameIn3 <- file.path(data_dir, "blat_results_scored")
fileNameIn4 <- file.path(data_dir, "sorted.bed")
dirOut1 <- file.path(data_dir, "Analysis4_dn")

#read blat data
scored <- read.table(fileNameIn3)
unscored <- read.table(fileNameIn2, skip = 5, sep = "\t")
# Clean up unplaced contigs
unplaced <- "chrUn|_alt|_random|KI|chrM"
scored <- scored[!grepl(unplaced, scored$V1, perl = TRUE), ]
unscored <- unscored[!grepl(unplaced, unscored$V14, perl = TRUE), ]
# data <- read.csv("D:/Users/steve/Documents/Projects/RNASeq/lncRNAs/data/Analysis4_up.csv")
data <- read.csv(fileNameIn1)
newdata <- read.table(fileNameIn4, sep = "\t", header = F)
colnames(newdata) <- c("chrom",	"chromStart",	"chromEnd",	"name",	"score",	"strand")

#add unique mm10 query identifier to each match
newscored <- scored
newscored$V7 <- unscored$V10

#create list of identifiers from original data
chrom.list <- list()

for (i in 1:dim(newdata)[1]) {
  identifier <- paste0(newdata$chrom[i],":",newdata$chromStart[i],"-",newdata$chromEnd[i])
  chrom.list[[i]] <- identifier
}

newdata$V7 <- unlist(chrom.list)

#match identifiers in sorted data and original data, add gene name to sorted data
for (i in 1:dim(newscored)[1]) {
  index <- match(newscored$V7[i], newdata$V7)
  newscored$V8[i] <- data$genes[index]
}

#create list of dataframes containing each individual original mouse gene
all_names <- list()

for (i in 1:dim(data)[1]) {
  indexes <- which(newscored$V8 %in% data$genes[i])
  data.by.gene <- newscored[indexes,]
  all_names <- c(all_names,list(data.by.gene))
}

names(all_names) <- data$genes

#make unique identifier for unscored
newunscored <- unscored

for (i in 1:dim(unscored)[1]) {
  newunscored$V22[i] <- paste0(unscored$V14[i], unscored$V16[i], unscored$V17[i])
}

#make unique identifier for scored data to match unscored
for (i in 1:dim(data)[1]) {
  var <- data$genes[i]
  if (dim(all_names[[var]])[1] > 0){
    for (k in 1:dim(all_names[[var]])[1]) {
      all_names[[var]]$V9[k] <- paste0(all_names[[var]][["V1"]][k], all_names[[var]][["V2"]][k], all_names[[var]][["V3"]][k]) 
      #add strandedness based on unique identifier
      index <- match(all_names[[var]]$V9[k], newunscored$V22)
      all_names[[var]]$V10[k] <- newunscored$V9[index]
    }
  } else {
    all_names[which(names(all_names) %in% var)] <- NULL
  }	
}

#create bed format from blat_results_scored for ChIPpeakAnno
library(ChIPpeakAnno)
library(dplyr)
library(annotables)
library(tibble)
library(EnsDb.Hsapiens.v86)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(org.Hs.eg.db)
#prepare annotation data
annoData <- toGRanges(EnsDb.Hsapiens.v86, feature="gene")

annotated_list <- list()
#run ChIPpeakAnno
for (i in 1:length(all_names)){
  tryCatch({
    var <- names(all_names)[i]
    bed <- all_names[[var]][,c("V1","V2","V3", "V10")] %>%
      dplyr::rename (space = V1) %>%
      dplyr::rename (start = V2) %>%
      dplyr::rename (end = V3) %>%
      dplyr::rename (strand = V10) %>%
      add_column(name = seq(1:dim(all_names[[var]])[1]), .after = "end") %>%
      add_column(score = "0", .after = "name")
    
    #establish index of human sequences not found
    gr1 <- toGRanges(bed, format="BED", header=TRUE)

    overlaps.anno <- annoPeaks(gr1, 
                               annoData=annoData, 
                               output="nearestBiDirectionalPromoters",
                               bindingRegion=c(-5000, 5000))
    overlaps.anno <- addGeneIDs(overlaps.anno,
                                "org.Hs.eg.db",
                                IDs2Add = "entrez_id")
    #write files for each annoData entry
    # write.csv(as.data.frame(unname(overlaps.anno)), file = file.path(dirOut1, paste0(var,"_annoData.csv")))
    #create list of data frames from annoData entries
    annotated_list <- c(annotated_list,list(as.data.frame(unname(overlaps.anno))))
    names(annotated_list)[length(annotated_list)] <- var
  }, error=function(e){})
}

#making unique identifiers for newscored
for (i in 1:dim(newscored)[1]) {
  newscored$V9[i] <- paste0(newscored$V1[i], substr(newscored$V2[i], 1, nchar(newscored$V2[i]) - 3), substr(newscored$V3[i], 1, nchar(newscored$V3[i]) - 3))
}

#adding score and identity back from newscored/all_names into annoData
for (i in 1:length(annotated_list)){
  gene_name <- names(annotated_list)[i]
  for (k in 1:dim(annotated_list[[1]])[1]) {
    annotated_list[[i]][k,"V18"] <- paste0(annotated_list[[i]][k,1], substr(annotated_list[[i]][k,2], 1, nchar(annotated_list[[i]][k,2]) - 3), substr(annotated_list[[i]][k,3], 1, nchar(annotated_list[[i]][k,3]) - 3))
    location_in_list <- match(gene_name, names(all_names))
    index <- match(annotated_list[[i]][k,"V18"], all_names[[location_in_list]]$V9)
    annotated_list[[i]][k,c("score", "identity")] <- all_names[[location_in_list]][index, c("V5","V6")]
  }
}

#adding score and identity back from newscored into annoData
for (i in 1:length(annotated_list)){
  gene_name <- names(annotated_list)[i]
  for (k in 1:dim(annotated_list[[i]])[1]) {
    annotated_list[[i]][k,"V18"] <- paste0(annotated_list[[i]][k,1], substr(annotated_list[[i]][k,2], 1, nchar(annotated_list[[i]][k,2]) - 3), substr(annotated_list[[i]][k,3], 1, nchar(annotated_list[[i]][k,3]) - 3))
    location_in_list <- match(gene_name, names(all_names))
    index <- match(annotated_list[[i]][k,"V18"], newscored$V9)
    annotated_list[[i]][k,c("score", "identity")] <- newscored[index, c("V5","V6")]
  }
  
}

#joining the compiled list
#create directory for results
unlink(dirOut1, recursive = TRUE)
dir.create(dirOut1)

for (i in 1:length(data$genes)){
  var <- data$genes[i]
  index <- match(var,names(annotated_list))
  symbol <- data$symbol[i]
  #only genes that are present in annotated_list are processed
  if (!is.na(index)){
    annoData_df <- annotated_list[[index]]
    rows <- data[i,]
    #duplicate the original analysis4_up data for the number of entries retrieved from annoData
    analysis <- rbind(rows, rows[rep(1, dim(annoData_df)[1] - 1),])
    #add in annoData by columns
    analysis[1:dim(annoData_df)[1],c("mm10_chr", "mm10_start", "mm10_end","mm10_strand")] <- newdata[i,c("chrom","chromStart","chromEnd", "strand")]
    analysis[,c("hg38_chr", "hg38_start", "hg38_end", "hg38_strand", "alignment.score", "feature", "feature.ranges.start", "feature.ranges.end", "feature.ranges.width", "feature.strand", "distance", "insideFeature", "distanceToSite", "gene_name", "entrez_id")] <- annoData_df[,c("seqnames","start","end", "strand", "score", "feature", "feature.ranges.start", "feature.ranges.end", "feature.ranges.width", "feature.strand", "distance", "insideFeature", "distanceToSite", "gene_name", "entrez_id")]
    analysis <- analysis %>%
      add_column(identity  = annoData_df[,"identity"], .after = "alignment.score") 
    #sort columns
    analysis <- analysis[with(analysis, base::order(alignment.score, identity, -distance, decreasing =TRUE)),]
    write.csv(analysis, file = file.path(dirOut1, paste0(sprintf("%03d_", i), var, "_", symbol, ".csv")))
  }
}
