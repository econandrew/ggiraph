% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interactive_polyline_grob.R
\name{interactive_polyline_grob}
\alias{interactive_polyline_grob}
\title{Generate an Interactive Grob Path}
\usage{
interactive_polyline_grob(x = unit(c(0, 1), "npc"), y = unit(c(0, 1),
  "npc"), id = NULL, id.lengths = NULL, tooltip = NULL, onclick = NULL,
  data_id = NULL, default.units = "npc", arrow = NULL, name = NULL,
  gp = gpar(), vp = NULL)
}
\arguments{
\item{x}{A numeric vector or unit object specifying x-values.}

\item{y}{A numeric vector or unit object specifying y-values.}

\item{id}{A numeric vector used to separate locations in \code{x} and
    \code{y} into multiple lines.  All locations with the same
    \code{id} belong to the same line.}

\item{id.lengths}{A numeric vector used to separate locations in \code{x} and
    \code{y} into multiple lines.  Specifies consecutive blocks of
    locations which make up separate lines.}

\item{tooltip}{tooltip associated with polylines}

\item{onclick}{javascript action to execute when polyline is clicked}

\item{data_id}{identifiers to associate with polylines}

\item{default.units}{A string indicating the default units to use
    if \code{x} or \code{y} are only given as numeric vectors.}

\item{arrow}{A list describing arrow heads to place at either end
    of the line, as produced by the \code{arrow} function.}

\item{name}{ A character identifier. }

\item{gp}{An object of class \code{gpar}, typically the output
    from a call to the function \code{gpar}.  This is basically
    a list of graphical parameter settings.}

\item{vp}{A Grid viewport object (or NULL).}
}
\description{
This function can be used to generate an interactive grob
path.
}
