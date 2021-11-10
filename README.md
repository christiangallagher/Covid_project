# Project 3: Coronavirus - Lauren Cohen, Christian Gallagher, Christopher Lee

## Investigation

The first subset of Safegraph data our group found interest in was all Medical Centers in Georgia.  Obviously, Coronavirus is and has been a topic of conversation for what feels like a lifetime.  A few of the popular talking points in the news concern the overfilling of hospital beds, and the lackluster vaccination rates in rural parts of the country.  From there, we explored additional data sets containing Covid testing sites, state population, and number of cases in the state per capita.

During the post-vaccine pandemic, is there a salient difference in hospital visits throughout Georgia, by county? Additionally, is the availability of Covid testing sites evenly distributed for all Georgians? Is there any noticeable relationship between number of covid cases and hospital visits?

### Cases + Visits - An Outlier

Our first plot attempt was to see if there was a noticeable relationship between number of Covid cases and average hospital visits by county.  In order to not make Fulton County and metro-Atlanta stick out like a sore thumb, we of course looked at per capita data.  The "hypothesis" is that the more per capita cases in a county, the larger number of hospital visits!

IMAGE

This plot is a bit busy.  We were thinking the "brighter" the county, the larger the radius of visits.  Clearly, this didn't pan out.  The one noticeable outlier is Blairsville, in NE Georgia.  This outlier falls under the problem of low population, so it is much easier to display discrepancies when using per capita data.

### Additional Factors

Our next thought 

- [Core Places data dictionary](https://docs.safegraph.com/docs/core-places)
- [Geometry data dictionary](https://docs.safegraph.com/docs/geometry-data)
- [Patterns data dictionary](https://docs.safegraph.com/docs/monthly-patterns)
- [KSUDS SafeGraph Data](https://github.com/KSUDS/safegraph_data)

### SafeGraph Packages

- [SafeGraphR](https://safegraphinc.github.io/SafeGraphR/) and [Github repo](https://github.com/SafeGraphInc/SafeGraphR)
- [Safegraph_py](https://colab.research.google.com/drive/1V7hnyYuY_dUXQEPkCMZkgMuBFQV4iA_4?usp=sharing) and [Github repo](https://github.com/SafeGraphInc/safegraph_py)

### Spatial Packages

- [R: sf](https://r-spatial.github.io/sf/)
- [Python: GeoPandas](https://geopandas.org/docs.html)

## Tasks

1. Complete the data joing and munging in R and Python.
2. Complete the visualizations in R and Python.

- [X] Create an account with [SafeGraph](https://www.safegraph.com/academics)
- [X] Create a data investigation narrative or question that will drive your project.
- [X] Tell a story through time-series charts for your narrative.
- [X] Tell a story through spatial maps for your narrative.
- [X] Include a visualization that displays space and time in your narrative.
