
cat("Geneset Profiles and Maps\n|" )
for( i in 1:50 ) cat(" ")
cat("|\n|")
flush.console()





  ### init parallel computing ###

#   try({ stopCluster(cl) }, silent=T )
# 
#   if( Sys.info()["sysname"] == "Windows" )
#   {  
#     cl<-makeCluster( preferences$max.parallel.cores )
#     registerDoSNOW(cl)
#     
#   } else
#   {
#     registerDoMC( preferences$max.parallel.cores )
#   }





  ### csv output ###

  samples.GSZ.scores = do.call( cbind,  lapply( GS.infos.samples, function(x) {  x$GSZ.score[names(gs.def.list)] } )  ) 

  write.csv2( samples.GSZ.scores, paste( files.name, " - Results/CSV Sheets/Sample GSZ scores.csv", sep="" ) )












  ## Geneset Profiles over Samples


  if( preferences$geneset.analysis.exact )
  {

    fdr.threshold = 0.1

    GSZs = cbind( as.vector( unlist( sapply( GS.infos.samples, function(x){   x$GSZ.score[names(gs.def.list)]    } )  ) ),
          as.vector( unlist( sapply( GS.infos.samples, function(x){   x$GSZ.p.value[names(gs.def.list)]    } )  ) ) )

    GSZs = GSZs[ which( !is.na(GSZs[,2]) ), ]
  
    fdrtool.result = fdrtool( GSZs[,2], statistic="pvalue", verbose=F, plot=F )
    fdr.significant.GS.infos.samples = length( which( fdrtool.result$lfdr < fdr.threshold ) )

    fdr.gsz.threshold = sort( GSZs[,1], decreasing=T )[ fdr.significant.GS.infos.samples ]

  } else
  {
    fdr.gsz.threshold = 0
  }





  
#  leading.metagenes = sapply( lapply( GS.infos.overexpression[-1], function(x){ x$metagenes } ), function(x){order( metadata.sum[x,"nobs"], decreasing=T )[1]} )


