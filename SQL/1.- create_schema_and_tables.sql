CREATE SCHEMA IF NOT EXISTS dbo;

CREATE OR REPLACE TABLE dbo.staging_ads_raw (
	id INT,
	date DATE,
	platform STRING,
	account STRING,
	campaign STRING,
	country STRING,
	device STRING,
	spend FLOAT64,
	clicks INT,
	impressions INT,
	conversions INT,
	source_file STRING,
	loading_date STRING
);

CREATE OR REPLACE TABLE dbo.dim_campaign (
	id INT,
	name STRING
);

CREATE OR REPLACE TABLE dbo.dim_account (
	id INT,
	name STRING
);

CREATE OR REPLACE TABLE dbo.dim_platform (
 	id INT,
 	name STRING
);

CREATE OR REPLACE TABLE dbo.dim_country (
	id INT,
	name STRING
);

CREATE OR REPLACE TABLE dbo.dim_device (
	id INT,
	name STRING
);

CREATE OR REPLACE TABLE dbo.fact_ads (
	id INT,
  date DATE,
	alt_id INT,
	id_campaign INT,
	id_account INT,
	id_platform INT,
	id_country INT,
	id_device INT,
	spend FLOAT64,
	clicks INT,
	impressions INT,
	conversion INT
)
PARTITION BY date
CLUSTER BY id_campaign,id_country,id_platform,id_device;

