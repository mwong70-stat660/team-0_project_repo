*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* 
[Dataset 1 Name] frpm1415

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data,
AY2014-15

[Experimental Unit Description] California public K-12 schools in AY2014-15

[Number of Observations] 10,393      

[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1415.xls
was downloaded and edited to produce file frpm1415-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School
Code" form a composite key, which together are equivalent to the unique id
column CDS_CODE in dataset gradaf15, and which together are also equivalent to
the unique id column CDS in dataset sat15.
*/
%let inputDataset1DSN = frpm1415_raw;
%let inputDataset1URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/frpm1415-edited.xls?raw=true
;
%let inputDataset1Type = XLS;


/*
[Dataset 2 Name] frpm1516

[Dataset Description] Student Poverty Free or Reduced Price Meals (FRPM) Data,
AY2015-16

[Experimental Unit Description] California public K-12 schools in AY2015-16

[Number of Observations] 10,453     

[Number of Features] 28

[Data Source] The file http://www.cde.ca.gov/ds/sd/sd/documents/frpm1516.xls
was downloaded and edited to produce file frpm1516-edited.xls by deleting
worksheet "Title Page", deleting row 1 from worksheet "FRPM School-Level Data",
reformatting column headers in "FRPM School-Level Data" to remove characters
disallowed in SAS variable names, and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsspfrpm.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School
Code" form a composite key, which together are equivalent to the unique id
column CDS_CODE in dataset gradaf15, and which together are also equivalent to
the unique id column CDS in dataset sat15.
*/
%let inputDataset2DSN = frpm1516_raw;
%let inputDataset2URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/frpm1516-edited.xls?raw=true
;
%let inputDataset2Type = XLS;


/*
[Dataset 3 Name] gradaf15

[Dataset Description] Graduates Meeting UC/CSU Entrance Requirements, AY2014-15

[Experimental Unit Description] California public K-12 schools in AY2014-15

[Number of Observations] 2,490

[Number of Features] 15

[Data Source] The file
http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2014-15&cCat=UCGradEth&cPage=filesgradaf.asp
was downloaded and edited to produce file gradaf15.xls by importing into Excel
and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sd/sd/fsgradaf09.asp

[Unique ID Schema] The column CDS_CODE is a unique id.
*/
%let inputDataset3DSN = gradaf15_raw;
%let inputDataset3URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/gradaf15.xls?raw=true
;
%let inputDataset3Type = XLS;


/*
[Dataset 4 Name] sat15

[Dataset Description] SAT Test Results, AY2014-15

[Experimental Unit Description] California public K-12 schools in AY2014-15

[Number of Observations] 2,331

[Number of Features] 12

[Data Source]  The file http://www3.cde.ca.gov/researchfiles/satactap/sat15.xls
was downloaded and edited to produce file sat15-edited.xls by opening in Excel
and setting all cell values to "Text" format

[Data Dictionary] http://www.cde.ca.gov/ds/sp/ai/reclayoutsat.asp

[Unique ID Schema] The column CDS is a unique id.
*/
%let inputDataset4DSN = sat15_raw;
%let inputDataset4URL =
https://github.com/stat697/team-0_project_repo/blob/master/data/sat15-edited.xls?raw=true
;
%let inputDataset4Type = XLS;


/* load raw datasets over the wire, if they don't already exist */
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                    method="get"
                    url="&url."
                    out=tempfile
                ;
            run;
            proc import
                    file=tempfile
                    out=&dsn.
                    dbms=&filetype.
                ;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 4;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets


/*
For frpm1415_raw, the columns County_Code, District_Code, and School_Code are
intended to form a composite key, so any rows corresponding to multiple values
should be removed. In addition, rows should be removed if they (a) are missing
values for any of the composite key columns or (b) have a School_Code value
corresponding to a non-school entity or a private school.

After running the proc sort step below, the new dataset frpm1415_public_schools
will have no duplicate/repeated unique id values, and all unique id values will
correspond to our experimental units of interest, which are California Public
K-12 schools. This means the columns County_Code, District_Code, and School_Code
in frpm1415_public_schools are guaranteed to form a composite key.
*/
proc sort
        nodupkey
        data=frpm1415_raw
        dupout=frpm1415_raw_dups
        out=frpm1415_public_schools
    ;
    where
        /* remove rows with missing composite key components */
        not(missing(County_Code))
        and
        not(missing(District_Code))
        and
        not(missing(School_Code))
        and
        /* remove rows for non-school entities and private schools */
        School_Code not in ("0000000","0000001")
    ;
    by
        County_Code
        District_Code
        School_Code
    ;
run;


/*
For frpm1516_raw, the columns County_Code, District_Code, and School_Code are
intended to form a composite key, so any rows corresponding to multiple values
should be removed. In addition, rows should be removed if they (a) are missing
values for any of the composite key columns or (b) have a School_Code value
corresponding to a non-school entity or a private school.

After running the proc sort step below, the new dataset frpm1516_public_schools
will have no duplicate/repeated unique id values, and all unique id values will
correspond to our experimental units of interest, which are California Public
K-12 schools. This means the columns County_Code, District_Code, and School_Code
in frpm1516_public_schools are guaranteed to form a composite key.
*/
proc sort
        nodupkey
        data=frpm1516_raw
        dupout=frpm1516_raw_dups
        out=frpm1516_public_schools
    ;
    where
        /* remove rows with missing composite key components */
        not(missing(County_Code))
        and
        not(missing(District_Code))
        and
        not(missing(School_Code))
        and
        /* remove rows for non-school entities and private schools */
        School_Code not in ("0000000","0000001")
    ;
    by
        County_Code
        District_Code
        School_Code
    ;
run;


/*
For gradaf15_raw, the column CDS_CODE is a primary key, so any rows
corresponding to multiple values should be removed. In addition, rows should be
removed if they (a) are missing values for CDS_CODE or (b) have a CDS_CODE
value corresponding to a non-school entity or a private school.

After running the proc sort step below, the new dataset gradaf15_public_schools
will have no duplicate/repeated unique id values, and all unique id values will
correspond to our experimental units of interest, which are California Public
K-12 schools. This means the column CDS_CODE in gradaf15_public_schools is
guaranteed to be a primary key.
*/
proc sort
        nodupkey
        data=gradaf15_raw
        dupout=gradaf15_raw_dups
        out=gradaf15_public_schools
    ;
    where
        /* remove rows with missing primary key */
        not(missing(CDS_CODE))
        and
        /* remove rows for non-school entities and private schools */
        substr(CDS_CODE,8,7) not in ("0000000","0000001")
    ;
    by
        CDS_CODE
    ;
run;


/*
For sat15_raw, the column CDS is a primary key, so any rows corresponding to
mulitple values should be removed. In addition, rows should be removed if they
(a) are missing values for CDS or (b) have a CDS value corresponding to a
non-school entity or a private school.

After running the proc sort step below, the new dataset sat15_public_schools
will have no duplicate/repeated unique id values, and all unique id values will
correspond to our experimental units of interest, which are California Public
K-12 schools. This means the column CDS in sat15_public_schools is guaranteed
to be a primary key.
*/
proc sort
        nodupkey
        data=sat15_raw
        dupout=sat15_raw_dups
        out=sat15_public_schools
    ;
    where
        /* remove rows with missing primary key */
        not(missing(CDS))
        and
        /* remove rows for non-school entities and private schools */
        substr(CDS,8,7) not in ("0000000","0000001")
    ;
    by
        CDS
    ;
run;


/*
Combine FRPM data vertically, combine composite key values into a primary key,
and compute year-over-year change in Percent_Eligible_FRPM_K12.
*/
data frpm1415_with_yoy_change;
    retain
        CDS_Code
    ;
    length
        CDS_Code $15.
        District_Name $75. /* address length mismatch in input datasets */
    ;
    set
        frpm1516_public_schools(in=ay2015_data_row)
        frpm1415_public_schools(in=ay2014_data_row)
    ;
    retain
        Percent_Eligible_FRPM_K12_1516
    ;
    by
        County_Code
        District_Code
        School_Code
    ;
    if
        ay2015_data_row=1
    then
        do;
            Percent_Eligible_FRPM_K12_1516 = Percent_Eligible_FRPM_K12;
        end;
    else if
        ay2014_data_row=1
        and
        Percent_Eligible_FRPM_K12 > 0
        and
        substr(School_Code,1,6) ne "000000"
    then
        do;
            CDS_Code = cats(County_Code,District_Code,School_Code);
            frpm_rate_change_2014_to_2015 =
                Percent_Eligible_FRPM_K12
                -
                Percent_Eligible_FRPM_K12_1516
            ;
            output;
        end;
run;


/*
Build final analytic dataset, including only the columns and minimal data-
cleaning/transformation needed to address each research question/objective in
corresponding data-analysis files.
*/
data cde_analytic_file;
    retain
        CDS_Code
        School_Name
        Percent_Eligible_FRPM_K12
        frpm_rate_change_2014_to_2015
        PCTGE1500
        excess_sat_takers
    ;
    keep
        CDS_Code
        School_Name
        Percent_Eligible_FRPM_K12
        frpm_rate_change_2014_to_2015
        PCTGE1500
        excess_sat_takers
    ;
    length
        CDS_Code $15.
        School_Name $100.
    ;
    merge
        frpm1415_with_yoy_change
        gradaf15_public_schools
        sat15_public_schools(rename=(CDS=CDS_Code PCTGE1500=PCTGE1500_character))
    ;
    by
        CDS_Code
    ;
    if
        not(missing(compress(PCTGE1500_character,'.','kd')))
    then
        do;
            PCTGE1500 = input(PCTGE1500_character,best12.2);
        end;
    else
        do;
            call missing(PCTGE1500);
        end;
    excess_sat_takers = input(NUMTSTTAKR,best12.) - input(TOTAL,best12.);
    if
        not(missing(CDS_Code))
        and
        not(missing(School_Name))
        and
        not(missing(School_Name))
    ;
run;


/*
Check cde_analytic_file for rows whose unique id values are repeated, missing,
or correspond to a non-school entity or a private school.

After executing the data step below, the resulting dataset should be empty,
meaning the match-merge above did not introduce any duplicates or malformed
unique ids.
*/
data cde_analytic_file_raw_bad_ids;
    set cde_analytic_file;
    by CDS_Code;

    if
        first.CDS_Code*last.CDS_Code = 0
        or
        missing(CDS_Code)
        or
        substr(CDS_Code,8,7) in ("0000000","0000001")
    then
        do;
            output;
        end;
run;
