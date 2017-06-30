#------------------------------------------------------------------------------#
#----------------------------FUNCTION DEFINITIONS------------------------------#
#------------------------------------------------------------------------------#

#' Tidy the human brain atlas data. The data is available for download here:
#' http://human.brain-map.org/static/download. The data comes as 6 zip files,
#' one for each donor. To use this script, but all 6 directories in a base
#' directory like such
#' 
#' dirHBA
#'      |_ Donor1
#'      |_ Donor2
#'      |_ ...
#' 
#' The `path` is then the path to dirHBA.
#' 
#' 
#' 
#' @param path File path to the base directory as depicted above
#' @param func Aggregating function for brain structures; `max` default
#' @param Boolean for rowcollapsing via WGCNA's collapseRows; `TRUE` default
#' @return Create a new directory in the current working directory `resultFrame` or `resultFrameCollapse`. This directoy contains the tidy version of each donors brain
#' @examples
#' dirHBA <- "/my/very/cool/file/system/dirHBA"
#' # aggregate to max and don't collapse
#' formatterHBA(dirHBA)
#' 
#' # aggregate to min and collapse rows
#' formatterHBA(dirHBA, func=min, collapse=TRUE) 
formatterHBA <- function(path, func=max, collapse = FALSE){
    
    # create a list of files to iterate through
    pathHBA <- as.list(list.dirs(dirHBA, recursive = FALSE))
    
    # format each file and save to a csv labeled 1-n for reading later
    i <- 1
    for (brain in pathHBA) {
        print("Begin Formatting")
        resultFrame <- .formatOneHBA(brain, f=func, c=collapse)
        print("Saving results")
        if (collapse){
            readr::write_csv(resultFrame, 
                             paste("./resultFrameCollapse/resultFrame",
                                   as.character(i), ".csv", sep=""))
        } else {
            readr::write_csv(resultFrame,paste("./resultFrame/resultFrame",
                                               as.character(i), ".csv", sep=""))
        }
        print(paste("Done saving", as.character(i)))
        i <- i + 1
    }
}

#------------------------------HELPER FUNCTIONS--------------------------------#

.createHBAMatrix <- function(mpath, ppath, apath){

    # load the microexpression data...suppress to hide parse info
    suppressMessages(MicroExp <- readr::read_csv(mpath, col_names = FALSE))
    suppressMessages(AnSamp <- readr::read_csv(apath))
    suppressMessages(Probes <- readr::read_csv(ppath)[c("probe_id", "probe_name", "gene_symbol")])

    # Change first column name for joining
    colnames(MicroExp)[1] <- "probe_id"

    if (all(MicroExp$probe_id == Probes$probe_id)) {

        # this is to ensure that the order of the probe ids is the same in both
        # frames. Checking is O(n), while joining is O(n^2)
        rowProbeID <- Probes$probe_name
        rowGeneGroup <- Probes$gene_symbol
        MicroExp <- MicroExp[c(-1)]

    } else {
        # in the event that they are ordered differently we need to join on the
        # identifier
        warning("probe_id variable from micro-array expression csv and probe csv do not have the same order\n\nThis implies gene order may have changed")
        MicroExp <- dplyr::inner_join(
            Probes, MicroExp, by="probe_id")

        rowProbeID <- MicroExp$probe_name
        rowGeneGroup <- MicroExp$gene_symbol
        MicroExp <- MicroExp[c(-1,-2,-3)]
    }

    colnames(MicroExp) <- AnSamp$structure_acronym
    MicroExp <- cbind(probe_name = rowProbeID,
                      gene = rowGeneGroup,
                      MicroExp)

    return(list(dat = MicroExp))
}

    
.formatOneHBA <- function(folder, f=max, c=FALSE){

    # extract the donor ID from the file string
    donorID <- gsub("normalized_microarray_", "",
               tail(strsplit(folder, '/')[[1]], n=1))

    # format the paths appropriately to read the csvs
    micro_path <- paste(folder,"MicroarrayExpression.csv",sep="/")
    probe_path <- paste(folder, "Probes.csv", sep="/")
    annot_path <- paste(folder, "SampleAnnot.csv", sep="/")

    # format the dataframe correctly and retun for aggregating
    print("Begin reading in data")
    MicroExp <- .createHBAMatrix(micro_path, probe_path, annot_path)
    print("Data loaded")
    gc() # reallocate free memory

    # create unique column ids...for melting
    n_col <- ncol(MicroExp$dat) - 2
    n_pad <- nchar(as.character(n_col))
    id_pad <- stringr::str_pad(as.character(1:n_col), n_pad, pad="0")
    col_ids <- paste(colnames(MicroExp$dat)[c(-1,-2)], id_pad, sep="")
    colnames(MicroExp$dat)[c(-1,-2)] <- col_ids

    # reformat as long data to aggragate on groups
    MicroLong <- reshape2::melt(MicroExp$dat, id.vars = c("probe_name", "gene"))
    structs <- as.character(MicroLong$variable)
    MicroLong$variable <- factor(substr(structs, 1, nchar(structs) - n_pad))

    # aggregate on genes and probes, and structure
    print("Begin data aggregation")
    MicroLong <- aggregate(.~probe_name+gene+variable, MicroLong, f)
    print("Done aggregating")
    gc()  # make sure to reallocate free memory

    # collapse rows -- this is a time intensive step
    if (c){

        # format for use in WGCNA collapseRow
        MicroExp$dat <- tidyr::spread(MicroLong, variable, value) # wide format
        MicroExp$group <- MicroExp$dat$gene
        MicroExp$id <- MicroExp$dat$probe_name
        MicroExp$struct <- colnames(MicroExp$dat)[c(-1,-2)]
        MicroExp$dat <- as.matrix(MicroExp$dat[c(-1,-2)])
        rownames(MicroExp$dat) <- MicroExp$id

        # remove old objects to free memory
        rm(MicroLong)
        rm(structs)
        gc()  # this may make the machine return memory

        # collapse rows to get a single representative of each gene
        print("Collapsing Rows")
        MicroCollapse <- WGCNA::collapseRows(
            MicroExp$dat, rowGroup = MicroExp$group, rowID = MicroExp$id)
        print("Done collapsing")

        # reformat to a dataframe and create a gene variable before reshaping
        # this is to facilitate joining the gene on the selected probe
        resultFrame <- as.data.frame(MicroCollapse$datETcollapsed)
        resultFrame$gene <- rownames(resultFrame)
        rownames(resultFrame) <- c(1:nrow(resultFrame))
        resultFrame <- reshape2::melt(resultFrame, id.vars=c("gene"))

        # reformate the group2row matrix as a data frame and add names for join
        group2row <- unique(as.data.frame(MicroCollapse$group2row))
        colnames(group2row) <- c("gene", "probe_name")

        # inner join to match genes with probes
        resultFrame <- dplyr::inner_join(resultFrame, group2row, by="gene")
        resultFrame <- cbind(probe_name = resultFrame$probe_name, 
                             resultFrame[c(-4)])
        resultFrame <- cbind(donorID, resultFrame)
        resultFrame$gene <- factor(resultFrame$gene)

    } else {
        # add the donorId to get a frame of every probes value in each struct
        resultFrame <- cbind(donorID, MicroLong)
    }
    
    print(paste("dataframe dimensions:", dim(resultFrame)))
    print("Foramtting complete")
    return(resultFrame)
}


