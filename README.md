# Loan-Default-Risk-Analytics-SQL-Server-Power-BI
End-to-end analysis of 307,511 loan applications to find which borrower profiles are linked to payment difficulties. Raw data was cleaned in SQL Server and presented in a 3-page interactive Power BI dashboard.

## 1. Project Overview

**Business problem:** A lender needs to know which applicants are more likely to have trouble repaying a loan, so it can price risk and make approval decisions with evidence.

**What this project does:**
- Cleans and combines 3 raw tables (current applications, external credit history, previous applications) using SQL views.
- Builds a Power BI dashboard that lets a risk manager filter the portfolio and compare default rates across age, income, occupation, credit history and more.
- Includes a drillthrough page to look closely at any segment, such as one occupation or age group.

**Definition used:** *Default* means a client flagged with payment difficulties. The overall rate is **8.07%** (24,825 of 307,511 loans).

## 2. Dataset

Source: [Home Credit Default Risk on Kaggle](https://www.kaggle.com/c/home-credit-default-risk/data). Three of the seven files were used.

| Table | Rows | What it holds |
|---|---|---|
| `application_train` | 307,511 | One row per loan application: borrower details, loan amount, income, and the `TARGET` flag (1 = payment difficulties) |
| `bureau` | 1,716,428 | Credit accounts the client held with other lenders (status, credit amount, debt) |
| `previous_application` | 1,670,214 | Earlier applications to Home Credit (approved, refused, canceled) |

## 3. Tools Used

| Tool | Used for |
|---|---|
| SQL Server Express + SSMS | Importing the CSVs, profiling, cleaning views, validation checks |
| T-SQL | `CASE WHEN`, `TRY_CAST`, `ISNULL`, `GROUP BY`, `LEFT JOIN`, conditional aggregation |
| Power BI Desktop | Dashboard, slicers, bookmarks, drillthrough, AI visuals |
| DAX | KPI measures and calculated band columns |  

## 4. Data Cleaning (SQL)
Raw tables were cleaned with SQL views using 9 documented business rules, for example:
- Placeholder values fixed (gender `XNA`, employment `365243`) and blank occupations set to `Unknown`.
- Age converted from days to years and grouped; income grouped into 5 brackets.
- `bureau` and `previous_application` summarised to one row per client **before** joining, so no loan is repeated.

The final view, `v_loan_flat`, has 307,511 rows (one per loan) and 34 columns. Validation queries confirmed that the row count and the default total (24,825) did not change after joining.

| Script | Purpose |
|---|---|
| `sql/01_profiling.sql` | Row counts, NULLs, odd values |
| `sql/02_v_application_clean.sql` | Cleaned applications |
| `sql/03_v_bureau_summary.sql` | External credit per client |
| `sql/04_v_prev_summary.sql` | Previous applications per client |
| `sql/05_v_loan_flat.sql` | Final joined view |
| `sql/06_validation_checks.sql` | Row-count and total checks |
| `sql/07_extra_analysis.sql` | Extra analysis queries |



## 7. Dashboard
Power BI reads one flat table, `v_loan_flat`, so no relationships are needed. About 16 DAX measures (Total Loans, Defaults, Default Rate, Portfolio Default Rate, Rate vs Portfolio and others) and 7 calculated band columns drive the dashboard.

Built in Power BI Desktop on a single table, with the same filters on every page.

| Page | Purpose | Contents |
|---|---|---|
| **1 Overview** | Portfolio health at a glance | 5 KPIs, 5 slicers, 6 charts: default rate by age, income, occupation, credit history, region rating and education |
| **2 Detail** | Risk drivers | 6 secondary KPIs, 6 charts (employment, bureau loans, credit-to-income, car and realty, previous outcomes), smart narrative, AI view |
| **3 Segment** | Drillthrough | Right-click any bar to open a segment: KPIs vs the portfolio rate, decomposition tree and a loan-level table |

**Interactive features:** synced slicers across pages, bookmark buttons that swap each chart for an alternative view, a hide-and-show "More filters" panel, Key influencers (AI) view, and drillthrough.

