# Ads-Analysis
On this file you can find the requirements and the instructions on setting up the project. Also an example of how the script "kpi_checkout" can be used for natural language questions.

## Requirements
- n8n account
- Google BigQuery
- Source File ([Link](https://docs.google.com/spreadsheets/d/1Aixc7qe5nhUloftgbNF0ogpGcTt16FzWfEE0MIdrbVw/edit?usp=sharing))

## Setup
1. On Google BigQuery execute the SQL files in the following order
    - [create_schema_and_tables.sql](https://github.com/Eddie2809/Ads-Analysis/blob/main/SQL/1.-%20create_schema_and_tables.sql): This script will create the main schema dbo and the staging, dim and fact tables.
    - [create_procedures.sql](https://github.com/Eddie2809/Ads-Analysis/blob/main/SQL/2.-%20create_procedures.sql): This script will create every procedure that will be used on the ETL process.
    - [kpi_checkout.sql](https://github.com/Eddie2809/Ads-Analysis/blob/main/SQL/3.-%20kpi_checkout.sql): This script creates a view for getting the analysis on the last 30 days and a stored procedure for getting the same analysis on a date range compared with certain amount of days prior.
2. Create a service account on GCP with the following roles:
    - BigQuery Data Editor
    - BigQuery Job User
3. Import a n8n el [ingestion workflow](https://github.com/Eddie2809/Ads-Analysis/blob/main/Ingestion_Workflow.json)



## Agent Demo
Using the stored procedure "kpi_checkout" we can get very useful insights of certaing kpis if we ask the right questions:

```json
[
    {
        "question": "Compare CAC and ROAS for the last 30 days vs prior 30 days",
        "query": "CALL dbo.kpi_checkout(date_add(current_date(),INTERVAL -30 DAY),current_date(),30)"
    },
    {
        "question": "Compare CAC and ROAS last trimester vs prior trimester",
        "query": "CALL dbo.kpi_checkout(date_add(current_date(),INTERVAL -90 DAY),current_date(),90)"
    },
    {
        "question": "CAC and ROAS last week vs prior month",
        "query": "CALL dbo.kpi_checkout(date_add(current_date(),INTERVAL -7 DAY),current_date(),30)"
    }
]
```