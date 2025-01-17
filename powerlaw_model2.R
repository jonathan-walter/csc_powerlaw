
require(tidyverse)
require(lmodel2)

rm(list=ls())

# data
csc <- read.csv("./data/pcl_output_20201109.csv") 
#pft <- read.csv("neon_pft_plots.csv")
csc$pft[csc$pft == "BDF"] <- "DBF"

# 
unique(csc$siteID)

# filters out plots that don't match criteria
csc %>%
  filter(cover.fraction > 25) %>%
  filter(can.max.ht < 50) %>%
  filter(management == "unmanaged") %>%
  filter(disturbance == "") %>%
  filter(plotID != "?" & plotID != "") %>%
  select(siteID, plotID, transect.length, pft, moch, can.max.ht, rugosity, 
         enl, fhd) %>%
  group_by(plotID, siteID, pft) %>%
  summarise_at(.vars = vars(moch, can.max.ht, rugosity, enl, fhd),
               .funs = "mean") %>%
  data.frame() -> cst

# cleans up naming conventions
names(cst) <- gsub(x = names(cst), pattern = "\\.", replacement = "_")  


# builds list of sites
cst %>%
  group_by(siteID) %>%
  summarize(plots = n_distinct(plotID)) %>%
  data.frame()  -> site.table

# list of pfts
pft.table <- data.frame(cst$siteID, cst$pft)

# bring in site metadata
site.meta <- read.csv("./data/pcl_site_metadata_powerlaw.csv")

# merge for map making
site.table <- merge(site.table, site.meta)


### analyses with model 2 regression -----------------------------------------------------------

hist(log10(cst$moch))
hist(log10(cst$can_max_ht))
hist(log10(cst$rugosity))
hist(log10(cst$enl))
hist(log10(cst$fhd))

logcst <- cst
logcst$moch <- log10(cst$moch)
logcst$can_max_ht <- log10(cst$can_max_ht)
logcst$rugosity <- log10(cst$rugosity)
logcst$enl <- log10(cst$enl)
logcst$fhd <- log10(cst$fhd)


## USE RESULTS from RMA METHOD; see https://cran.r-project.org/web/packages/lmodel2/vignettes/mod2user.pdf

## Combined PFTs

rug_cmh <- lmodel2(rugosity ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst,
                nperm=1000)
enl_cmh <- lmodel2(enl~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst,
                   nperm=1000)
fhd_cmh <- lmodel2(fhd ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst,
                   nperm=1000)
rug_moch <- lmodel2(rugosity ~ moch, range.x = "interval", range.y = "interval", data=logcst,
                   nperm=1000)
enl_moch <- lmodel2(enl~ moch, range.x = "interval", range.y = "interval", data=logcst,
                   nperm=1000)
fhd_moch <- lmodel2(fhd ~ moch, range.x = "interval", range.y = "interval", data=logcst,
                   nperm=1000)


