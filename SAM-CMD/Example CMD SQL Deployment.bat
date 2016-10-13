rem ============================================================================
rem
rem  THIS FILE USED FOR CMX_ORS DATABASE INSTALLATION. 

rem ============================================================================
rem If you want to use different name for CMX_ORS DATABASE , 
rem please change the name of DEF_CMX_USER or type it during installation
rem  Note: All default parameters may be changed in this file or interactively during installation
rem
rem ============================================================================
@echo off

set def_cmx_user=cmx_ors
set def_host="localhost"
set def_cmx_db_path="C:\MSSQLDATA" 
set def_sa_user_name="sa"
set def_collation=Latin1_General_CI_AS


set question1=
set /p question1="Print Host name with MSSQL instance for CMX_ORS DB (%def_host%): "
if '%question1%'=='' goto :end_default1 
set host="%question1%"
goto :end_question1 
:end_default1
set host=%def_host%
:end_question1

set question2=
set /p question2="Print CMX_ORS DB path in double quotes (%def_cmx_db_path%): "
if '%question2%'=='' goto :end_default2 
set cmx_db_path=%question2%
goto :end_question2 
:end_default2
set cmx_db_path=%def_cmx_db_path%
:end_question2

set question3=
set /p question3="Print SA user name (%def_sa_user_name%): "
if '%question3%'=='' goto :end_default3 
set sa_user_name="%question3%"
goto :end_question3 
:end_default3
set sa_user_name=%def_sa_user_name%
:end_question3

:question4
set question4=
set /p question4="Print SA user password : "
if '%question4%'=='' goto :question4
set sa_user_pass="%question4%"
goto :end_question4 
:end_question4

set question5=
set /p question5="Print CMX_ORS user name (%def_cmx_user%): "
if '%question5%'=='' goto :end_default5
set cmx_user=%question5%
goto :end_question5 
:end_default5
set cmx_user=%def_cmx_user%
:end_question5

:question6
set question6=
set /p question6="Print CMX_ORS user password : "
if '%question6%'=='' goto :question6
set cmx_pass="%question6%"
goto :end_question6 
:end_question6


@echo on

sqlcmd -U %sa_user_name% -P %sa_user_pass% -S %host% -i create_cmx_db.sql -v db=%cmx_user% parameter1=%cmx_pass% parameter2=%cmx_db_path%  collation_name=%def_collation% -o create_%cmx_user%_db.log

@echo off

set cmx_user=
set cmx_pass=
set sa_user_name=
set sa_user_pass=
set host=
set cmx_db_path=
set collation_name=
set def_cmx_user=
set def_host=
set def_cmx_db_path=
set def_sa_user_name=
set def_collation=
set question1=
set question2=
set question3=
set question4=
set question5=
set question6=
set question7=

@echo on


rem ============================================================================
rem  INSTALLATION COMPLETED. PLEASE REWIEV LOG FILES FOR DETAILS.
rem ============================================================================