#  foreach( i = 1:nrow(samples.GSZ.scores) ) %dopar%
  for( i in 1:nrow(samples.GSZ.scores) )
  {
    pdf( paste( files.name, " - Results/Geneset Analysis/", substring( make.names( names(gs.def.list)[i]), 1, 100 )," profile.pdf", sep="" ), 29.7/2.54, 21/2.54 )
    par( mar=c(15,6,4,5) )


    leading.metagenes = as.numeric( names( sort( table( som.nodes[ names(gene.ids)[ which( gene.ids %in% gs.def.list[[i]]$Genes ) ] ] ), decreasing=T ) )[1:5] )

    ylim = c( -10, 20 )
#    ylim = range(samples.GSZ.scores)
    bar.coords = barplot( samples.GSZ.scores[i,], beside=T, main=rownames(samples.GSZ.scores)[i], las=2, cex.names=1.2, col=group.colors, cex.main=1, ylim=ylim, border = if( ncol(indata) < 80 ) "black" else NA, names.arg=if( ncol(indata)<100 ) colnames(indata) else rep("",ncol(indata) ) )
      abline( h=fdr.gsz.threshold, lty=2 )
      abline( h=-fdr.gsz.threshold, lty=2 )

      mtext( "GSZ", side=2, line=3.5, cex=2 )

    
    
    mean.boxes = by( samples.GSZ.scores[i,], group.labels, c )[ unique( group.labels ) ]
    boxplot( mean.boxes, col=unique.group.colors, main=rownames(samples.GSZ.scores)[i], cex.main=1, ylim=ylim, axes=F, yaxs="i" )
      axis( 1, 1:length(unique(group.labels)), unique(group.labels), las=2, tick=F )
      axis( 2, las=2 )  

      abline( h=0, lty=2 )
      abline( h=fdr.gsz.threshold, lty=2 )
      abline( h=-fdr.gsz.threshold, lty=2 )
      
      mtext( "GSZ", side=2, line=3.5, cex=2 )
      
      
#     if( length(leading.metagenes) > 0 )
#     {
#       par(new=T)
#       plot( 0, type="n", xlab="", ylab="", axes=F, xlim=range(bar.coords)+c(-0.5,0.5), ylim=ylim )
#       for( j in 1:length(leading.metagenes) )
#         lines( bar.coords, metadata[ leading.metagenes[j], ], lwd=2, col=paste("gray", round(seq(1,80,length.out=5))[j] ,sep="") )
#       axis( 4, las=2 )
#       mtext( expression( paste( Delta, "e", ''^meta ) ), side=4, line=3.5, cex=2 )
#     }



    #################################################

    spot.fisher.p = -log10( sapply( GS.infos.overexpression$spots, function(x){ x$Fisher.p[ names(gs.def.list)[i] ] } ) )
    names(spot.fisher.p) = LETTERS[ 1:length(spot.fisher.p) ]
    
    barplot( spot.fisher.p, main=paste("Enrichment in spots:",names(gs.def.list)[i]) , las=1, cex.names=1.2 )
      mtext( "log( p.value )", side=2, line=3.5, cex=2 )





    #################################################

    spot.expression = t( sapply( GS.infos.overexpression$spots, function(x)
    { 
      g = intersect( gene.ids[x$genes], gs.def.list[[i]]$Genes )
      g = names(gene.ids)[ which( gene.ids %in% g ) ]
      if( length(g) > 0 )
      {
        return( apply( indata[g,,drop=F], 2, mean ) )
      } else
      {
        return( rep(0,ncol(indata)) )
      }
    } ) )
    colnames(spot.expression) = colnames(indata)


    for( ii in 1:nrow(spot.expression) )
    {
      barplot( spot.expression[ii,], beside=T, main=paste("Expression of",names(gs.def.list)[i],"in Spot",LETTERS[ii]), las=2, cex.names=1.2, col=group.colors, cex.main=1, ylim=range(spot.expression), border = if( ncol(indata) < 80 ) "black" else NA )
        mtext( expression(paste(Delta,"e")), side=2, line=3.5, cex=2 )    
    }


    dev.off()




    #################################################

    genes = names(gene.ids)[ which( gene.ids %in% gs.def.list[[i]]$Genes ) ]
    
    out = data.frame( AffyID = names( gene.ids[ genes ] ),
                      EnsemblID = gene.ids[ genes ],
                      Metagene = genes.coordinates[ genes ],
                      Max.expression.sample = colnames(indata)[ apply( indata[ genes, ,drop=F], 1, which.max ) ],
                      GeneSymbol = gene.names[ genes ],
                      Description = gene.descriptions[ genes ]    )

    write.csv2( out, paste( files.name, " - Results/Geneset Analysis/", substring( make.names( names(gs.def.list)[i]), 1, 100 ),".csv", sep="" ), row.names=F   )

 

  out.intervals = round( seq( 1, nrow(samples.GSZ.scores), length.out=25+1 ) )[-1]
  cat( paste( rep("#",length( which( out.intervals == i) ) ), collapse="" ) );  flush.console()

  }










  ## Gensets Population Maps  

