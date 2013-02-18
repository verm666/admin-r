#!/usr/bin/env Rscript

suppressMessages(require(ggplot2))
suppressMessages(require(reshape))
suppressMessages(library(optparse))

option_list <- list(
  make_option(c("-f", "--filename"), action="store", dest="filename",
    default="stdin"),
  make_option(c("-s", "--scale"), action="store", dest="scale", type="integer",
    default=60),
  make_option(c("-x", "--xlab"), action="store", dest="xlab", type="character",
    default="x"),
  make_option(c("-y", "--ylab"), action="store", dest="ylab", type="character",
    default="y"),
  make_option(c("-t", "--title"), action="store", dest="title",
    type="character", default="title"),
  make_option(c("-c", "--columns"), action="store", dest="columns",
    type="character", default="all")
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

d <- read.table(o$filename, sep=" ")

if (o$columns == "all") {
  useful_columns = seq(from=2, to=ncol(d))
} else {
  useful_columns = as.numeric(strsplit(o$columns, ",")[[1]])
}

# scale timestamp
d$V1 <- round(d$V1 / o$scale) * o$scale
dn <- data.frame(unique(d$V1))
colnames(dn)[1] <- 'time'

# scale values
for (i in useful_columns) {
  col_name <- paste("V", i, sep="")
  dn[col_name] <- c(aggregate(d[, col_name], by=list(d$V1), sum)["x"])
}

dn[1] <- as.POSIXct(origin="1970-01-01", dn[, 1])
dn <- melt(dn, id = 'time', variable_name = 'Legend')

# plot
X11()
ggplot(dn, aes(time, value)) +
  geom_line(aes(colour = Legend)) +
  labs(x=o$xlab, y=o$ylab, title=o$title)

write("press `ctrl+c` for exit", stderr())
while (T) {
  Sys.sleep(10)
}
