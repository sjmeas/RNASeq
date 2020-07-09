# Settings
data_dir <- "D:/Users/steve/Documents/Projects/RNASeq/lncRNAs/data" # Steve
data_dir <- "/Users/mdozmorov/Documents/Work/GitHub/RNA-seq/misc/RNASeq/lncRNAs/data" # Mikhail
fileNameIn1 <- file.path(data_dir, "Analysis4_up.csv")
fileNameIn2 <- file.path(data_dir, "blat_results.psl")
fileNameIn3 <- file.path(data_dir, "blat_results_scored")
fileNameIn4 <- file.path(data_dir, "sorted.bed")

#read data
scored <- read.table("blat_results_scored")
unscored <- read.table("blat_results.psl", skip = 5, sep = "\t")
data <- read.csv("D:/Users/steve/Documents/Projects/RNASeq/lncRNAs/data/Analysis4_up.csv")
newdata <- read.table("sorted.bed", sep = "\t", header = T)

#add unique mm10 query identifier to each match
newscored <- scored
newscored$V7 <- unscored$V10

#create list of identifiers from original data
chrom.list <- list()

for (i in 1:dim(newdata)[1]) {
  identifier <- paste0(newdata$chrom[i],":",newdata$chromStart[i],"-",newdata$chromEnd[i])
  chrom.list[[i]] <- identifier
}

newdata$V7 <- chrom.list

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

#create directory for results
dir.create("annoData_results")

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
    gr1$score <- as.numeric(gr1$score) 
    gr2 <- gr1
    ol <- findOverlapsOfPeaks(gr1, gr2)
    ol <- addMetadata(ol, colNames="score", FUN=mean) 
    
    #prepare annotation data
    library(EnsDb.Hsapiens.v86)
    annoData <- toGRanges(EnsDb.Hsapiens.v86, feature="gene")
    overlaps <- ol$peaklist[["gr1///gr2"]]
    binOverFeature(overlaps, annotationData=annoData,
                   radius=5000, nbins=20, FUN=length, errFun=0,
                   ylab="count", 
                   main="Distribution of aggregated peak numbers around TSS")
    
    
    library(TxDb.Hsapiens.UCSC.hg38.knownGene)
    aCR<-assignChromosomeRegion(overlaps, nucleotideLevel=FALSE, 
                                precedence=c("Promoters", "immediateDownstream", 
                                             "fiveUTRs", "threeUTRs", 
                                             "Exons", "Introns"), 
                                TxDb=TxDb.Hsapiens.UCSC.hg38.knownGene)
    barplot(aCR$percentage, las=3)
    
    overlaps.anno <- annoPeaks(overlaps, 
                               annoData=annoData, 
                               output="nearestBiDirectionalPromoters",
                               bindingRegion=c(-2000, 500))
    library(org.Hs.eg.db)
    overlaps.anno <- addGeneIDs(overlaps.anno,
                                "org.Hs.eg.db",
                                IDs2Add = "entrez_id")
    head(overlaps.anno)
    overlaps.anno$peakNames <- NULL
    #write files for each annoData entry
    write.csv(as.data.frame(unname(overlaps.anno)), file = paste0("./annoData_results/",var,"_annoData.csv"))
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
dir.create("compiled_results")
analysis <- data.frame()

for (i in 1:length(data$genes)){
  var <- data$genes[i]
  index <- match(var,names(annotated_list))
  #only genes that are present in annotated_list are processed
  if (!is.na(index)){
    annoData_df <- annotated_list[[index]]
    rows <- data[i,]
    #duplicate the original analysis4_up data for the number of entries retrieved from annoData
    analysis <- rbind(rows, rows[rep(1, dim(annoData_df)[1] - 1),])
    #add in annoData by columns
    analysis[1:dim(annoData_df)[1],c("mm10_chr", "mm10_start", "mm10_end","mm10_strand")] <- newdata[i,c("chrom","chromStart","chromEnd", "strand")]
    analysis[,c("hg38_chr", "hg38_start", "hg38_end", "hg38_strand", "score", "feature", "feature.ranges.start", "feature.ranges.end", "feature.ranges.width", "feature.strand", "distance", "insideFeature", "distanceToSite", "gene_name", "entrez_id")] <- annoData_df[,c("seqnames","start","end", "strand", "score", "feature", "feature.ranges.start", "feature.ranges.end", "feature.ranges.width", "feature.strand", "distance", "insideFeature", "distanceToSite", "gene_name", "entrez_id")]
    analysis <- analysis %>%
      add_column(identity  = annoData_df[,"identity"], .after = "score") 
    #sort columns
    analysis <- analysis[with(analysis,order(-score,identity,distance)),]
    write.csv(analysis, file = paste0("./compiled_results/",var,".csv"))
  }
}
