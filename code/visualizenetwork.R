# documentation for network package at http://cran.r-project.org/web/packages/network/network.pdf
# This file generates graphs of 9 village networks.

set.seed(1)

library(statnet)
setwd("[PATH]/snf_code")

for(i in c(6, 12, 29, 34, 35, 46, 71, 74, 76)) {
	# import lending matrix
	mat = read.csv(paste("directed_adjacency_matrices/lendmoney",as.character(i),".csv", sep=""))
	mat = mat[,2:ncol(mat)]
	mat = as.matrix(mat)
	g = network(mat, directed=TRUE, matrix.type="adjacency")
	
	# import covariates
	X = read.csv(paste("lendmoney_graphs/Xcrs",as.character(i),".csv", sep=""))
	X[,1] = X[,1]+2 # for better plot colors
	X[,2] = X[,2]+1
	g %v% "sex" = X[,1]
	g %v% "relig" = X[,2]
	g %v% "caste" = X[,3]
	#get.vertex.attribute(g,"relig")
	
	# import family relations matrix
	zmat = read.csv(paste("directed_adjacency_matrices/rel",as.character(i),".csv", sep=""))
	zmat = zmat[,2:ncol(zmat)]
	zmat = as.matrix(zmat)
	z = network(zmat, directed=FALSE, matrix.type="adjacency")
	zmat = zmat + 3 # better colors
	g %e% "family" = zmat
	
	# specify one layout for all graphs (see layout.R in the network package)
	n = dim(mat)[1]
	niter = 500
  	max.delta = n
  	area = n^2
  	cool.exp = 3
  	repulse.rad = area*n
    tempa<-sample((0:(n-1))/n)
    seed.coord = matrix(NA, length(tempa), 2)
    seed.coord[,1] = n/(2*pi)*sin(2*pi*tempa)
    seed.coord[,2] = n/(2*pi)*cos(2*pi*tempa)
    
    network.layout.fm<-function(d, layout.par){
  		d<-d|t(d)  
  		layout<-.C("network_layout_fruchtermanreingold_R", as.integer(d), as.double(n), as.integer(niter), as.double(max.delta), as.double(area), as.double(cool.exp), as.double(repulse.rad), x=as.double(seed.coord[,1]), y=as.double(seed.coord[,2]), PACKAGE="network")
  	#Return the result
  		cbind(layout$x,layout$y)
	}

	# graph lending network
	png(filename = paste("lendmoney_graphs/lendmoney",as.character(i),".png",sep=""), width=700, height=700)
	plot(g, mode="fm")
	dev.off()
	
	# graph family network
	png(filename = paste("lendmoney_graphs/family",as.character(i),".png",sep=""), width=700, height=700)
	plot(z, mode="fm")
	dev.off()
	
	# graph lending network by family
	png(filename = paste("lendmoney_graphs/v",as.character(i),"_family.png",sep=""), width=700, height=700)
	plot(g, mode="fm", displayisolates = TRUE, edge.col = "family")
	legend("bottomleft",fill=3:4,legend=c("not related","related"),cex=0.75)
	dev.off()
	
	# graph lending network by sex
	png(filename = paste("lendmoney_graphs/v",as.character(i),"_sex.png",sep=""), width=700, height=700)
	plot(g, mode="fm", displayisolates = TRUE, vertex.col = "sex", vertex.cex = 0.7)
	legend("bottomleft",fill=2:3,legend=c("male","female"),cex=0.75)
	dev.off()
	
	# graph lending network by religion
	png(filename = paste("lendmoney_graphs/v",as.character(i),"_relig.png",sep=""), width=700, height=700)
	plot(g, mode="fm", displayisolates = TRUE, vertex.col = "relig", vertex.cex = 0.7)
	legend("bottomleft",fill=2:4,legend=c("hindu", "muslim", "christian"),cex=0.75)
	dev.off()
	
	# graph lending network by caste
	png(filename = paste("lendmoney_graphs/v",as.character(i),"_caste.png",sep=""), width=700, height=700)
	plot(g, mode="fm", displayisolates = TRUE, vertex.col = "caste", vertex.cex = 0.7)
	legend("bottomleft",fill=2:4,legend=c("general", "OBC", "scheduled"),cex=0.75)
	dev.off()
	
}

# for creating grayscale image in the paper
set.seed(1)
i=71
	# import lending matrix
	mat = read.csv(paste("directed_adjacency_matrices/lendmoney",as.character(i),".csv", sep=""))
	mat = mat[,2:ncol(mat)]
	mat = as.matrix(mat)
	g = network(mat, directed=TRUE, matrix.type="adjacency")
	
	# import covariates
	X = read.csv(paste("lendmoney_graphs/Xcrs",as.character(i),".csv", sep=""))
	
	# recode colors
	# colors()
	x = matrix(data = NA, nrow = dim(X)[1], ncol=1)
	for(j in 1:dim(X)[1]){
		if(X[j,3]==2) {x[j,1]=colors()[24]}
		if(X[j,3]==3) {x[j,1]=colors()[321]}
		if(X[j,3]==4) {x[j,1]=colors()[1]}	
	}
	
	# associate caste with adjacency matrix
	g %v% "caste" = X[,3]
	
	# specify one layout for all graphs (see layout.R in the network package)
	n = dim(mat)[1]
	niter = 500
  	max.delta = n
  	area = n^2
  	cool.exp = 3
  	repulse.rad = area*n
    tempa<-sample((0:(n-1))/n)
    seed.coord = matrix(NA, length(tempa), 2)
    seed.coord[,1] = n/(2*pi)*sin(2*pi*tempa)
    seed.coord[,2] = n/(2*pi)*cos(2*pi*tempa)
    
    network.layout.fm<-function(d, layout.par){
  		d<-d|t(d)  
  		layout<-.C("network_layout_fruchtermanreingold_R", as.integer(d), as.double(n), as.integer(niter), as.double(max.delta), as.double(area), as.double(cool.exp), as.double(repulse.rad), x=as.double(seed.coord[,1]), y=as.double(seed.coord[,2]), PACKAGE="network")
  	#Return the result
  		cbind(layout$x,layout$y)
	}
	
	# graph lending network by caste
	png(filename = paste("lendmoney_graphs/v",as.character(i),"_caste_grayscale.png",sep=""), width=700, height=700)
	plot(g, mode="fm", displayisolates = TRUE, vertex.col = x, vertex.cex = 0.7)
	legend("bottomleft",fill=c(colors()[24], colors()[321], colors()[1]),legend=c("general", "OBC", "scheduled"),cex=0.75)
	dev.off()
