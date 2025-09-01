CREATE OR REPLACE VIEW dbo.kpi_checkout AS

WITH Agg_Table AS (
  SELECT
    date,
    SUM(spend) AS spend,
    SUM(clicks) AS clicks,
    SUM(impressions) AS impressions,
    SUM(conversion) AS conversion
  FROM dbo.fact_ads
  GROUP BY date
),
CAC_Table AS(
  SELECT
    'CAC' AS KPI,
    SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN spend END) / 
    SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN conversion END) AS last_30_days,
    SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -60 DAY) AND date < DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN spend END) / 
    SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -60 DAY) AND date < DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN conversion END) AS prior_30_days
  FROM Agg_Table
),
ROAS_Table AS(
  SELECT
    'ROAS' AS KPI,
    (SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN conversion END) * 100) / 
    SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN spend END) AS last_30_days,
    (SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -60 DAY) AND date < DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN conversion END) * 100) / 
    SUM(CASE WHEN date >= DATE_ADD('2025-06-30',INTERVAL -60 DAY) AND date < DATE_ADD('2025-06-30',INTERVAL -30 DAY) THEN spend END) AS prior_30_days
  FROM Agg_Table
)
SELECT
  KPI,prior_30_days,last_30_days,100 * ((last_30_days - prior_30_days) / prior_30_days) AS delta_change
FROM CAC_Table
UNION ALL
SELECT
  KPI,prior_30_days,last_30_days,100 * ((last_30_days - prior_30_days) / prior_30_days) AS delta_change
FROM ROAS_Table;

CREATE OR REPLACE PROCEDURE `excellent-bolt-470412-v9.dbo.kpi_checkout`(date_from DATE, date_to DATE, days_prior INT64)
BEGIN
WITH Agg_Table AS (
  SELECT
    date,
    SUM(spend) AS spend,
    SUM(conversion) AS conversion
  FROM dbo.fact_ads
  GROUP BY date
),
CAC_Table AS(
  SELECT
    'CAC' AS KPI,
    SUM(CASE WHEN date >= date_from AND date <= date_to THEN spend END) / 
    SUM(CASE WHEN date >= date_from AND date <= date_to THEN conversion END) AS last_days,
    SUM(CASE WHEN date >= DATE_ADD(date_from,INTERVAL -days_prior DAY) AND date < date_from THEN spend END) / 
    SUM(CASE WHEN date >= DATE_ADD(date_from,INTERVAL -days_prior DAY) AND date < date_from THEN conversion END) AS prior_days
  FROM Agg_Table
),
ROAS_Table AS(
  SELECT
    'ROAS' AS KPI,
    (SUM(CASE WHEN date >= date_from AND date <= date_to THEN conversion END) * 100) / 
    SUM(CASE WHEN date >= date_from AND date <= date_to THEN spend END) AS last_days,
    (SUM(CASE WHEN date >= DATE_ADD(date_from,INTERVAL -days_prior DAY) AND date < date_from THEN conversion END) * 100) / 
    SUM(CASE WHEN date >= DATE_ADD(date_from,INTERVAL -days_prior DAY) AND date < date_from THEN spend END) AS prior_days
  FROM Agg_Table
)
SELECT
  KPI,ROUND(prior_days,2) AS prior_days,ROUND(last_days,2) AS last_days,ROUND(100 * ((last_days - prior_days) / prior_days),2) AS delta_change
FROM CAC_Table
UNION ALL
SELECT
  KPI,ROUND(prior_days,2),ROUND(last_days,2),ROUND(100 * ((last_days - prior_days) / prior_days),2) AS delta_change
FROM ROAS_Table;
END;