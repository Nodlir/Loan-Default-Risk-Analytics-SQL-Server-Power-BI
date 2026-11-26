# Loan-Default-Risk-Analytics-SQL-Server-Power-BI
End-to-end analysis of 307,511 loan applications to find which borrower profiles are linked to payment difficulties. Raw data was cleaned in SQL Server and presented in a 3-page interactive Power BI dashboard.

**Dataset:** [Home Credit Default Risk (Kaggle)](https://www.kaggle.com/c/home-credit-default-risk/data)

## 1. Project Overview

**Business problem:** A lender needs to know which applicants are more likely to have trouble repaying a loan, so it can price risk and make approval decisions with evidence.

**What this project does:**
- Cleans and combines 3 raw tables (current applications, external credit history, previous applications) using SQL views.
- Builds a Power BI dashboard that lets a risk manager filter the portfolio and compare default rates across age, income, occupation, credit history and more.
- Includes a drillthrough page to look closely at any segment, such as one occupation or age group.

**Definition used:** *Default* means a client flagged with payment difficulties. The overall rate is **8.07%** (24,825 of 307,511 loans).