#  foreach( i = 1:length(gs.def.list) ) %dopar%
  for( i in 1:length(gs.def.list) )
  {
    pdf( paste( files.name, " - Results/Geneset Analysis/", substring( make.names( names(gs.def.list)[i]), 1, 100 )," map.pdf", sep="" ), 21/2.54, 21/2.54 )

    
    ### Population Map ###

    n.map = matrix(0,preferences$dim.som1,preferences$dim.som1)
    gs.nodes = som.nodes[  names( gene.ids )[ which( gene.ids %in% gs.def.list[[ i ]]$Genes ) ]  ]
    n.map[ as.numeric( names(table( gs.nodes )) ) ] = table( gs.nodes )
    n.map[which(n.map==0)] = NA
    n.map = matrix( n.map, preferences$dim.som1 )
    
    
    x.test = sum( ( apply( n.map, 1, sum, na.rm=T ) - sum(n.map, na.rm=T)*(1/preferences$dim.som1) )^2 / sum(n.map, na.rm=T)*(1/preferences$dim.som1) )
    y.test = sum( ( apply( n.map, 2, sum, na.rm=T ) - sum(n.map, na.rm=T)*(1/preferences$dim.som1) )^2 / sum(n.map, na.rm=T)*(1/preferences$dim.som1) )
    chi.sq.p.value = 1-pchisq( x.test+y.test, 1 )
    

#    old rectangular map
    
#     par( mfrow = c(1,1) );  par( mar=c(5,6,4,5) )
#     image( matrix( (n.map), preferences$dim.som1, preferences$dim.som1 ), main=names(gs.def.list)[i], col=colramp(1000), axes=F, cex.main=2 )
#       title(sub=paste( "# features =", sum( gene.ids %in% gs.def.list[[ i ]]$Genes ) ),line=0)
#       box()
# 
#     par(new=T, mar=c(1,0,0,0) );  layout( matrix( c(0,0,0,0,1,0,0,0,0), 3, 3 ), c( 1, 0.05, 0.02 ), c( 0.15, 0.3, 1 ) )
#     image( matrix( 1:100, 1, 100 ), col = colramp(1000), axes=F )
#       axis( 2, at=c(0,1), c( min(n.map,na.rm=T), max(n.map,na.rm=T) ), las=2, tick=F, pos=-0.5 )  
#       box()

    
    par( mfrow = c(1,1) );  par( mar=c(5,6,4,5) )
        
    lim = c(1,preferences$dim.som1) + preferences$dim.som1*0.01*c(-1,1)
    plot( which( !is.na(n.map), arr.ind=T ), xlim=lim, ylim=lim, pch=16,
          axes=F, xlab="",ylab="", xaxs="i", yaxs="i", main=names(gs.def.list)[i],
          col = colramp(1000)[ ( na.omit( as.vector( n.map ) ) - min(n.map,na.rm=T) ) / max( 1, ( max(n.map,na.rm=T) - min(n.map,na.rm=T) ) )* 999 + 1 ],
          cex = 0.5 + na.omit( as.vector( n.map ) ) / max(n.map,na.rm=T) * 2.8 )
    
      title(sub=paste( "# features =", sum( gene.ids %in% gs.def.list[[ i ]]$Genes ) ),line=0)          
      title(sub=paste("chi-square p = ",round(chi.sq.p.value,2)),line=1)
      box()
    
    
    
    
    par(new=T, mar=c(1,0,0,0) );  layout( matrix( c(0,0,0,0,1,0,0,0,0), 3, 3 ), c( 1, 0.05, 0.02 ), c( 0.15, 0.3, 1 ) )
    
    image( matrix( 1:100, 1, 100 ), col = colramp(1000), axes=F )
      axis( 2, at=c(0,1), c( min(n.map,na.rm=T), max(n.map,na.rm=T) ), las=2, tick=F, pos=-0.5 )  
      box()    
    
    
    
          
    ### Smooth Population Map ###

    if( any( !is.na(n.map) ) )
    {                                         
      par( mfrow = c(1,1) );  par( mar=c(5,6,4,5) )

      coords = som.result$visual[ which( rownames(indata) %in% names( gene.ids[ which( gene.ids %in% gs.def.list[[ i ]]$Genes ) ] ) ), c(1,2), drop=F ]
      if( nrow(coords) == 1 )
        coords = rbind( coords, coords ) 

      smoothScatter(  coords+1 ,main=names(gs.def.list)[i], cex.main=2, xlim=c(1,preferences$dim.som1), ylim=c(1,preferences$dim.som1), xaxs="i", yaxs="i", axes=F, xlab="", ylab="", nrpoints=0 )
        title(sub=paste( "# features =", sum( gene.ids %in% gs.def.list[[ i ]]$Genes ), ", max =", max(n.map,na.rm=T) ),line=0)
    }


    dev.off()


  out.intervals = round( seq( 1, length(gs.def.list), length.out=25+1 ) )[-1]
  cat( paste( rep("#",length( which( out.intervals == i) ) ), collapse="" ) );  flush.console()
  }



  cat("|\n\n");  flush.console()





  ### stop parallel computing ###

#  try({ stopCluster(cl) }, silent=T )





