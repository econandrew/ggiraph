#' @import htmlwidgets
#' @import htmltools
#' @import rvg
#' @import grid
#' @importFrom grDevices dev.off
#' @importFrom xml2 read_xml xml_find_all xml_text xml_ns
#' @importFrom xml2 xml_remove xml_attr xml_attr<-

#' @title ggiraph
#'
#' @description Create an interactive graphic to be used in a web browser.
#'
#' Use \code{geom_zzz_interactive} to create interactive graphical elements.
#'
#' Difference from original functions is that the following
#' aesthetics are understood: \code{tooltip}, \code{onclick}
#' and \code{data_id}.
#'
#' Tooltips can be displayed when mouse is over graphical elements.
#'
#' If id are associated with points, they get animated when mouse is
#' over and can be selected when used in shiny apps.
#'
#' On click actions can be set with javascript instructions. This option
#' should not be used simultaneously with selections in Shiny
#' applications as both features are "on click" features.
#'
#' When \code{zoom_max} is set, "zoom activate", "zoom desactivate" and
#' "zoom init" buttons are available in a toolbar.
#'
#' When \code{selection} is set to multiple (in Shiny applications), lasso
#' selection and lasso anti-selections buttons are available in a toolbar.
#'
#' @param code Plotting code to execute
#' @param ggobj ggplot objet to print. argument \code{code} will
#' be ignored if this argument is supplied.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param width_svg,height_svg svg viewbox width and height in inches
#' @param tooltip_extra_css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param hover_css css to apply when mouse is hover and element with a data-id attribute.
#' @param tooltip_opacity tooltip opacity
#' @param tooltip_offx tooltip x offset
#' @param tooltip_offy tooltip y offset
#' @param zoom_max maximum zoom factor
#' @param selection_type row selection mode ("single", "multiple", "none")
#'  when widget is in a Shiny application.
#' @param selected_css css to apply when element is selected (shiny only).
#' @param width widget width ratio (0 < width <= 1)
#' @param flexdashboard should be TRUE when used within a flexdashboard to
#' ensure svg will fit in boxes.
#' @param ... arguments passed on to \code{\link[rvg]{dsvg}}
#' @examples
#' # ggiraph simple example -------
#' @example examples/geom_point_interactive.R
#' @export
ggiraph <- function(code, ggobj = NULL,
	pointsize = 12, width = 0.7,
	width_svg = 6, height_svg = 6,
	tooltip_extra_css,
	hover_css,
	tooltip_opacity = .9,
	tooltip_offx = 10,
	tooltip_offy = 0,
	zoom_max = 1,
	selection_type = "multiple",
	selected_css, flexdashboard = FALSE,
	...) {

  if( missing( tooltip_extra_css ))
    tooltip_extra_css <- "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;"
  if( missing( hover_css ))
    hover_css <- "fill:orange;"
  if( missing( selected_css ))
    selected_css = "fill:orange;"



  stopifnot(selection_type %in% c("single", "multiple", "none"))
  stopifnot(is.numeric(tooltip_offx))
  stopifnot(is.numeric(tooltip_offy))
  stopifnot(is.numeric(tooltip_opacity))
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(is.numeric(zoom_max))

  if( zoom_max < 1 )
    stop("zoom_max should be >= 1")

	ggiwid.options = getOption("ggiwid")
	tmpdir = tempdir()
	path = tempfile()
	canvas_id <- ggiwid.options$svgid
	dsvg(file = path, pointsize = pointsize, standalone = TRUE,
			width = width_svg, height = height_svg,
			canvas_id = canvas_id, ...
		)
	tryCatch({
	  if( !is.null(ggobj) ){
	    stopifnot(inherits(ggobj, "ggplot"))
	    print(ggobj)
	  } else
	    code
	  }, finally = dev.off() )

	ggiwid.options$svgid = 1 + ggiwid.options$svgid
	options("ggiwid"=ggiwid.options)

	data <- read_xml( path )
	scr <- xml_find_all(data, "//*[@type='text/javascript']", ns = xml_ns(data) )
	js <- paste( sapply( scr, xml_text ), collapse = ";")

	xml_remove(scr)
  xml_attr(data, "width") <- NULL
  xml_attr(data, "height") <- NULL


	if( grepl(x = tooltip_extra_css, pattern = "position[ ]*:") )
	  stop("please, do not specify position in tooltip_extra_css, this parameter is managed by ggiraph.")
	if( grepl(x = tooltip_extra_css, pattern = "pointer-events[ ]*:") )
	  stop("please, do not specify pointer-events in tooltip_extra_css, this parameter is managed by ggiraph.")


	x = list( html = HTML( as.character(data) ), code = js,
	          tooltip_extra_css = tooltip_extra_css, hover_css = hover_css, selected_css = selected_css,
	          tooltip_opacity = tooltip_opacity, tooltip_offx = tooltip_offx, tooltip_offy = tooltip_offy,
	          zoom_max = zoom_max,
	          selection_type = selection_type,
	          ratio = width_svg / height_svg, flexdashboard = flexdashboard, width = width
	          )
	unlink(path)

	# create widget
	htmlwidgets::createWidget(
			name = 'ggiraph', x = x, package = 'ggiraph',
			sizingPolicy = sizingPolicy(knitr.figure = FALSE, defaultWidth = "70%", defaultHeight = "auto")
	)
}

#' @title Create a ggiraph output element
#' @description Render a ggiraph within an application page.
#'
#' @param outputId output variable to read the ggiraph from.
#' @param width widget width
#' @param height widget height
#' @examples
#' \dontrun{
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny/cars" )
#'   shinyAppDir(appDir = app_dir )
#'  }
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny/crimes" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' }
#' @export
ggiraphOutput <- function(outputId, width = "100%", height = "500px"){

  msger <- sprintf(
    "Shiny.addCustomMessageHandler('%s',function(message) {var varname = '%s';d3.selectAll('#%s svg *[data-id]').classed('clicked_%s', false);d3.selectAll(message).each(function(d, i) {d3.selectAll('#%s svg *[data-id=\"'+ message[i] + '\"]').classed('clicked_%s', true);});window[varname] = message;Shiny.onInputChange(varname, window[varname]);});",
    paste0(outputId, "_set"),
    paste0(outputId, "_selected"),
    outputId, outputId, outputId, outputId)



  div(
    singleton( tags$head(tags$script(msger)) ),
	  shinyWidgetOutput(outputId, 'ggiraph', package = 'ggiraph', width = width, height = height)
  )
}

#' @title Reactive version of ggiraph object
#'
#' @description Makes a reactive version of a ggiraph object for use in Shiny.
#'
#' @param expr An expression that returns a \code{\link{ggiraph}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @examples
#' \dontrun{
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' }
#' @export
renderggiraph <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, ggiraphOutput, env, quoted = TRUE)
}
