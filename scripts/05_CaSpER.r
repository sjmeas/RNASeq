
#Creation of consolidated table

#Loading STAR *ReadsperGene.out.tab in RStudio
dataset1 <- read.table("./02_aligned/DCAF_A_S62_L007_R1_001_trimmed.fq.gzReadsPerGene.out.tab",sep="\t", skip = 4, header = F)

dataset2 <- read.table("./02_aligned/GFP_A_S57_L007_R1_001_trimmed.fq.gzReadsPerGene.out.tab",sep="\t", skip = 4, header = F)

dataset3 <- read.table("./02_aligned/KO_DCAF_A_S72_L007_R1_001_trimmed.fq.gzReadsPerGene.out.tab",sep="\t", skip = 4, header = F)

dataset4 <- read.table("./02_aligned/KO_GFP_A_S67_L007_R1_001_trimmed.fq.gzReadsPerGene.out.tab",sep="\t", skip = 4, header = F)


#creating a new dataframe out of these samples (V1 are gene names, V4 selected based on strandedness of data)
newdata <- data.frame(dataset1$V1,dataset1$V4,dataset2$V4,dataset3$V4,dataset4$V4)

#setting row names as genes
rownames(newdata) <- newdata$dataset1.V1
newdata$dataset1.V1 <- NULL

#setting column names as samples
colnames(newdata) <- c("DCAF_A_S62_L007_R1", "GFP_A_S57_L007_R1", "KO_DCAF_A_S72_L007_R1", "KO_GFP_A_S67_L007_R1")

#writing new dataframe to file
write.table(newdata, "./readsoutpergene_sum.tab", sep="\t")  

#HG38 cytoband creation
cytoband <- read.delim("cytoBand.txt", header=F)
cytoband <- data.frame(V1=gsub("chr", "", cytoband[,1]), V2=cytoband[,2], V3=cytoband[,3], V4=substring(cytoband$V4, 1, 1), stringsAsFactors=F)
start <- do.call(rbind, lapply(split(cytoband$V2, paste0(cytoband$V1, cytoband$V4)), min))
end <- do.call(rbind, lapply(split(cytoband$V3, paste0(cytoband$V1, cytoband$V4)), max))
cytoband <- data.frame(V1=gsub("p", "", gsub("q", "", rownames(start))), V2=start, V3=end, V4=rownames(start), stringsAsFactors=F)
cytoband <- cytoband [as.vector(unlist(sapply(c(1:22, "X"), function(x) which(cytoband$V1 %in% x)))), ]
cytoband$V4[grep("q", cytoband$V4)] <- "q"
cytoband$V4[grep("p", cytoband$V4)] <- "p"
rownames(cytoband) <- NULL
write.table(cytoband, "C:/Users/steve/Documents/cytoband.tab", sep="\t")

#loading centromere information
centromere <- read.delim("centromere.tab", header=F)

#creating annotation date
annotation <- generateAnnotation(id_type="ensembl_gene_id", genes=rownames(newdata), ishg19=T, centromere, host="uswest.ensembl.org")

#reading BAFExtractoutput
loh <- readBAFExtractOutput(path="./03_BAFExtract\\", sequencing.type="bulk")
names(loh) <- gsub(".snp", "", names(loh))

#create loh.name.mapping, this is just a file to match loh.name with sample name, if different
loh.name.mapping <- data.frame("loh.name" = c("DCAF_A_S62_L007_R1", "GFP_A_S57_L007_R1", "KO_DCAF_A_S72_L007_R1", "KO_GFP_A_S67_L007_R1"), "sample.name" = c("DCAF_A_S62_L007_R1", "GFP_A_S57_L007_R1", "KO_DCAF_A_S72_L007_R1", "KO_GFP_A_S67_L007_R1"))

#making control.sample.ids, just a list of control samples
control.sample.ids = c("DCAF_A_S62_L007_R1","GFP_A_S57_L007_R1")

#comparing annotation data to newdata, making them equal
gene1=rownames(newdata)
gene2=rownames(annotation)
gene3=intersect(gene1,gene2)
gene2=annotation$Gene
gene3=intersect(gene1,gene2)
newdata1=newdata[rownames(newdata) %in% gene3,]
newdata2=newdata1[match(annotation$Gene,rownames(newdata1)),]

#creating casper object
object <- CreateCasperObject(raw.data=newdata2, loh.name.mapping=loh.name.mapping, sequencing.type="bulk", 
                             cnv.scale=3, loh.scale=3, matrix.type="normalized", expr.cutoff=4.5,
                             annotation=annotation, method="iterative", loh=loh, filter="median",  
                             control.sample.ids=control.sample.ids, cytoband=cytoband, genomeVersion= "hg38")

final.objects <- runCaSpER(object, removeCentromere=T, cytoband=cytoband, method="iterative")

#segment based CNV summarization
gamma <- 6
all.segments <- do.call(rbind, lapply(final.objects, function(x) x@segments))
segment.summary <- extractSegmentSummary (final.objects)
loss <- segment.summary$all.summary.loss
gain <- segment.summary$all.summary.gain
loh <- segment.summary$all.summary.loh
loss.final <- loss[loss$count>gamma, ]
gain.final <- gain[gain$count>gamma, ]
loh.final <- loh[loh$count>gamma, ]

#gene based CNV summarization

all.summary<- rbind(loss.final, gain.final)
colnames(all.summary) [2:4] <- c("Chromosome", "Start",   "End")
geno.rna <-  GRanges(seqnames = Rle(gsub("q", "", gsub("p", "", all.summary$Chromosome))), 
                     IRanges(all.summary$Start, all.summary$End))   
ann.gr <- makeGRangesFromDataFrame(final.objects[[1]]@annotation.filt, keep.extra.columns = TRUE, seqnames.field="Chr")
hits <- findOverlaps(geno.rna, ann.gr)
genes <- splitByOverlap(ann.gr, geno.rna, "GeneSymbol")
genes.ann <- lapply(genes, function(x) x[!(x=="")])
all.genes <- unique(final.objects[[1]]@annotation.filt[,2])
all.samples <- unique(as.character(final.objects[[1]]@segments$ID))
rna.matrix <- gene.matrix(seg=all.summary, all.genes=all.genes, all.samples=all.samples, genes.ann=genes.ann)


