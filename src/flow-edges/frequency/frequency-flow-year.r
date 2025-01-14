library(ggplot2) 

### histogram/frequency
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-degree.csv")
df <- data.frame(flow$cities, flow$count)

# ggplot(df, aes(x = flow$cities, y = flow$count, col = 'blue')) + geom_line()
# ggplot(df, aes(x = flow$cities, y = flow$count, col = 'blue')) + geom_point()
# ggplot(df, aes(x = flow$cities, y = flow$count, col = 'blue')) + geom_line() + geom_point()
ggplot(data=df, aes(x = flow$cities, y = flow$count)) + geom_bar(stat="identity")


###
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-degree-histogram.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-1995.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-1985.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-1975.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-2005.csv")
df <- data.frame(log(flow$count), flow$freq)
ggplot(df, aes(x = flow$freq, y = log(flow$count), col = 'blue')) + 
    geom_point()
ggplot(df, aes(x = flow$freq, y = log(flow$count), col = 'blue')) + 
    geom_line() + 
    geom_point()
ggplot(df, aes(x = flow$count, y = flow$freq, col = 'blue')) + 
    geom_line() + 
    geom_point()
ggplot(data=df, aes(x = flow$count, y = flow$freq)) + 
    geom_bar(stat="identity")

###
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/frequency/frequency-flow-year-degree-histogram-pos.csv")
df <- data.frame(flow$count, flow$freq)
ggplot(df, aes(x = flow$count, y = flow$freq, col = 'blue')) + 
    geom_line() + 
    geom_point()
ggplot(data=df, aes(x = flow$count, y = flow$freq)) + 
    geom_bar(stat="identity")

### TOP 10
library(ggplot2)
library(reshape2)
library(plyr)
library(scales)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/frequency/frequency-flow-year-phd-top-city.csv")
row.names(flow) <- flow$cities
# flow <- flow[,2:84]
flow <- flow[,2:80]
flow_matrix <- data.matrix(flow)
# dat2 <- melt(flow_matrix, id.var = "X1")
dat2 <- melt(log(flow_matrix+1), id.var = "X1")
# https://gist.github.com/dsparks/3710171
dat2$Var1 <- factor(dat2$Var1, names(sort(with(dat2, by(value, Var1, sum)))))
# dat2$Var1 <- factor(dat2$Var1, levels(dat2$Var1))
# dat2 <- melt(scale(flow_matrix), id.var = "X1")
# dat2 <- melt(rescale(scale(flow_matrix)), id.var = "X1")
# dat2$value[43:49] = 0
p <- ggplot(dat2, aes(as.factor(Var2), Var1, group=Var1)) +
    geom_tile(aes(fill = value)) + 
    scale_fill_gradient(low = "white", high = "steelblue")
print(p)
p <- ggplot(dat2, aes(as.factor(Var1), Var2, group=Var2)) +
    geom_tile(aes(fill = value)) + 
    geom_text(aes(fill = dat2$value, label = round(dat2$value, 1))) +
    ggtitle("Mobilidade entre os continentes")+
    scale_fill_gradient(low = "white", high = "steelblue")
print(p)


### TOP 10
library(ggplot2)
library(reshape2)
file <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/frequency/frequency-flow-year-phd-top-city.csv", sep=",",header=T, check.names = FALSE)
row.names(file) <- file$cities
flow <- file[,2:80]
flow_matrix <- data.matrix(flow)
# dat <- melt(flow_matrix, id.var = "X1")
dat <- melt(log(flow_matrix+1), id.var = "X1")
dat$valor <- replace(dat$value, dat$value==-Inf, 0)
# dat$Var2 <- replace(dat$Var2, dat$Var2%%10!=0, '')
# names(dat)
# colnames(dat)
# colnames(dat) <- c("city", "year","value")
ggplot(dat, aes(as.factor(Var2), Var1, group=Var1))+
    geom_tile(aes(fill = valor))+
    # scale_fill_gradient(low = "white", high = "red")+
    scale_fill_gradient(low='white', high='grey20')+
    # xlab("years") + ylab("TOP cities")+ggtitle("Evolution of phd")+
    xlab("ano") + ylab("cidade")+
    theme(
        title=element_text(size=14,face="bold"), 
        axis.text=element_text(size=14,face="bold"), 
        axis.title=element_text(size=14,face="bold")#,
        # axis.text.x=element_text(angle=-90)
    )+
    scale_x_discrete(breaks=seq(1930, 2008, 10))+
  	scale_y_discrete(limits=c("brasilia","guarulhos","recife","florianopolis","curitiba","belo horizonte","bauru","porto alegre","campinas","rio de janeiro","sao paulo"))

