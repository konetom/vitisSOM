pipeline.detectEnsemblDataset <- function(env)
{
    env$preferences$database.dataset <- ""
    util.info("Autodetecting vine annotation parameters")
    mart <- useMart(biomart = "plants_mart", host = "https://plants.ensembl.org",
                    dataset = "vvinifera_eg_gene")
    biomart.table <- getBM(c("ensembl_gene_id", "chromosome_name",
                             "name_1006", "definition_1006", "goslim_goa_description"), "ensembl_gene_id", rownames(env$indata),
                           mart, checkFilters = FALSE)
    env$preferences$database.dataset <- "vvinifera_eg_gene"
    env$preferences$database.id.type <- rownames(env$indata)
    return(env)
}
