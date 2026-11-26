--1A = raw data check
select		top 10
			SK_ID_CURR, TARGET, CODE_GENDER, NAME_INCOME_TYPE, OCCUPATION_TYPE, DAYS_BIRTH, DAYS_EMPLOYED,
			AMT_INCOME_TOTAL
from		stg_application_train; 

--1B= target, gender, occupation 
select		SK_ID_CURR, 
			CAST (target as int) as Target,
			case when CODE_GENDER = 'F' then 'Female'
				 when CODE_GENDER = 'M' then 'Male'
				 else 'Unknown'
				 end as Gender,
			ISNULL (occupation_type, 'Unknown') as Occupation
from		stg_application_train;

--1C= years employed
select		SK_ID_CURR, NAME_INCOME_TYPE, DAYS_EMPLOYED,
			case when DAYS_EMPLOYED = 365243 then Null
				 else round(-days_employed/ 365.0, 1)
				 end as Years_employed,
			case when DAYS_EMPLOYED = 365243 then 'Not employed'
				 else 'Employed'
				 end as employment_status
from		stg_application_train;

--1D= age and age group
select		SK_ID_CURR, DAYS_BIRTH, ABS( days_birth) / 365 as Age_years,
			case when ABS( days_birth) / 365 < 30 then '20-29'
				 when ABS( days_birth) / 365 < 40 then '30-39'
				 when ABS( days_birth) / 365 < 50 then '40-49'
				 when ABS( days_birth) / 365 < 60 then '50-59'
				 else '60+'
				 end as Age_group
from		stg_application_train; 

--1E= Income bracket
select		SK_ID_CURR, AMT_INCOME_TOTAL, 
			case when AMT_INCOME_TOTAL < 100000 then '1. Below 100k'
				 when AMT_INCOME_TOTAL < 150000 then '2. 100k-150k'
				 when AMT_INCOME_TOTAL < 200000 then '3. 150k-200k'
				 when AMT_INCOME_TOTAL < 300000 then '4. 200k-300k'
				 else '5. 300k and above' 
				 end as Income_bracket
from		stg_application_train; 

--1F= Compilation and view creation
DROP VIEW IF EXISTS dbo.v_application_clean;
GO

CREATE VIEW dbo.v_application_clean AS
SELECT
/*from 1B (target, gender, occupation)*/
			SK_ID_CURR as Loan_ID, 
			CAST (target as int) as Target,
			case when CODE_GENDER = 'F' then 'Female'
				 when CODE_GENDER = 'M' then 'Male'
				 else 'Unknown'
				 end as Gender,
			ISNULL (occupation_type, 'Unknown') as Occupation,

/*from 1C (years employed)*/
			case when DAYS_EMPLOYED = 365243 then Null
				 else round(-days_employed/ 365.0, 1)
				 end as Years_employed,
			case when DAYS_EMPLOYED = 365243 then 'Not employed'
				 else 'Employed'
				 end as employment_status,

/*from 1D (age)*/
			case when ABS( days_birth) / 365 < 30 then '20-29'
				 when ABS( days_birth) / 365 < 40 then '30-39'
				 when ABS( days_birth) / 365 < 50 then '40-49'
				 when ABS( days_birth) / 365 < 60 then '50-59'
				 else '60+'
				 end as Age_group,

/*from 1E (income bracket)*/
			case when AMT_INCOME_TOTAL < 100000 then '1. Below 100k'
				 when AMT_INCOME_TOTAL < 150000 then '2. 100k-150k'
				 when AMT_INCOME_TOTAL < 200000 then '3. 150k-200k'
				 when AMT_INCOME_TOTAL < 300000 then '4. 200k-300k'
				 else '5. 300k and above' 
				 end as Income_bracket,