results <- rbind(cbind(rug_cmh$regression.results[c(1,4),], rug_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(enl_cmh$regression.results[c(1,4),], enl_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_cmh$regression.results[c(1,4),], fhd_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(rug_moch$regression.results[c(1,4),], rug_moch$confidence.intervals[c(1,4),-1]),
                 cbind(enl_moch$regression.results[c(1,4),], enl_moch$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_moch$regression.results[c(1,4),], fhd_moch$confidence.intervals[c(1,4),-1])
                 )
                 


## PFT == DBF

logcst.dbf <- logcst[logcst$pft == "DBF",]

rug_cmh <- lmodel2(rugosity ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.dbf,
                   nperm=1000)
enl_cmh <- lmodel2(enl~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.dbf,
                   nperm=1000)
fhd_cmh <- lmodel2(fhd ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.dbf,
                   nperm=1000)
rug_moch <- lmodel2(rugosity ~ moch, range.x = "interval", range.y = "interval", data=logcst.dbf,
                    nperm=1000)
enl_moch <- lmodel2(enl~ moch, range.x = "interval", range.y = "interval", data=logcst.dbf,
                    nperm=1000)
fhd_moch <- lmodel2(fhd ~ moch, range.x = "interval", range.y = "interval", data=logcst.dbf,
                    nperm=1000)


results <- rbind(results,
                 cbind(rug_cmh$regression.results[c(1,4),], rug_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(enl_cmh$regression.results[c(1,4),], enl_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_cmh$regression.results[c(1,4),], fhd_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(rug_moch$regression.results[c(1,4),], rug_moch$confidence.intervals[c(1,4),-1]),
                 cbind(enl_moch$regression.results[c(1,4),], enl_moch$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_moch$regression.results[c(1,4),], fhd_moch$confidence.intervals[c(1,4),-1])
)

## PFT == MF

logcst.mf <- logcst[logcst$pft == "MF",]

rug_cmh <- lmodel2(rugosity ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.mf,
                   nperm=1000)
enl_cmh <- lmodel2(enl~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.mf,
                   nperm=1000)
fhd_cmh <- lmodel2(fhd ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.mf,
                   nperm=1000)
rug_moch <- lmodel2(rugosity ~ moch, range.x = "interval", range.y = "interval", data=logcst.mf,
                    nperm=1000)
enl_moch <- lmodel2(enl~ moch, range.x = "interval", range.y = "interval", data=logcst.mf,
                    nperm=1000)
fhd_moch <- lmodel2(fhd ~ moch, range.x = "interval", range.y = "interval", data=logcst.mf,
                    nperm=1000)

results <- rbind(results,
                 cbind(rug_cmh$regression.results[c(1,4),], rug_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(enl_cmh$regression.results[c(1,4),], enl_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_cmh$regression.results[c(1,4),], fhd_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(rug_moch$regression.results[c(1,4),], rug_moch$confidence.intervals[c(1,4),-1]),
                 cbind(enl_moch$regression.results[c(1,4),], enl_moch$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_moch$regression.results[c(1,4),], fhd_moch$confidence.intervals[c(1,4),-1])
)


## PFT == ENF

logcst.enf <- logcst[logcst$pft == "ENF",]

rug_cmh <- lmodel2(rugosity ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.enf,
                   nperm=1000)
enl_cmh <- lmodel2(enl~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.enf,
                   nperm=1000)
fhd_cmh <- lmodel2(fhd ~ can_max_ht, range.x = "interval", range.y = "interval", data=logcst.enf,
                   nperm=1000)
rug_moch <- lmodel2(rugosity ~ moch, range.x = "interval", range.y = "interval", data=logcst.enf,
                    nperm=1000)
enl_moch <- lmodel2(enl~ moch, range.x = "interval", range.y = "interval", data=logcst.enf,
                    nperm=1000)
fhd_moch <- lmodel2(fhd ~ moch, range.x = "interval", range.y = "interval", data=logcst.enf,
                    nperm=1000)


results <- rbind(results,
                 cbind(rug_cmh$regression.results[c(1,4),], rug_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(enl_cmh$regression.results[c(1,4),], enl_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_cmh$regression.results[c(1,4),], fhd_cmh$confidence.intervals[c(1,4),-1]),
                 cbind(rug_moch$regression.results[c(1,4),], rug_moch$confidence.intervals[c(1,4),-1]),
                 cbind(enl_moch$regression.results[c(1,4),], enl_moch$confidence.intervals[c(1,4),-1]),
                 cbind(fhd_moch$regression.results[c(1,4),], fhd_moch$confidence.intervals[c(1,4),-1])
)



info <- data.frame(x = rep(rep( rep(c("cmh", "moch"), each=3), 4), each=2),
                   y = rep(rep( rep(c("rug","enl","fhd"), 2), 4), each=2),
                   pft = rep(c("all","DBF","MF","ENF"), each=12)

)

resuts <- cbind(info, results)

write.csv(results, "powerlaw_RMA_vs_OLS.csv", row.names=FALSE)
