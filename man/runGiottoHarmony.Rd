% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dimension_reduction.R
\name{runGiottoHarmony}
\alias{runGiottoHarmony}
\title{runGiottoHarmony}
\usage{
runGiottoHarmony(
  gobject,
  spat_unit = NULL,
  feat_type = NULL,
  vars_use = "list_ID",
  do_pca = FALSE,
  expression_values = c("normalized", "scaled", "custom"),
  dim_reduction_to_use = "pca",
  dim_reduction_name = NULL,
  dimensions_to_use = 1:10,
  name = NULL,
  feats_to_use = NULL,
  toplevel_params = 2,
  return_gobject = TRUE,
  ...
)
}
\arguments{
\item{gobject}{giotto object}

\item{spat_unit}{spatial unit}

\item{feat_type}{feature type}

\item{expression_values}{expression values to use}

\item{dim_reduction_to_use}{use another dimension reduction set as input}

\item{dim_reduction_name}{name of dimension reduction set to use}

\item{dimensions_to_use}{number of dimensions to use as input}

\item{name}{arbitrary name for Harmony run}

\item{feats_to_use}{if dim_reduction_to_use = NULL, which genes to use}

\item{toplevel_params}{parameters to extract}

\item{return_gobject}{boolean: return giotto object (default = TRUE)}

\item{...}{additional Harmony parameters}

\item{verbose}{be verbose}
}
\value{
giotto object with updated Harmony dimension recuction
}
\description{
run UMAP
}
\details{
See \code{\link[harmony]{HarmonyMatrix}} for more information about these and other parameters.
This is a simple wrapper for the HarmonyMatrix function in the Harmony package.
}
