biomart.available <- function(env)
{
  mart <- try({ suppressMessages({ useMart(biomart="plants_mart", host="https://plants.ensembl.org", dataset = "vvinifera_eg_gene", verbose=FALSE) }) }, silent=TRUE)
  return(is(mart,"Mart"))
}
