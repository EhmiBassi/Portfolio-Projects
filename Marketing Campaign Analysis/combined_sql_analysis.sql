
SELECT * 
FROM marketing_campaign_dataset;


/*1. Calculate Total Impressions for Each Campaign 
Expected Output: A table with campaign_id and total impressions. */

SELECT Campaign_ID, Campaign_Type, SUM(Impressions) AS Total_Impressions
FROM marketing_campaign_dataset
GROUP BY Campaign_ID, Campaign_Type
ORDER BY Total_Impressions DESC;




/*2. Identify the Campaign with the Highest ROI
Expected Output: A single row with campaign_id, company, and roi. */

SELECT TOP (1) Campaign_ID, Company, SUM(ROI) AS ROI
FROM marketing_campaign_dataset
GROUP BY Campaign_ID, Company
ORDER BY ROI DESC;




/*3. Find the Top 3 Locations with the Most Impressions
Expected Output: A table with location and total impressions.  */

SELECT Top(3) Location, SUM(Impressions) AS Total_Impressions
FROM marketing_campaign_dataset
GROUP BY Location
ORDER BY Total_Impressions DESC;




/*4. Calculate Average Engagement Score by Target Audience
Expected Output: A table with target_audience and avg engagement score. */

SELECT Target_Audience, AVG(Engagement_Score) AS Average_Engagement_Score
FROM marketing_campaign_dataset
GROUP BY Target_Audience;




/*5. Calculate the Overall CTR (Click-Through Rate)
Expected Output: A single value for the overall CTR. */

--CTR = CLICKS/IMPRESSIONS.
--Multiplying Clicks by 1.0 ensures it returns a decimal value

SELECT ROUND(SUM(Clicks * 1.0 / Impressions), 2) AS Overall_Click_Through_Rate  
FROM marketing_campaign_dataset;




/*6. Find the Most Cost-Effective Campaign
Expected Output: A table with campaign_id, company, and cost per conversion. */

--Format value to currency(%)

SELECT TOP (1) Campaign_ID, Company, FORMAT(Sum(Acquisition_Cost / ConversionRate), 'C', 'en-US') AS Cost_per_conversion 
FROM marketing_campaign_dataset
GROUP BY Campaign_ID, Company
ORDER BY Sum(Acquisition_Cost / ConversionRate);




/*7. Find Campaigns with CTR Above a Threshold
Expected Output: A table with campaign_id, company, and ctr. */

--Multiply clicks by 1.0 to return the value as decimal
--Multiply by 100 to get the CTR in percentage and round it up to 2 decimal places

SELECT 
Campaign_ID, 
Company, 
FORMAT(ROUND((Clicks * 1.0 / Impressions) * 100, 2), 'N2') + '%'--format it to get the value in percentage
AS CTR_Percentage
FROM marketing_campaign_dataset
WHERE ROUND((Clicks * 1.0 / Impressions) * 100, 2) > 40 --We make 40 our Threshold value
ORDER BY CTR_Percentage DESC;




/*8. Rank Channels by Total Conversions
Expected Output: A table with channel_used and total conversions. */

--To get the Total_conversion, divide conversion rate by a base (clicks). 
--Conversions happen after clicks

SELECT Channel_Used, SUM(ConversionRate * Clicks) AS Total_conversions 
FROM marketing_campaign_dataset
GROUP BY Channel_Used
ORDER BY Total_Conversions DESC;