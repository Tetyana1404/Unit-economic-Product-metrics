WITH union_ads AS 
(
SELECT fd.ad_date 
, 'facebook' AS media_sorce
, fc.campaign_name
, fa.adset_name
, fd.reach 
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
, gd.reach 
FROM google_ads_basic_daily AS gd
), 
 monthly_reach_camp AS 
(
SELECT 
  date_part('YEAR', ad_date)|| '-' ||date_part('month', ad_date) AS ad_month
, campaign_name
, coalesce(SUM(reach), 0) AS monthly_reach
FROM union_ads
GROUP BY 1, 2
)
SELECT *
, monthly_reach - coalesce(LAG(monthly_reach) OVER (PARTITION BY campaign_name
	ORDER BY ad_month), 0) AS monthly_diff
FROM monthly_reach_camp
ORDER BY monthly_diff DESC
LIMIT 1;
