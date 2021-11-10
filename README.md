# Project 3: Coronavirus - Lauren Cohen, Christian Gallagher, Christopher Lee

## Investigation

The first subset of Safegraph data our group found interest in was all Medical Centers in Georgia.  Obviously, Coronavirus is and has been a topic of conversation for what feels like a lifetime.  A few of the popular talking points in the news concern the overfilling of hospital beds, and the lackluster vaccination rates in rural parts of the country.  From there, we explored additional data sets containing Covid testing sites, state population, and number of cases in the state per capita.

During the post-vaccine pandemic, is there a salient difference in hospital visits throughout Georgia, by county? Additionally, is the availability of Covid testing sites evenly distributed for all Georgians? Is there any noticeable relationship between number of covid cases and hospital visits?

### Cases + Visits - An Outlier

Our first plot attempt was to see if there was a noticeable relationship between number of Covid cases and average hospital visits by county.  In order to not make Fulton County and metro-Atlanta stick out like a sore thumb, we of course looked at per capita data.  The "hypothesis" is that the more per capita cases in a county, the larger number of hospital visits!

![](https://ibb.co/VN2Njh4)

This plot is a bit busy.  We were thinking the "brighter" the county, the larger the radius of visits.  Clearly, this didn't pan out.  The one noticeable outlier is Blairsville, in NE Georgia.  This outlier falls under the problem of low population, so it is much easier to display discrepancies when using per capita data.

### Additional Factors

Our next thought were the additional factors that could affect our data.  What if there is a discrepancy in the number of testing sites by county?  Would people of one county then be a positive test in the neighboring county?  This plot is to shine a light on the availability (or lackthereof) of testing sites for Georgians.

IMAGE 2

Wowza!  There are certainly some counties that are lacking in testing locations.  The counties that are obvious offenders are ....  Comparing this to our first plot though, there isn't much in common.  Most importantly, Blairsville is right along with the pack in terms of testing sites.

### Comparing Months, a Hiccup

Wanting to make sure our data is similar across months, we then compared our pots in a three-month span.  

IMAGE 3

At first glance, these seem similar enough!  But then there are some locations with no data for a whole month! Telfair County, for instance, has data for both August and September, but no data for July.  Similar to some of the Chipotle visit data, something might be a bit off with some of the Safegraph data.

### Additional Plot Attempts

These are two additional plots that are either unfinished, or do not provide any useful imformation.

IMAGE 1

This plot is an interactive version of our first plot, which could be of more value to an end user.

IMAGE 2

This plot is a modification of the Chipotle plot done in class, with average hospital visits in Georgia by day.  It's interesting that almost in a pattern, visits are low, then average, then high, average, low, etc.

## Tasks

1. Complete the data joing and munging in R and Python.
2. Complete the visualizations in R and Python.

- [X] Create an account with [SafeGraph](https://www.safegraph.com/academics)
- [X] Create a data investigation narrative or question that will drive your project.
- [X] Tell a story through time-series charts for your narrative.
- [X] Tell a story through spatial maps for your narrative.
- [X] Include a visualization that displays space and time in your narrative.
