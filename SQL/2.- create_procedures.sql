CREATE OR REPLACE PROCEDURE dbo.update_accounts()
BEGIN
  TRUNCATE TABLE dbo.dim_account;

  INSERT INTO dbo.dim_account
  SELECT
    ROW_NUMBER() OVER() AS id,
    account
  FROM dbo.staging_ads_raw
  GROUP BY account;
END;

CREATE OR REPLACE PROCEDURE dbo.update_campaigns()
BEGIN
  TRUNCATE TABLE dbo.dim_campaign;

  INSERT INTO dbo.dim_campaign
  SELECT
    ROW_NUMBER() OVER() AS id,
    campaign
  FROM dbo.staging_ads_raw
  GROUP BY campaign;
END;

CREATE OR REPLACE PROCEDURE dbo.update_countries()
BEGIN
  TRUNCATE TABLE dbo.dim_country;

  INSERT INTO dbo.dim_country
  SELECT
    ROW_NUMBER() OVER() AS id,
    country
  FROM dbo.staging_ads_raw
  GROUP BY country;
END;

CREATE OR REPLACE PROCEDURE dbo.update_devices()
BEGIN
  TRUNCATE TABLE dbo.dim_device;

  INSERT INTO dbo.dim_device
  SELECT
    ROW_NUMBER() OVER() AS id,
    device
  FROM dbo.staging_ads_raw
  GROUP BY device;
END;

CREATE OR REPLACE PROCEDURE dbo.update_platforms()
BEGIN
  TRUNCATE TABLE dbo.dim_platform;

  INSERT INTO dbo.dim_platform
  SELECT
    ROW_NUMBER() OVER() AS id,
    platform
  FROM dbo.staging_ads_raw
  GROUP BY platform;
END;

CREATE OR REPLACE PROCEDURE dbo.update_fact_ads() 
BEGIN

DECLARE max_id INT64;
SET max_id = COALESCE((SELECT MAX(id) FROM dbo.fact_ads),0);

INSERT INTO dbo.fact_ads
SELECT
  ROW_NUMBER() OVER() + max_id AS id,
  ads.date,
  ads.id AS altId,
  acc.id AS id_account,
  camp.id AS id_campaign,
  co.id AS id_country,
  dev.id AS id_device,
  plt.id AS id_platform,
  spend,
  clicks,
  impressions,
  conversions
FROM dbo.staging_ads_raw AS ads
LEFT JOIN `dbo.dim_account` AS acc ON ads.account = acc.name
LEFT JOIN `dbo.dim_campaign` AS camp ON ads.campaign = camp.name
LEFT JOIN `dbo.dim_country` AS co ON ads.country = co.name
LEFT JOIN `dbo.dim_device` AS dev ON ads.device = dev.name
LEFT JOIN `dbo.dim_platform` AS plt ON ads.platform = plt.name
WHERE ads.id NOT IN (SELECT DISTINCT id FROM dbo.fact_ads);

END