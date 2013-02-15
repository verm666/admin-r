#!/usr/bin/env Rscript

library(optparse)
library(data.table)

option_list <- list(
  make_option(c("-f", "--filename"), action="store", dest="filename",
    default="stdin"),
  make_option(c("-s", "--scale"), action="store", dest="scale", type="integer",
    default=60),
  make_option(c("-x", "--xlab"), action="store", dest="xlab", type="character",
    default="x"),
  make_option(c("-y", "--ylab"), action="store", dest="ylab", type="character",
    default="y"),
  make_option(c("-t", "--title"), action="store", dest="title", type="character",
    default="title")
)

# input file format
#        V1      V2 ...
# timestamp [value1 ...]

o <- parse_args(OptionParser(option_list = option_list,
  usage = "%prog [options]"))

if (o$scale <= 0) {
  stop(sprintf("scale must be positive number"))
}

if (o$filename != "stdin" && file.access(o$filename, mode=4) == -1) {
  stop(sprintf("could not open file: %s", o$filename))
}

d <- data.table(read.table(o$filename, sep=" ", ))
values_count = ncol(d)

d$V1 <- round(d$V1 / o$scale) * o$scale

for (i in seq(from=2, to=values_count)) {
  col_name = paste("V", i, sep="")
  d <- d[, sum(get(col_name) / o$scale), by=V1]
}

d$V1 <- as.POSIXct(origin="1970-01-01", d$V1)

X11()
plot(d, type="l", xlab=o$xlab, ylab=o$ylab, main=o$title)

write("press `ctrl+c` for exit", stderr())
while (T) {
  Sys.sleep(10)
}
