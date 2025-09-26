SELECT * FROM facebook_ads_basic_daily LIMIT 100;

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
)
SELECT m.campaign_name
 , date_part('month', m.ad_date) AS month_ad
 , SUM(m.reach)  AS reach
 , SUM(prev_m.reach) AS reach_prev_month
 , SUM(m.reach) - SUM(prev_m.reach) AS diff_reach
 FROM union_ads  AS m
 	LEFT JOIN union_ads AS prev_m
 	ON prev_m.ad_date = m.ad_date - INTERVAL '1 month'
WHERE prev_m.reach IS NOT NULL
GROUP BY m.campaign_name, date_part('month', m.ad_date)
ORDER BY diff_reach DESC
Limit 1; 
 