#------------------------------------------------------------------------------#
#---------------------------------MAIN SCRIPT----------------------------------#
#------------------------------------------------------------------------------#

# This script is meant to reformat the data found on the allen institutes human
# brain atlas form into tidy (http://vita.had.co.nz/papers/tidy-data.html) data.
# It accomplishes this goal by individually transfering each brain from wide to
# long format and then aggregating on structures to create ID - observation 
# pairs. From there the data is collapsed using the WGCNA collapseRows function,
# and is then saved as a csv (disk space is cheap...). The second half of this 
# scipt then loads these csvs (after exiting the initial function) and rbinds
# them together before saving as one large tidy dataframe.

# reset dirHBA to point to base directory
dirHBA <- "C:/Users/charlese/Desktop/Data_Exploration/dir_HBA"
datHBA_test <- formatterHBA(dirHBA, collapse = TRUE)



# load to create level for factor import 
# these are created in `create_factors.py`
load("C:/Users/cygwin/home/charlese/hbadata/data/donorsHBA.rda")
load("C:/Users/cygwin/home/charlese/hbadata/data/probesHBA.rda")
load("C:/Users/cygwin/home/charlese/hbadata/data/genesHBA.rda")
load("C:/Users/cygwin/home/charlese/hbadata/data/subregionsHBA.rda")

# open up and rbind to a new dataframe
# dirResults <- "C:/Users/cygwin/home/charlese/resultFrame" # full
dirResults <- "C:/Users/cygwin/home/charlese/resultFrameCollapse" # collapsed
datHBA <- NULL
for (file in list.files(dirResults, recursive = FALSE)) {
    if (is.null(datHBA)) {
        datHBA <- readr::read_csv(paste(dirResults,file,sep="/"),
                                  col_types= list(
                                   donorID = readr::col_factor(donorsHBA),
                                   probe_name = readr::col_factor(probesHBA),
                                   gene = readr::col_factor(genesHBA),
                                   variable = readr::col_factor(subregionsHBA),
                                   value = readr::col_number()
                                  ))
    } else {
        datHBA <- rbind(datHBA, readr::read_csv(paste(dirResults,file,sep="/"),
                                        col_types= list(
                                        donorID = readr::col_factor(donorsHBA),
                                        probe_name = readr::col_factor(probesHBA),
                                        gene = readr::col_factor(genesHBA),
                                        variable = readr::col_factor(subregionsHBA),
                                        value = readr::col_number()
                                        )))
    }
}

colnames(datHBA)[4] <- "brain_structure"
save(datHBA, file = "datHBACollapsed.Rda", compress = "xz")