/*EXTRA columns (not in 1B to 1E)*/
 NAME_CONTRACT_TYPE	 as Contract_type,
			case when FLAG_OWN_CAR = 'Y' then 'Yes' 
				 else 'No' 
				 end as Own_car,
			case when FLAG_OWN_REALTY = 'Y' then 'Yes' 
				 else 'No' 
				 end as Own_realty,

 AMT_INCOME_TOTAL as Income,  AMT_CREDIT as Credit,  AMT_ANNUITY as Annuity,  AMT_GOODS_PRICE as Goods_price, NAME_INCOME_TYPE as Income_type,
			case when NAME_INCOME_TYPE IN ('Student','Businessman','Maternity leave','Unemployed') then 'Other' 
			ELSE NAME_INCOME_TYPE 
			END  AS income_type_group,

NAME_EDUCATION_TYPE as Education, NAME_FAMILY_STATUS as Family_status, NAME_HOUSING_TYPE AS Housing_type,
			CAST(REGION_RATING_CLIENT AS INT) AS Region_rating
FROM dbo.stg_application_train;
GO

--Check if View worked.
select		count(*) as rows_in_view from v_application_clean;
select		* from v_application_clean;			


select		* from stg_bureau;
--2A check data
select		SK_ID_CURR, count (*) as Bureau_loans
from		stg_bureau
group by	SK_ID_CURR;


--2B create view
drop view if exists dbo.v_bureau_summary;
go 

create view dbo.v_bureau_summary as 
select		SK_ID_CURR as Loan_ID, count(*) as Bureau_loans, 
			sum(case when credit_active ='Active' then 1
					 else 0 end) as Bureau_active,
			sum(case when credit_active ='Closed' then 1 
					 else 0 end) as Bureau_closed,
			sum(case when credit_active ='bad debt' then 1
					 else 0 end) as Bureau_bad_debt,
			sum(try_cast(amt_credit_sum as float))		as Bureau_total_credit,
			sum(try_cast(amt_credit_sum_debt as float))	as Bureau_total_debt
from		stg_bureau
group by	SK_ID_CURR;
go

--2c check view created
select		* from v_bureau_summary;
select		count(*) as clients, sum(bureau_loans) as total_rows
from		v_bureau_summary;


select * from stg_previous_application; 
--3A create view of previous_application
Drop view	if exists dbo.v_prev_summary;
go

create view dbo.v_prev_summary as
select		SK_ID_CURR as Loan_ID, count(*) as Prev_apps,
			sum(case when name_contract_status ='approved' then 1 else 0 end) as Prev_approved,
			sum(case when name_contract_status ='refused' then 1 else 0 end) as Prev_refused,
			sum(case when name_contract_status ='canceled' then 1 else 0 end) as Prev_canceled
from		stg_previous_application
group by	SK_ID_CURR;
go

--3B check
select		* from v_prev_summary;
select		count(*), sum(prev_apps)
from		v_prev_summary;



--4A join
drop view if exists dbo.v_loan_flat;
go

create view dbo.v_loan_flat as 
select		a.*, 
			case when b.Loan_ID is null then 'No'
				 else 'Yes' end as Has_bureau_history,
			isnull (b.bureau_loans, 0)	as Bureau_loans,
			isnull (b.bureau_active, 0) as Bureau_active,
			isnull (b.bureau_closed, 0) as Bureau_closed,
			isnull (b.bureau_bad_debt, 0) as Bureau_bad_debt,
			b.bureau_total_credit, b.bureau_total_debt,
			case when p.Loan_ID is null then 'No'
				 else 'Yes' end as Has_prev_history,
			isnull (p.prev_apps, 0) as Prev_apps,
			isnull (p.prev_approved, 0) as Prev_approved,
			isnull (p.prev_refused, 0) as Prev_refused,
			isnull (p.prev_canceled, 0) as Prev_canceled,
			case when isnull (p.prev_refused, 0) > 0 then 'Yes'
				 else 'No' end as Ever_refused
from		v_application_clean a
left join	v_bureau_summary b	on a.Loan_ID= b.Loan_ID
left join	v_prev_summary p	on a.Loan_ID= p.Loan_ID;
go
