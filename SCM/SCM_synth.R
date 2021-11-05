
# Set working directory

setwd('C:/Users/xps-seira/Dropbox/Statistics/P13/RScripts')
set.seed(39348)


# ---------------------------------------------------------------------------


# Functions

	#Jacknife resampling (mean)
jackknife.apply.mean <- function(xdata){
  jk <- jackknife(xdata, mean)
  results<-jk$jack.se
  return(results)  
}

	#Jacknife resampling (median)
jackknife.apply.med <- function(xdata){
  jk <- jackknife(xdata, median)
  results<-jk$jack.se
  return(results)  
}


	# Standarize function
std <- function(var ){
  standar<-scale(var)
  return(standar)
}

	# Install packages
instalar <- function(paquete) {
  if (!require(paquete,character.only = TRUE, 
               quietly = TRUE, 
               warn.conflicts = FALSE)) {
    install.packages(as.character(paquete), 
                     dependencies = TRUE, 
                     repos = "http://cran.us.r-project.org")
    library(paquete, 
            character.only = TRUE, 
            quietly = TRUE, 
            warn.conflicts = FALSE)
  }
}


paquetes <- c('dplyr', 'Synth', 'ggplot2', 'tidyr', 'reshape', 'matrixStats',
              'bootstrap', 'fpp')

lapply(paquetes, instalar)
rm(paquetes, instalar)


# ---------------------------------------------------------------------------


# Load packages

library(Synth)
library(dplyr)
library(ggplot2)
library(reshape)
library(matrixStats)
library(bootstrap)
library(fpp)


# ---------------------------------------------------------------------------


## While synth() can be used to construct synthetic control groups
## directly, by providing the X1, X0, Z1, and Z0 matrices, we strongly
## recommend to first run dataprep() to extract these matrices 
## and pass them to synth() as a single object

## The usual sequence of commands is:
## 1. dataprep() for matrix-extraction
## 2. synth() for the construction of the synthetic control group
## 3. synth.tab(), gaps.plot(), and path.plot() to summarize the results


# ---------------------------------------------------------------------------



# Load preprocessed data. Recall that the Household were grouped using 
# k-medians clusters according to its time series covariates in order to 
# speed up matching algorithm
panel<-read.csv('../DB/panel_hh_SDr_litros.csv') %>%
  mutate_if(is.factor, as.character) 


# Standardize dataset by Household
panel<-panel %>% group_by(id_domicilio) %>% 
  mutate_at(vars(matches('_kilos'),matches('_litros'),matches('_gasto')),std)
panel<-as.data.frame(panel)


# Initialize matrix for the 'effects'
gaps<-matrix(0,400,24)


# SCM
# For each treated household, we look for a synthetic control (among the pool donor) and save the 'Treatment effect'
for (i in c(1:400)){
  # create matrices from panel data that provide inputs for synth()
  dataprep.out1<-
    dataprep(
      foo = panel,
      predictors = c("nonSDr_gasto", "nonSDr_litros",
                     "SDr_gasto", "HCFr_gasto", "HCFr_kilos"),
      predictors.op = "mean",
      special.predictors = list(
        list("SDr_litros", 12, "mean"),
        list("SDr_litros", 11, "mean"),
        list("SDr_litros", 10, "mean"),
        list("SDr_litros", 9, "mean"),
        list("SDr_litros", 8, "mean"),
        list("SDr_litros", 7, "mean"),
        list("SDr_litros", 6, "mean"),
        list("SDr_litros", 5, "mean"),
        list("SDr_litros", 4, "mean"),
        list("SDr_litros", 3, "mean")
      ),
      dependent = "SDr_litros",
      unit.variable = "id_domicilio",
      time.variable = "time",
      treatment.identifier = i,
      controls.identifier = setdiff(c(401:500),1),
      time.predictors.prior = c(1:11),
      time.optimize.ssr = c(1:11),
      unit.names.variable = "hh_str",
      time.plot = 1:24
    )

  ## run the synth command to identify the weights
  ## that create the best possible synthetic 
  ## control unit for the treated.

  tryCatch({
    synth.out1 <- synth(dataprep.out1)
  }, error=function(e){})
  
  ## the output from synth opt 
  ## can be flexibly combined with 
  ## the output from dataprep to 
  ## compute other quantities of interest
  ## for example, the period by period 
  ## discrepancies between the 
  ## treated unit and its synthetic control unit
  
  gaps[i,]<- dataprep.out1$Y1plot-(
    dataprep.out1$Y0plot%*%synth.out1$solution.w
  ) 
}



# Drop treatment units that do not 'satisfy' (more specifically - whose
# parallel trend deviate much from zero) SCM assumptions (parallel trend)
avg_dev<-apply(gaps[,1:11], 1 , function(x) sum(x^2))  
gaps<-gaps[avg_dev<quantile(avg_dev,0.85),]


# Aggregated results
gaps_med<-apply(gaps,2,median)
gaps_mean<-apply(gaps,2,mean)
gaps_10<-colQuantiles(gaps, probs = 0.1)
gaps_90<-colQuantiles(gaps, probs = 0.9)


# Jacknife for CI construction
jck.mean<-apply(gaps, 2 , jackknife.apply.mean)  
jck.med<-apply(gaps, 2 , jackknife.apply.med)  


# Computation of CI
lower.jck.mean <- gaps_mean - jck.mean*abs(qt(0.0001, df=dim(gaps)[1]-1))
upper.jck.mean <- gaps_mean + jck.mean*abs(qt(0.0001, df=dim(gaps)[1]-1))

lower.jck.med <- gaps_med - jck.med*abs(qt(0.0001, df=dim(gaps)[1]-1))
upper.jck.med <- gaps_med + jck.med*abs(qt(0.0001, df=dim(gaps)[1]-1))


# Data frame for plotting
df_tr<-data.frame(gaps_med,gaps_mean, gaps_10, gaps_90, lower.jck.mean, upper.jck.mean, 
                  lower.jck.med, upper.jck.med)


# ---------------------------------------------------------------------------


# Plot
pdf('SD_scm_smooth.pdf')
ggplot() +
  ylim(-.7,0.6) +
  geom_ribbon(data = df_tr, aes(x=c(-11:12), ymin=lower.jck.med, ymax=upper.jck.med),fill = "grey80") +
  geom_ribbon(data = df_tr, aes(x=c(-11:12), ymin=lower.jck.mean, ymax=upper.jck.mean),fill = "grey80") +
  geom_vline(xintercept = 0 , color="red") +
  geom_hline(yintercept = 0 , color="red") +
  geom_line(data = df_tr, aes(x=c(-11:12), y=gaps_mean), color="black", size=1.1) +
  geom_line(data = df_tr, aes(x=c(-11:12), y=gaps_med), color="blue", size=1.0, linetype = "dashed") +
  ggtitle("SCM - SD") +
  xlab("Time") + ylab("Lts. (sd)")+
  theme_light()
dev.off()

save.image("SDr_scm_image.RData")
