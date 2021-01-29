args<-commandArgs(T);
input<-args[1]; 
output<-args[2];
png<-args[3]; 

Col=c("count","freq","cdr3nt","cdr3aa","v","d","j","VEnd","DStart","DEnd","JStart","pgen")
Data=read.table(input,header=1)[,Col]
pvalue=ppois(Data$count-1,sum(Data$count)*Data$pgen, lower.tail = F)
qvalue=p.adjust(pvalue,method = "bonferroni")
Status=qvalue
Status[is.na(qvalue)]='-'
Status[qvalue < 0.00001]='Amplified'
Status[qvalue >= 0.00001]='Silent'
Data=cbind(Data,pvalue,qvalue,Status)
write.table(Data,output,sep="\t",row.names=F,col.names=T,quote=F)

plotData=log10(Data[,c("pgen","freq")])
plotData=cbind(plotData,Status)
plotData=plotData[is.na(plotData$pgen)==F,]

LegendA=paste0("Amplified Clonotypes: ",table(Status)[2],"; Clonality: ",sum(Data$count[Status=='Amplified']))
LegendS=paste0("Slient Clonotypes: ",table(Status)[3],"; Clonality: ",sum(Data$count[Status=='Silent']))

library(ggplot2)
png(png,width=640,height=480)
ggplot(data=plotData,aes(x=pgen,y=freq,color=Status))+geom_point()+
  xlab("log10(pgen)")+
  ylab("log10(frequency)")+
  scale_color_manual(values=c("red","gray"),labels=c(LegendA,LegendS))+
  theme(legend.position=c(0,1),legend.justification=c(0,1))
dev.off()