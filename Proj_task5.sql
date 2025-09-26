WITH union_ads AS 
(
SELECT fd.ad_date 
, 'facebook' AS media_sorce
, fc.campaign_name
, fa.adset_name
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
FROM google_ads_basic_daily AS gd
), grouped_days AS 
(
SELECT adset_name 
, ad_date :: date - row_number() OVER (PARTITION BY adset_name ORDER BY ad_date):: int AS grp_days
FROM union_ads
GROUP BY adset_name, ad_date
)
SELECT adset_name 
, COUNT(grp_days) AS count_days
FROM grouped_days
GROUP BY adset_name
ORDER BY COUNT(grp_days) DESC
LIMIT 1;

