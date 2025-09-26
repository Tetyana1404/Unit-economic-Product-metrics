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
)
SELECT campaign_name
, date_trunc('week' , ad_date) :: date AS weeks
, coalesce(SUM (value) , 0)  AS value_total
FROM union_ads 
GROUP BY weeks, campaign_name
ORDER BY value_total desc
LIMIT 1;
