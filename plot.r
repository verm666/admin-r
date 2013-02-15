#!/usr/bin/env Rscript

library(optparse)
library(data.table)

option_list <- list(
  make_option(c("-f", "--filename"), action="store", dest="filename"),
  make_option(c("-s", "--scale"), action="store", dest="scale", type="integer",
    default=60),
  make_option(c("-x", "--xlab"), action="store", dest="xlab", type="character",
    default="x"),
  make_option(c("-y", "--ylab"), action="store", dest="ylab", type="character",
    default="y"),
  make_option(c("-t", "--title"), action="store", dest="title", type="character",
    default="title")
)

o <- parse_args(OptionParser(option_list = option_list,
  usage = "%prog [options]"))

if (is.null(o$filename)) {
  stop("filename must be specified")
}

if (file.access(o$filename, mode=4) == -1) {
  stop(sprintf("could not open file: %s", o$filename))
}

d <- data.table(read.table(o$filename, sep=" ",
  col.names=c("timestamp", "value")))
d$timestamp <- round(d$timestamp / o$scale) * o$scale
d <- d[, sum(value / o$scale), by=timestamp]

d$timestamp <- as.POSIXct(origin="1970-01-01", d$timestamp)

X11()
plot(d, type="l", xlab=o$xlab, ylab=o$ylab, main=o$title)

message("press any key to exit")
i <- readLines("stdin", n = 1)
