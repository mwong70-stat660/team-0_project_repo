*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/*
create macro variable with path to directory where this file is located,
enabling relative imports
*/
%let path=%sysfunc(tranwrd(%sysget(SAS_EXECFILEPATH),%sysget(SAS_EXECFILENAME),));

/*
execute data-prep file, which will generate final analytic dataset used to
answer the research questions below
*/
%include "&path.STAT660-01_s21-team-0_data_preparation.sas";


*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 3: What are the top five schools that experienced the biggest
increase in "Percent (%) Eligible Free (K-12)" between AY2014-15 and AY2015-16?

Rationale: This should help identify schools to consider for new outreach based
upon increasing child-poverty levels.

Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1415
to the column of the same name from frpm1516.

Limitations: Values of "Percent (%) Eligible Free (K-12)" equal to zero should
be excluded from this analysis, since they are potentially missing data values.
*/

title "Inspect Percent_Eligible_FRPM_K12 from frpm1415_public_schools";
proc means
        data=frpm1415_public_schools
        maxdec=1
        missing
        n /* number of observations */
        nmiss /* number of missing values */
        min q1 median q3 max  /* five-number summary */
        mean std /* two-number summary */
    ;
    var 
        Percent_Eligible_FRPM_K12
    ;
    label
        Percent_Eligible_FRPM_K12=" "
    ;
run;
title;

title "Inspect Percent_Eligible_FRPM_K12 from frpm1516_public_schools";
proc means
        data=frpm1516_public_schools
        maxdec=1
        missing
        n /* number of observations */
        nmiss /* number of missing values */
        min q1 median q3 max  /* five-number summary */
        mean std /* two-number summary */
    ;
    var 
        Percent_Eligible_FRPM_K12
    ;
    label
        Percent_Eligible_FRPM_K12=" "
    ;
run;
title;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Can "Percent (%) Eligible FRPM (K-12)" be used to predict the
proportion of high school graduates earning a combined score of at least 1500
on the SAT?

Rationale: This would help inform whether child-poverty levels are associated
with college-preparedness rates, providing a strong indicator for the types of
schools most in need of college-preparation outreach.

Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1415
to the column PCTGE1500 from sat15.

Limitations: Values of "Percent (%) Eligible Free (K-12)" and PCTGE1500 equal to
zero should be excluded from this analysis, since they are potentially missing
data values. The dataset sat15 also has two obvious encodings for missing
values of PCTGE1500, which will also need to be excluded.
*/

/* output frequencies of PCTGE1500 to a dataset for manual inspection */
proc freq
        data=sat15_public_schools
        noprint
    ;
    table
        PCTGE1500
        / out=sat15_PCTGE1500_frequencies
    ;
run;

/* use manual inspection to create bins to study missing-value distribution */
proc format;
    value $PCTGE1500_bins
        "*","NA"="Explicitly Missing"
        "0.00"="Potentially Missing"
        other="Valid Numerical Value"
    ;
run;

/* inspect study missing-value distribution */
title "Inspect PCTGE1500 from sat15_public_schools";
proc freq
        data=sat15_public_schools
    ;
    table
        PCTGE1500
        / nocum
    ;
    format
        PCTGE1500 $PCTGE1500_bins.
    ;
    label
        PCTGE1500="Percent of Students w/ SAT Scores Above 1500 (PCTGE1500)"
    ;
run;
title;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: What are the top ten schools were the number of high school
graduates taking the SAT exceeds the number of high school graduates completing
UC/CSU entrance requirements?

Rationale: This would help identify schools with significant gaps in
preparation specific for California's two public university systems, suggesting
where focused outreach on UC/CSU college-preparation might have the greatest
impact.

Note: This compares the column NUMTSTTAKR from sat15 to the column TOTAL from
gradaf15.

Limitations: Values of NUMTSTTAKR and TOTAL equal to zero should be excluded
from this analysis, since they are potentially missing data values.
*/

/* output frequencies of NUMTSTTAKR to a dataset for manual inspection */
proc freq
        data=sat15_public_schools
        noprint
    ;
    table
        NUMTSTTAKR
        / out=sat15_NUMTSTTAKR_frequencies
    ;
run;

/* use manual inspection to create bins to study missing-value distribution */
proc format;
    value $NUMTSTTAKR_bins
        "0"="Potentially Missing"
        other="Valid Numerical Value"
    ;
run;

/* inspect missing-value distribution */
title "Inspect PCTGE1500 from sat15_public_schools";
proc freq
        data=sat15_public_schools
    ;
    table
        NUMTSTTAKR
        / nocum
    ;
    format
        NUMTSTTAKR $NUMTSTTAKR_bins.
    ;
    label
        NUMTSTTAKR="Number of SAT Test-takers (NUMTSTTAKR)"
    ;
run;
title;


/* output frequencies of TOTAL to a dataset for manual inspection */
proc freq
        data=gradaf15_public_schools
        noprint
    ;
    table
        TOTAL
        / out=gradaf15_TOTAL_frequencies
    ;
run;

/* use manual inspection to create bins to study missing-value distribution */
proc format;
    value $TOTAL_bins
        "0"="Potentially Missing"
        other="Valid Numerical Value"
    ;
run;

/* inspect missing-value distribution */
title "Inspect TOTAL from gradaf15_public_schools";
proc freq
        data=gradaf15_public_schools
    ;
    table
        TOTAL
        / nocum
    ;
    format
        TOTAL $TOTAL_bins.
    ;
    label
        TOTAL="Number of UC/CSU-entrance-requirements completers (TOTAL)"
    ;
run;
title;
