WITH union_ads AS 
(
SELECT fd.ad_date 
, 'facebook' AS media_sorce
, fc.campaign_name
, fa.adset_name
, fd.spend 
, fd.value
FROM facebook_ads_basic_daily AS fd 
	LEFT JOIN public.facebook_campaign AS fc
	ON fd.campaign_id = fc.campaign_id
	LEFT JOIN public.facebook_adset AS fa
	ON fd.adset_id = fa.adset_id
UNION ALL 
SELECT  gd.ad_date 
, 'google' AS media_sorce
, gd.campaign_name
, gd.adset_name
, gd.spend
, gd.value
FROM google_ads_basic_daily AS gd
),
set_days AS (
SELECT ad_date 
, adset_name
FROM union_ads 
GROUP BY 1, 2)
, grouped_rank_by_days  AS (
SELECT *
, ad_date:: date - row_number() OVER (PARTITION BY adset_name ORDER BY ad_date)  :: int AS grouped_date
FROM set_days
GROUP BY adset_name, ad_date)
SELECT adset_name 
, COUNT (DISTINCT grouped_date) AS duration_adset
FROM grouped_rank_by_days 
GROUP BY adset_name 
ORDER BY duration_adset desc
LIMIT 1;