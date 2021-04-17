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

/* Sort schools by FRPM eligibility increase. */
proc sort
        data=cde_analytic_file
        out=cde_analytic_file_sorted
    ;
    by descending frpm_rate_change_2014_to_2015;
run;

title
"Top 5 Schools Experiencing the Biggest Increase in FRPM Eligibility Increase between AY2014-15 and AY2015-16."
;
proc print data=cde_analytic_file_sorted(obs=5);
    id School_Name;
    var frpm_rate_change_2014_to_2015;
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

title "Formal correlation analysis for FRPM Eligibility Rate and SAT Scores.";
proc corr
        data=cde_analytic_file
        nosimple
    ;
    var
        Percent_Eligible_FRPM_K12
        PCTGE1500
    ;
    where
        not(missing(Percent_Eligible_FRPM_K12))
        and
        not(missing(PCTGE1500))
    ;
run;
title;

title "Scatter Plot of FRPM Eligibility Rate and SAT Scores.";
proc sgplot data=cde_analytic_file;
    scatter
        x=Percent_Eligible_FRPM_K12
        y=PCTGE1500
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

/*
Sort schools by number of students taking the SAT exceeding the number of
students completing UC/CSU college-preparation coursework.
*/
proc sort
        data=cde_analytic_file
        out=cde_analytic_file_sorted
    ;
    by descending excess_sat_takers;
run;

title
"Top 10 Schools with more students taking the SAT than completing UC/CSU college-preparation coursework."
;
proc print data=cde_analytic_file_sorted(obs=10);
    id School_Name;
    var excess_sat_takers;
run;
title;
