# Automation and the Minimum Wage

### **WARNING**:

The CPS data (cps.csv) are a random sample of 4% of the full data set, which
has 70 million observations. Accordingly, the sample only has 2.8 million. 
This is for your convenience in having the code run more quickly.
However, estimates are far off that of the full sample and not statistically
significant. For the actual full results, see the end of the real
paper:
<https://anthonyfloresokc.myportfolio.com/raising-the-minimum-wage-slightly-increases-automation>

You can access the full data set here:
https://cps.ipums.org/cps-action/variables/group

Use the variables selected during importing [here](https://github.com/AnthonyOKC/automation-and-the-minimum-wage/blob/main/src/data-management/cps_clean_join_genvar.R) as a guide for which variables to checkout of IPUMS.

------------------------------------------------------------------------

## Requirements:

-- R 4.1.1

## Instructions:

#### (Automated)

-   RunAllCode.R: Run the entire analysis from start to finish,
    including the resulting .pdf. 
    
-   RunDirectory.R: Each folder in /src/ contains this file, which will
    run that section of code in the correct order.
    
**NOTE**: Using these scripts clears corresponding /out/ directories to ensure output is
produced by current code.


#### (Manual)

The following describes the order to run the analysis from start to
finish.

0) Run install_r_packages.R if first-time running analysis.
1) Clear output from corresponding ./out folders to ensure all output is new.
2) ./src/data-management
    1. rti_clean_join.R
    2. mw_clean_join_genvar.R
    3. cps_clean_join_genvar.R
3) ./src/analysis/
    1. compute_rti_rsh.R
    2. regression_aggregated_rsh.R
    3. regression_disaggregated_rsh.R
4) ./src/paper/
    1. Knit to PDF -> Automation-and-the-Minimum-Wage.Rmd

## Directory Guide:

-   ./ the Root Folder: The root directory.

-   ./src folder: This is the 'source' folder. It contains all of our
    code files we develop during our analysis and the original
    datasets we begin your analysis with.

-   ./out folder: This is the output directory. We will put anything
    that we create by running a R script. For example, it can contain
    new datasets we create by cleaning and merging our original data,
    saved regression results and saved figures or summary tables. The
    main point is that anything we can recreate by running R scripts
    will get saved here - whether they be 'temporary' or 'intermediate'
    outputs that will get used by another R script later in our project,
    or 'final' outputs that we will want to insert into a paper, report
    or slide deck.

-   ./sandbox folder: As we work through our project, we will want to
    explore new ideas and test out how to code them. While we play with
    these bits and pieces of code, we save them in the sandbox.
    Separating them from src means we know that R scripts in here are
    'under development'. When they are finalized, we can move them into
    src.

## Subfolders Guide:

-   data/ contains all of the project's original/raw data.

-   data-management/ contains all R scripts to clean and merge datasets
    together

-   data-specs/ contains any special parameterizations used in cleaning
    or analysis.

-   analysis/ contains all R scripts that are our main analysis. For
    example, our regression scripts

-   figures/ contains R scripts that produce figures. One script per
    figure.

-   tables/ contains R scripts that produce summary tables and
    regression tables. One script per table.
    
-   lib/ contains R scripts that contain functions that can be used more
    generally. For example helper functions that can be used in both
    data cleaning and analysis could be put here. So can scripts that
    contain functions that can be portable across multiple projects.

-   slides/ contains the Rmarkdown files to write up project results as
    a slide deck, i.e. the text of the slides.
