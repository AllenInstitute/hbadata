#'Micro RNA Expression Values for the Human Brain Atlas.
#'
#'A dataset containing the normalized expression values for the human brain atlas.
#'
#'@format A data frame with 32160624 rows and 5 variables:
#'\describe{
#'  \item{donorID}{brain ID from the Allen Institute}
#'  \item{probe_name}{mRNA probe used for this observation}
#'  \item{gene}{gene the above probe corresponds to; gene to probe is many to one}
#'  \item{brain_structure}{brain structure acronym}
#'  \item{value}{normalized expression value}
#'}
#'@source \url{"http://human.brain-map.org/static/download"}
"datHBA"

#'Donor ID's for Brains in the Human Brain Atlas
#'
#'A vector of the donor ID's from the 6 brains in the human brain atlas
#'
#'@format A character vector of length 6:
#'
#'@source \url{"http://human.brain-map.org/static/download"}
"donorsHBA"

#'Genes Surveyed in the Human Brain Atlas
#'
#'A list of the genes surved in the Human Brain Atlas at the Allen Institute
#'
#'@format A large character vector of length 29131
#'@source \url{"http://human.brain-map.org/static/download"}
"genesHBA"

#'Ontology of the Human Brains in the Human Brain Atlas
#'
#'A dataset containing the acronyms and corresponding structure names for all of the brain structures featured in the Human Brain Atlas.
#'
#'@format A data frame with 559 rows and 2 variables:
#'\describe{
#'  \item{acronyms}{brain structure acronym as used in `subregionsHBA`}
#'  \item{name}{brain structure names; substructures may have same acronyms}
#'}
#'@source \url{"http://human.brain-map.org/static/download"}
"ontologyHBA"

#'mRNA Probes Used in the Human Brain Atlas
#'
#'A list of the mRNA probes surveyed in the Human Brain Atlas at the Allen Institute.
#'
#'@format A large character vector of length 58692
#'@source \url{"http://human.brain-map.org/static/download"}
"probesHBA"

#'Brain Subregions Surveyed in the Human Brain Atlas
#'
#'A list of the subregions acronyms surveyed in the Human Brain Atlas at the Allen Institute.
#'
#'@format A character vector of length 232
#'@source \url{"http://human.brain-map.org/static/download"}
"subregionsHBA"
