# Ecospatmap
A shiny web app to improve vizualisation and understanding map results (and projections) from ecospat group.
This shiny web app is a support of the article *Predicting current and future spatial patterns of nature’s contributions to people from species distribution models* published in Ecological Indicators (https://doi.org/10.1016/j.ecolind.2025.113528)

## About Ecospatmap
The shiny web app was developped under the v.1.7.5 (*Chang et al., 2023*) and is hosted by nginx via the computational group of the University of Lausanne.

In this respository you can find the code and data used to produce your own [Ecospatmap](https://ecospatmap.unil.ch/)

* categories: For the DEMO, we only loaded 66/315 files available on the website. These ratsers (TIFF format) are used to vizualize all individual Nature's Contributions to People (NCP) predicted from species distribution models (SDM) for current period and also for future conditions for three different approaches.

* SR: all TIFF format used to vizualize Species Richness prediction for current and future conditions (using binarized outputs)

* www: includes all the images and media used in the app and html script to support *app.R*

* app.R: the main script to run the shiny web app and open a local "Ecospatmap" profile

* lf.csv: Excel file to facilitate the selection of NCP rasters (stocked in categories folder) by reactive functions.

* lf-sr.csv: Excel file to facilitate the selection of SR rasters (stocked in SR folder) by reactive functions. 
