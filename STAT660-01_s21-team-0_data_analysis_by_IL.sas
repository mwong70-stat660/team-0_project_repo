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

title1 justify=left
'Question 1 of 3: What are the top five California public K-12 schools experiencing the biggest increase in Free/Reduced-Price Meal (FRPM) Eligibility Rates between AY2014-15 and AY2015-16?'
;

title2 justify=left
'Rationale: This should help identify schools to consider for new outreach based upon increasing child-poverty levels.'
;

footnote1 justify=left
"Of the five schools with the greatest increases in percent eligible for free/reduced-price meals between AY2014-15 and AY2015-16, the percentage point increase ranges from about 75% to about 79%."
;

footnote2 justify=left
"These are significant demographic shifts for a community to experience, so further investigation should be performed to ensure no data errors are involved."
;

footnote3 justify=left
"However, assuming there are no data issues underlying this analysis, possible explanations for such large increases include changing CA demographics and recent loosening of the rules under which students qualify for free/reduced-price meals."
;

proc print
        data=cde_analytic_file_sorted(obs=5)
        label
    ;
    id
        School_Name
    ;
    var
        frpm_rate_change_2014_to_2015
    ;
    label
        School_Name="School Name"
        frpm_rate_change_2014_to_2015="FRPM Eligibility Rate Change from AY2014 to AY2015"
    ;
    format
        frpm_rate_change_2014_to_2015 percent10.1
    ;
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Note: This compares the column "Percent (%) Eligible Free (K-12)" from frpm1415
to the column PCTGE1500 from sat15.

Limitations: Values of "Percent (%) Eligible Free (K-12)" and PCTGE1500 equal to
zero should be excluded from this analysis, since they are potentially missing
data values. The dataset sat15 also has two obvious encodings for missing
values of PCTGE1500, which will also need to be excluded.
*/

title1 justify=left
'Research Question 2 of 3: Can Free/Reduced-Price Meal (FRPM) Eligibility Rates be used to predict the proportion of high school graduates earning a combined score of at least 1500 on the SAT in AY2014 at California public K-12 schools?'
;

title2 justify=left
'Rationale: This would help inform whether child-poverty levels are associated with college-preparedness rates, providing a strong indicator for the types of schools most in need of college-preparation outreach.'
;
title3 justify=left
'Correlation analysis for Percent_Eligible_FRPM_K12 and PCTGE1500'
;

footnote1 justify=left
"Assuming the variables are normally distributed, the above inferential analysis shows that there is a fairly strong negative correlation between student poverty and SAT scores in AY2014-15, with lower-poverty schools much more likely to have high proportions of students with combined SAT scores exceeding 1500."
;

footnote2 justify=left
"In particular, there is a statistically significant correlation with high confidence level since the p-value is less than 0.001, and the strength of the relationship between these variables is approximately -85%, on a scale of -1 to +1."
;

footnote3 justify=left
"Possible explanations for this correlation include child-poverty rates tending to be higher at schools with lower overall academic performance and quality of instruction. In addition, students in non-impoverished conditions are more likely to have parents able to pay for SAT preparation, confirming that outreach would be most effective at high-needs schools."
;

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
    label
        Percent_Eligible_FRPM_K12="FRPM Eligibility Rate in AY2014"
        PCTGE1500="Percent of Students Earning 1500 or higher on the SAT"
    ;
run;

/* clear titles/footnotes */
title;
footnote;


title1
'Plot illustrating the negative correlation between FRPM Eligibility Rate and earning high SAT scores'
;

footnote1
"In the above plot, we can see how earning high SAT scores tends to decrease as FRPM Eligibility Rates increase."
;

proc sgplot data=cde_analytic_file;
    scatter
        x=Percent_Eligible_FRPM_K12
        y=PCTGE1500
    ;
    label
        Percent_Eligible_FRPM_K12="FRPM Eligibility Rate in AY2014 (Percent_Eligible_FRPM_K12)"
        PCTGE1500="Percent of Students Earning 1500 or higher on the SAT (PCTGE1500)"
    ;
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
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

title1 justify=left
'Research Question 3 of 3: What are the top ten California public K-12 schools were the number of high school graduates taking the SAT exceeds the number of high school graduates completing UC/CSU entrance requirements?'
;

title2 justify=left
"Rationale: This would help identify schools with significant gaps in preparation specific for California's two public university systems, suggesting where focused outreach on UC/CSU college-preparation might have the greatest impact."
;

footnote1 justify=left
"All ten schools listed appear to have extremely large numbers of 12th-graders graduating who have completed the SAT but not the coursework needed to apply for the UC/CSU system, with differences ranging from 148 to 282."
;

footnote2 justify=left
"These are significant gaps in college-preparation, with some of the percentages suggesting that schools have a college-going culture not aligned with UC/CSU-going. Given the magnitude of these numbers, further investigation should be performed to ensure no data errors are involved."
;

footnote3 justify=left
"However, assuming there are no data issues underlying this analysis, possible explanations for such large numbers of 12th-graders completing only the SAT include lack of access to UC/CSU-preparatory coursework, as well as lack of proper counseling for students early enough in high school to complete all necessary coursework. This again confirms that outreach would be most effective at high-needs schools."
;

proc print
        data=cde_analytic_file_sorted(obs=10)
        label
    ;
    id
        School_Name
    ;
    var
        excess_sat_takers
    ;
    label
        School_Name="School Name"
        excess_sat_takers="Number of SAT Takers Exceeding Number of UC/CSU college-preparation completers"
    ;
run;

/* clear titles/footnotes */
title;
footnote;
