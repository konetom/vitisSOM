pipeline.2ndLvlSom <- function()
{
  2ndLvlSom.custom <<- som(t(metadata), xdim=preferences$dim.2ndLvlSom, ydim=preferences$dim.2ndLvlSom)

  if (preferences$dim.2ndLvlSom == 20)
  {
    2ndLvlSom.20.20 <<- 2ndLvlSom.custom
  } else
  {
    2ndLvlSom.20.20 <<- som(t(metadata), xdim=20, ydim=20)
  }

  filename <- file.path(paste(files.name, "- Results"), "2nd lvl Metagene Analysis", "2nd lvl SOM.pdf")
  util.info("Writing:", filename)
  pdf(filename, 21/2.54, 21/2.54)

  ##### Plot Supersom #####
  par(mar=c(1, 1, 1, 1))
  xl <- c(min(2ndLvlSom.custom$visual[,"x"])-1.2, max(2ndLvlSom.custom$visual[,"x"])+1.2)
  yl <- c(min(-2ndLvlSom.custom$visual[,"y"])-1.2, max(-2ndLvlSom.custom$visual[,"y"])+1.2)

  plot(2ndLvlSom.custom$visual[,"x"], -2ndLvlSom.custom$visual[,"y"], type="n",
       axes=F, xlab="", ylab="", xlim=xl, ylim=yl, xaxs="i", yaxs="i")

  if (ncol(indata) < 100)
  {
    legend("bottomright",  paste(1:length(colnames(indata)), ":", colnames(indata)),
           cex=0.5, text.col=group.colors, ncol=(ncol(indata)-1)%/%25+1, bg="white")
  }

  if (length(unique(group.labels)) > 1)
  {
    legend("topright", as.character(unique(group.labels)), cex=0.5,
           text.col=groupwise.group.colors, bg="white")
  }

  for (j in 1:nrow(2ndLvlSom.custom$code.sum))
  {

    which.samples <-
      intersect(which(2ndLvlSom.custom$visual[,"x"] == 2ndLvlSom.custom$code.sum[j,"x"]),
                which(2ndLvlSom.custom$visual[,"y"] == 2ndLvlSom.custom$code.sum[j,"y"]))

    if (!is.na(which.samples[1]))
    {

      which.samples <- which.samples[1:min(4, length(which.samples))]

      x.seq <- rep(c(-0.2, 0.2), 2)[1:length(which.samples)]
      y.seq <- c(rep(0.2, 2), rep(-0.2, 2))[1:length(which.samples)]

      points(2ndLvlSom.custom$visual[which.samples[1], "x"]+x.seq,
             -2ndLvlSom.custom$visual[which.samples[1], "y"]+y.seq,
             pch=16, col=group.colors[which.samples], cex=2.5)

      points(2ndLvlSom.custom$visual[which.samples[1], "x"]+x.seq,
             -2ndLvlSom.custom$visual[which.samples[1], "y"]+y.seq,
             pch=1, col="gray20", cex=2.5, lwd=1)

      text(2ndLvlSom.custom$visual[which.samples[1], "x"]+x.seq,
           -2ndLvlSom.custom$visual[which.samples[1], "y"]+y.seq,
           which.samples, col="gray20", cex=0.8)
    }
  }

  box()

  plot(2ndLvlSom.custom$visual[,"x"], -2ndLvlSom.custom$visual[,"y"], type="n",
       axes=F, xlab="", ylab="", xlim=xl, ylim=yl, xaxs="i", yaxs="i")

  if (length(unique(group.labels)) > 1)
  {
    legend("topright", as.character(unique(group.labels)), cex=0.5,
           text.col=groupwise.group.colors, bg="white")
  }

  for (j in 1:nrow(2ndLvlSom.custom$code.sum))
  {

    which.samples <-
      intersect(which(2ndLvlSom.custom$visual[,"x"] == 2ndLvlSom.custom$code.sum[j,"x"]),
                which(2ndLvlSom.custom$visual[,"y"] == 2ndLvlSom.custom$code.sum[j,"y"]))

    if (!is.na(which.samples[1]))
    {

      which.samples <- which.samples[1:min(4, length(which.samples))]

      x.seq <- rep(c(-0.2, 0.2), 2) [1:length(which.samples)]
      y.seq <- c(rep(0.2, 2), rep(-0.2, 2)) [1:length(which.samples)]

      points(2ndLvlSom.custom$visual[which.samples[1], "x"]+x.seq,
             -2ndLvlSom.custom$visual[which.samples[1], "y"]+y.seq,
             pch=16, col=group.colors[which.samples], cex=2.5)

      points(2ndLvlSom.custom$visual[which.samples[1], "x"]+x.seq,
             -2ndLvlSom.custom$visual[which.samples[1], "y"]+y.seq,
             pch=1, col="gray20", cex=2.5, lwd=1)

      text(2ndLvlSom.custom$visual[which.samples[1], "x"]+x.seq,
           -2ndLvlSom.custom$visual[which.samples[1], "y"]+y.seq,
           colnames(indata)[which.samples], col="gray20", cex=0.8)
    }
  }

  box()

  ##### Polygone-2ndSOM #####
  if (length(unique(group.labels)) > 1)
  {
    transparent.group.colors <- sapply(groupwise.group.colors, function(x)
    {
      paste(substr(x, 1, 7) , "50", sep="")
    })

    names(transparent.group.colors) <- unique(group.labels)

    plot(2ndLvlSom.custom$visual[,"x"], -2ndLvlSom.custom$visual[,"y"],
         type="n", axes=F, xlab="", ylab="", cex=4, col=group.colors, pch=16,
         xaxs="i", yaxs="i", xlim=xl, ylim=yl)

    for (i in 1:length(unique(group.labels)))
    {
      group.member <- which(group.labels==unique(group.labels)[i])
      group.centroid <- colMeans(2ndLvlSom.custom$visual[group.member, 1:2])

      hull <- chull(2ndLvlSom.custom$visual[group.member, 1],
                    -2ndLvlSom.custom$visual[group.member, 2])

      polygon(2ndLvlSom.custom$visual[group.member[hull], 1],
              -2ndLvlSom.custom$visual[group.member[hull], 2],
              col=transparent.group.colors[i], lty=1,
              border=groupwise.group.colors[i])
    }

    legend("topright", as.character(unique(group.labels)), cex=0.5,
           text.col=groupwise.group.colors, bg="white")

    box()
  }

  ##### Plot SmoothSupersom ######
  for (i in 1:length(unique(group.labels)))
  {
    col <- colorRampPalette(c("white", groupwise.group.colors[i]))
    coords <- cbind(2ndLvlSom.custom$visual[,"x"], -2ndLvlSom.custom$visual[,"y"])
    coords <- coords[which(group.labels==unique(group.labels)[i]) , ,drop=F]

    if (nrow(coords) == 1)
    {
      coords <- rbind(coords,coords)
    }

    smoothScatter(coords, main="", xlim=xl, ylim=yl, axes=F, xlab="", ylab="",
                  nrpoints=0, colramp=col, bandwidth=2, nbin=128,
                  transformation=function(x) { x^0.25 }, xaxs="i", yaxs="i")

    if (i < length(unique(group.labels)))
    {
      par(new=T)
    }
  }

  par(new=T)

  plot(2ndLvlSom.custom$visual[,"x"], -2ndLvlSom.custom$visual[,"y"],
       pch=16, col=group.colors, axes=F, xlab="",ylab="", xlim=xl,ylim=yl,
       xaxs="i", yaxs="i")

  if (length(unique(group.labels)) > 1)
  {
    legend("topright", as.character(unique(group.labels)), cex=0.5,
           text.col=groupwise.group.colors, bg="white")
  }

  ##### Plot Supersom with real expression profiles ######
  par(mar=c(1,1,1,1))
  xl <- c(min(2ndLvlSom.20.20$visual[,"x"])-1, max(2ndLvlSom.20.20$visual[,"x"])+1)
  yl <- c(min(-2ndLvlSom.20.20$visual[,"y"])-1, max(-2ndLvlSom.20.20$visual[,"y"])+1)

  plot(2ndLvlSom.20.20$visual[,"x"], -2ndLvlSom.20.20$visual[,"y"], type="p", axes=F,
       xlab="", ylab="", xlim=xl, ylim=yl, xaxs="i", yaxs="i")

  if (ncol(indata) < 100)
  {
    legend("bottomright",
           paste(1:length(colnames(indata)), ":", colnames(indata)),
           cex=0.5, text.col=group.colors, ncol=(ncol(indata)-1)%/%25+1, bg="white")
  }

  if (length(unique(group.labels)) > 1)
  {
    legend("topright", as.character(unique(group.labels)), cex=0.5,
           text.col=groupwise.group.colors, bg="white")
  }

  for (j in 1:nrow(2ndLvlSom.20.20$code.sum))
  {
    which.samples <-
      intersect(which(2ndLvlSom.20.20$visual[,"x"] == 2ndLvlSom.20.20$code.sum[j,"x"]),
                which(2ndLvlSom.20.20$visual[,"y"] == 2ndLvlSom.20.20$code.sum[j,"y"]))

    if (!is.na(which.samples[1]))
    {
      m <- matrix(metadata[, which.samples[1]], preferences$dim.1stLvlSom, preferences$dim.1stLvlSom)

      if (max(m) - min(m) != 0)
      {
        m <- (m - min(m)) / (max(m) - min(m)) * 999
      }

      m <- cbind(apply(m, 1, function(x){x}))[nrow(m):1,]
      x <- pixmapIndexed(m , col = colramp(1000))

      addlogo(x,
              2ndLvlSom.20.20$visual[which.samples[1], "x"]+c(-0.45,0.455),
              -2ndLvlSom.20.20$visual[which.samples[1], "y"]+c(-0.45,0.45))

      which.samples <- which.samples[1:min(4, length(which.samples))]

      x.seq <- rep(c(-0.2, 0.2), 2) [1:length(which.samples)]
      y.seq <- c(rep(0.2, 2), rep(-0.2, 2)) [1:length(which.samples)]

      points(2ndLvlSom.20.20$visual[which.samples[1], "x"]+x.seq,
             -2ndLvlSom.20.20$visual[which.samples[1], "y"]+y.seq,
             pch=16, col=group.colors[which.samples], cex=2.5)

      points(2ndLvlSom.20.20$visual[which.samples[1], "x"]+x.seq,
             -2ndLvlSom.20.20$visual[which.samples[1], "y"]+y.seq,
             pch=1, col="gray20", cex=2.5, lwd=1)

      text(2ndLvlSom.20.20$visual[which.samples[1], "x"]+x.seq,
           -2ndLvlSom.20.20$visual[which.samples[1], "y"]+y.seq,
           which.samples, col="gray20", cex=0.8)
    }
  }

  box()
  dev.off()
}
