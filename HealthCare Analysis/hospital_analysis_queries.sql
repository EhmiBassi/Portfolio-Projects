
-- ============================================================
--  HOSPITAL INVESTMENT ANALYSIS — SQL QUERIES
--  Database: PostgreSQL
--  Table: hospitals_appended
-- ============================================================


-- ============================================================
--  1. FINANCIAL PERFORMANCE
-- ============================================================

-- ------------------------------------------------------------
-- Q1. Revenue per encounter & does higher billing = higher collections?
-- ------------------------------------------------------------
SELECT
    hospital_name,
    ROUND(AVG(billed_amount), 2)                        AS avg_billed_per_encounter,
    ROUND(AVG(paid_amount), 2)                          AS avg_paid_per_encounter,
    ROUND(AVG(paid_amount) / NULLIF(AVG(billed_amount), 0) * 100, 2) AS collection_rate_pct
FROM hospitals_appended
GROUP BY hospital_name
ORDER BY avg_billed_per_encounter DESC;


-- ------------------------------------------------------------
-- Q2. Average billed, allowed, and paid per encounter + gap analysis
-- ------------------------------------------------------------
SELECT
    hospital_name,
    ROUND(AVG(billed_amount), 2)                        AS avg_billed,
    ROUND(AVG(allowed_amount), 2)                       AS avg_allowed,
    ROUND(AVG(paid_amount), 2)                          AS avg_paid,
    ROUND(AVG(billed_amount - allowed_amount), 2)       AS avg_writeoff,
    ROUND(AVG(allowed_amount - paid_amount), 2)         AS avg_underpayment,
    ROUND(AVG(billed_amount - paid_amount), 2)          AS avg_total_gap
FROM hospitals_appended
GROUP BY hospital_name
ORDER BY avg_billed DESC;


-- ------------------------------------------------------------
-- Q3. Revenue and collection rate by department per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    department,
    COUNT(*)                                            AS total_encounters,
    ROUND(SUM(billed_amount), 2)                        AS total_billed,
    ROUND(SUM(paid_amount), 2)                          AS total_paid,
    ROUND(SUM(paid_amount) / NULLIF(SUM(billed_amount), 0) * 100, 2) AS collection_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, department
ORDER BY hospital_name, collection_rate_pct DESC;


-- ------------------------------------------------------------
-- Q4. Monthly revenue trend per hospital (2023-2024)
-- ------------------------------------------------------------
SELECT
    hospital_name,
    TO_CHAR(admission_date, 'YYYY-MM')                  AS month,
    ROUND(SUM(billed_amount), 2)                        AS total_billed,
    ROUND(SUM(paid_amount), 2)                          AS total_paid
FROM hospitals_appended
GROUP BY hospital_name, TO_CHAR(admission_date, 'YYYY-MM')
ORDER BY hospital_name, month;


-- ------------------------------------------------------------
-- Q5. Collection rate by payer type per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    payer_type,
    COUNT(*)                                            AS total_encounters,
    ROUND(SUM(billed_amount), 2)                        AS total_billed,
    ROUND(SUM(paid_amount), 2)                          AS total_paid,
    ROUND(SUM(paid_amount) / NULLIF(SUM(billed_amount), 0) * 100, 2) AS collection_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, payer_type
ORDER BY hospital_name, collection_rate_pct DESC;


-- ------------------------------------------------------------
-- Q6. Top 5 denial reasons per hospital + revenue at risk
-- ------------------------------------------------------------
SELECT
    hospital_name,
    denial_reason,
    COUNT(*)                                            AS denied_claims,
    ROUND(SUM(billed_amount), 2)                        AS revenue_at_risk
FROM hospitals_appended
WHERE claim_status = 'Denied'
  AND denial_reason <> 'None'
GROUP BY hospital_name, denial_reason
ORDER BY hospital_name, revenue_at_risk DESC;


-- ------------------------------------------------------------
-- Q7. Claims under appeal + total value being contested ???
-- ------------------------------------------------------------
SELECT
    hospital_name,
    COUNT(*)                                            AS claims_under_appeal,
    ROUND(SUM(billed_amount), 2)                        AS total_contested_value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER 
        (PARTITION BY hospital_name), 2)                AS pct_of_total_claims
FROM hospitals_appended
WHERE claim_status = 'Appealed'
GROUP BY hospital_name
ORDER BY total_contested_value DESC;


-- ------------------------------------------------------------
-- Q8. Denial rate by department per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    department,
    COUNT(*)                                            AS total_claims,
    SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) AS denied_claims,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2)                          AS denial_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, department
ORDER BY hospital_name, denial_rate_pct DESC;


-- ------------------------------------------------------------
-- Q9. Diagnosis codes most associated with denied claims
-- ------------------------------------------------------------
SELECT
    diagnosis_code,
    diagnosis_description,
    COUNT(*)                                            AS denied_claims,
    ROUND(SUM(billed_amount), 2)                        AS revenue_at_risk
FROM hospitals_appended
WHERE claim_status = 'Denied'
GROUP BY diagnosis_code, diagnosis_description
ORDER BY denied_claims DESC
LIMIT 15;


-- ------------------------------------------------------------
-- Q10. Denial rate by severity level
-- ------------------------------------------------------------
SELECT
    hospital_name,
    severity_level,
    COUNT(*)                                            AS total_claims,
    SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) AS denied_claims,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS denial_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, severity_level
ORDER BY hospital_name, severity_level;


-- ============================================================
--  2. OPERATIONAL EFFICIENCY
-- ============================================================

-- ------------------------------------------------------------
-- Q11. Average LOS by hospital and admission type
-- ------------------------------------------------------------
SELECT
    hospital_name,
    admission_type,
    ROUND(AVG(los), 2)      AS avg_los_days
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name, admission_type
ORDER BY hospital_name, avg_los_days DESC;


-- ------------------------------------------------------------
-- Q12. Average LOS by diagnosis — which hospital manages it best?
-- ------------------------------------------------------------
SELECT
    diagnosis_description,
    hospital_name,
    ROUND(AVG(los), 2)      AS avg_los_days,
    COUNT(*)                                            AS total_encounters
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY diagnosis_description, hospital_name
ORDER BY diagnosis_description, avg_los_days;


-- ------------------------------------------------------------
-- Q13. Correlation between severity level and LOS
-- ------------------------------------------------------------
SELECT
    hospital_name,
    severity_level,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(los), 2)      AS avg_los_days
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name, severity_level
ORDER BY hospital_name, severity_level;


-- ------------------------------------------------------------
-- Q14. Average LOS by department per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    department,
    ROUND(AVG(los), 2)      AS avg_los_days,
    COUNT(*)                                            AS total_encounters
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name, department
ORDER BY hospital_name, avg_los_days DESC;



-- Q15. Outlier encounters with LOS > 14 days

SELECT
    hospital_name
    COUNT(*)                                            AS outlier_encounters,
    ROUND(AVG(los), 1)      AS avg_los_days,
    ROUND(SUM(billed_amount), 2)                        AS total_billed
FROM hospitals_appended
WHERE (los) > 7
GROUP BY hospital_name
ORDER BY outlier_encounters DESC;



-- Q16. Claim submission speed vs collection rate

SELECT
    hospital_name,
    ROUND(AVG(days_to_submit), 1) AS avg_days_to_submit,
    ROUND(AVG(paid_amount) / NULLIF(AVG(billed_amount), 0) * 100, 2) AS collection_rate_pct
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name
ORDER BY avg_days_to_submit;


-- ------------------------------------------------------------
-- Q17. Claim processing days vs claim status
-- ------------------------------------------------------------
SELECT
    hospital_name,
    claim_status,
    ROUND(AVG(claim_processing_days), 1)                AS avg_processing_days,
    COUNT(*)                                            AS total_claims
FROM hospitals_appended
GROUP BY hospital_name, claim_status
ORDER BY hospital_name, avg_processing_days DESC;


-- ------------------------------------------------------------
-- Q18. Claim processing days by payer type
-- ------------------------------------------------------------
SELECT
    hospital_name,
    payer_type,
    ROUND(AVG(claim_processing_days), 1)                AS avg_processing_days,
    COUNT(*)                                            AS total_claims
FROM hospitals_appended
GROUP BY hospital_name, payer_type
ORDER BY hospital_name, avg_processing_days DESC;


-- ============================================================
--  3. CLINICAL QUALITY
-- ============================================================

-- ------------------------------------------------------------
-- Q19. Mortality rate by hospital and admission type
-- ------------------------------------------------------------
SELECT
    hospital_name,
    admission_type,                                       
    COUNT(*)                                            AS total_encounters,
    SUM(mortality_flag)                                 AS total_deaths,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, admission_type
ORDER BY hospital_name, mortality_rate_pct DESC;


-- ------------------------------------------------------------
-- Q20. Diagnosis codes with highest mortality rate
-- ------------------------------------------------------------
SELECT
    diagnosis_code,
    diagnosis_description,
    COUNT(*)                                            AS total_encounters,
    SUM(mortality_flag)                                 AS total_deaths,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct
FROM hospitals_appended
GROUP BY diagnosis_code, diagnosis_description
HAVING COUNT(*) > 20
ORDER BY mortality_rate_pct DESC
LIMIT 15;


-- ------------------------------------------------------------
-- Q21. Mortality rate by severity level — are low severity patients dying?
-- ------------------------------------------------------------
SELECT
    hospital_name,
    severity_level,
    COUNT(*)                                            AS total_encounters,
    SUM(mortality_flag)                                 AS total_deaths,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, severity_level
ORDER BY hospital_name, severity_level;


-- ------------------------------------------------------------
-- Q22. Complication rate by procedure per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    COUNT(*)                                            AS total_encounters,
    SUM(complication_flag)                              AS total_complications,
    ROUND(SUM(complication_flag) * 100.0 / COUNT(*), 2) AS complication_rate_pct
FROM hospitals_appended
GROUP BY hospital_name
ORDER BY hospital_name, complication_rate_pct DESC;


-- ------------------------------------------------------------
-- Q23. HAI impact on LOS and cost
-- ------------------------------------------------------------
SELECT
    hospital_name,
    hospital_acquired_infection                         AS hai,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(los), 2)      AS avg_los_days,
    ROUND(AVG(billed_amount), 2)                        AS avg_billed
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name, hospital_acquired_infection
ORDER BY hospital_name, hai;


-- ------------------------------------------------------------
-- Q24. Quality incident types per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    quality_incident,
    COUNT(*)                                            AS total_incidents,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER
        (PARTITION BY hospital_name), 2)                AS pct_of_hospital_encounters
FROM hospitals_appended
WHERE quality_incident <> 'None'
GROUP BY hospital_name, quality_incident
ORDER BY hospital_name, total_incidents DESC;


-- ------------------------------------------------------------
-- Q25. Quality incident rate by department
-- ------------------------------------------------------------
SELECT
    hospital_name,
    department,
    COUNT(*)                                            AS total_encounters,
    SUM(CASE WHEN quality_incident <> 'NUL' THEN 1 ELSE 0 END) AS total_incidents,
    ROUND(SUM(CASE WHEN quality_incident <> 'None' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS incident_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, department
ORDER BY hospital_name, incident_rate_pct DESC;


-- ------------------------------------------------------------
-- Q26. Quality incidents vs patient satisfaction
-- ------------------------------------------------------------
SELECT
    hospital_name,
    CASE WHEN quality_incident <> 'None' THEN 'Has Incident'
         ELSE 'No Incident' END                         AS incident_status,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction
FROM hospitals_appended
GROUP BY hospital_name, incident_status
ORDER BY hospital_name, incident_status;


-- ------------------------------------------------------------
-- Q27. Provider quality incident rate
-- ------------------------------------------------------------
SELECT
    provider_name,
    hospital_name,
    COUNT(*)                                            AS total_encounters,
    SUM(CASE WHEN quality_incident <> 'None' THEN 1 ELSE 0 END) AS total_incidents,
    ROUND(SUM(CASE WHEN quality_incident <> 'None' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS incident_rate_pct
FROM hospitals_appended
GROUP BY provider_name, hospital_name
ORDER BY incident_rate_pct DESC
LIMIT 15;


-- ============================================================
--  4. PATIENT PROFILE & EXPERIENCE
-- ============================================================

-- ------------------------------------------------------------
-- Q28. Age distribution per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    CASE
        WHEN patient_age BETWEEN 0  AND 17 THEN '0-17 (Paediatric)'
        WHEN patient_age BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN patient_age BETWEEN 36 AND 55 THEN '36-55 (Middle Age)'
        WHEN patient_age BETWEEN 56 AND 70 THEN '56-70 (Senior)'
        ELSE '71+ (Elderly)'
    END                                                 AS age_group,
    COUNT(*)                                            AS total_patients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER
        (PARTITION BY hospital_name), 2)                AS pct_of_hospital
FROM hospitals_appended
GROUP BY hospital_name, age_group
ORDER BY hospital_name, age_group;


-- ------------------------------------------------------------
-- Q29. Gender breakdown + impact on LOS, mortality, satisfaction
-- ------------------------------------------------------------
SELECT
    hospital_name,
    patient_gender,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(discharge_date - admission_date), 2)      AS avg_los,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name, patient_gender
ORDER BY hospital_name, patient_gender;


-- ------------------------------------------------------------
-- Q30. Admission type mix per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    admission_type,
    COUNT(*)                                            AS total_encounters,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER
        (PARTITION BY hospital_name), 2)                AS pct_of_hospital,
    ROUND(AVG(los), 2)      AS avg_los,
    ROUND(AVG(billed_amount), 2)                        AS avg_billed
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name, admission_type
ORDER BY hospital_name, total_encounters DESC;


-- ------------------------------------------------------------
-- Q31. Patient satisfaction by department per hospital
-- ------------------------------------------------------------
SELECT
    hospital_name,
    department,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction
FROM hospitals_appended
GROUP BY hospital_name, department
ORDER BY hospital_name, avg_satisfaction DESC;


-- ------------------------------------------------------------
-- Q32. Satisfaction by admission type — which type scores lowest?
-- ------------------------------------------------------------
SELECT
    hospital_name,
    admission_type,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction,
    COUNT(*)                                            AS total_encounters
FROM hospitals_appended
GROUP BY hospital_name, admission_type
ORDER BY hospital_name, avg_satisfaction;


-- ------------------------------------------------------------
-- Q33. LOS vs satisfaction — do longer stays mean lower scores?
-- ------------------------------------------------------------
SELECT
    hospital_name,
    CASE
        WHEN (los) BETWEEN 0 AND 2  THEN '0-2 days'
        WHEN (los) BETWEEN 3 AND 5  THEN '3-5 days'
        WHEN (los) BETWEEN 6 AND 10 THEN '6-10 days'
        ELSE '11+ days'
    END                                                 AS los_bucket,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name, los_bucket
ORDER BY hospital_name, los_bucket;


-- ------------------------------------------------------------
-- Q34. Diagnosis groups with lowest satisfaction scores
-- ------------------------------------------------------------
SELECT
    diagnosis_description,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction,
    COUNT(*)                                            AS total_encounters
FROM hospitals_appended
GROUP BY diagnosis_description
HAVING COUNT(*) > 30
ORDER BY avg_satisfaction
LIMIT 15;


-- ============================================================
--  5. PROVIDER PERFORMANCE
-- ============================================================

-- ------------------------------------------------------------
-- Q35. Provider satisfaction scores — highest and lowest
-- ------------------------------------------------------------
SELECT
    provider_name,
    hospital_name,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction
FROM hospitals_appended
GROUP BY provider_name, hospital_name
ORDER BY avg_satisfaction DESC;


-- ------------------------------------------------------------
-- Q36. Provider denial rates — who has the most rejected claims?
-- ------------------------------------------------------------
SELECT
    provider_name,
    hospital_name,
    COUNT(*)                                            AS total_claims,
    SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) AS denied_claims,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS denial_rate_pct
FROM hospitals_appended
GROUP BY provider_name, hospital_name
ORDER BY denial_rate_pct DESC;


-- ------------------------------------------------------------
-- Q37. Provider case complexity — who handles the highest severity?
-- ------------------------------------------------------------
SELECT
    provider_name,
    hospital_name,
    COUNT(*)                                            AS total_encounters,
    ROUND(AVG(severity_level), 2)                       AS avg_severity,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct
FROM hospitals_appended
GROUP BY provider_name, hospital_name
ORDER BY avg_severity DESC;


-- ------------------------------------------------------------
-- Q38. Provider concentration risk — over-reliance on key providers
-- ------------------------------------------------------------
SELECT
    hospital_name,
    provider_name,
    COUNT(*)                                            AS total_encounters,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER
        (PARTITION BY hospital_name), 2)                AS pct_of_hospital_encounters
FROM hospitals_appended
GROUP BY hospital_name, provider_name
ORDER BY hospital_name, pct_of_hospital_encounters DESC;


-- ------------------------------------------------------------
-- Q39. Provider mortality and complication rates by severity
-- ------------------------------------------------------------
SELECT
    provider_name,
    hospital_name,
    severity_level,
    COUNT(*)                                            AS total_encounters,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct,
    ROUND(SUM(complication_flag) * 100.0 / COUNT(*), 2) AS complication_rate_pct
FROM hospitals_appended
GROUP BY provider_name, hospital_name, severity_level
HAVING COUNT(*) > 10
ORDER BY hospital_name, mortality_rate_pct DESC;


-- ============================================================
--  6. COMPARATIVE & INVESTMENT-FOCUSED
-- ============================================================

-- ------------------------------------------------------------
-- Q40. Overall hospital ranking across all key metrics
-- ------------------------------------------------------------
SELECT
    hospital_name,
    ROUND(AVG(paid_amount) / NULLIF(AVG(billed_amount), 0) * 100, 2) AS collection_rate_pct,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS denial_rate_pct,
    ROUND(AVG(los), 2)      AS avg_los,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction,
    ROUND(SUM(CASE WHEN claim_status = 'Denied'
        THEN billed_amount ELSE 0 END), 2)              AS revenue_at_risk
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name
ORDER BY collection_rate_pct DESC;


-- ------------------------------------------------------------
-- Q41. Year-over-year improvement per hospital (2023 vs 2024)
-- ------------------------------------------------------------
SELECT
    hospital_name,
    EXTRACT(YEAR FROM admission_date)                   AS year,
    ROUND(AVG(paid_amount) / NULLIF(AVG(billed_amount), 0) * 100, 2) AS collection_rate_pct,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS denial_rate_pct,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction,
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct
FROM hospitals_appended
GROUP BY hospital_name, EXTRACT(YEAR FROM admission_date)
ORDER BY hospital_name, year;


-- ------------------------------------------------------------
-- Q42. Which hospital has the most fixable problems?
--      Operational issues = high denial rate, slow submission
--      Structural issues  = high mortality, high HAI
-- ------------------------------------------------------------
SELECT
    hospital_name,
    -- Operational (fixable)
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS denial_rate_pct,
    ROUND(AVG(los), 1) AS avg_days_to_submit,
    ROUND(AVG(claim_processing_days), 1)                AS avg_processing_days,
    -- Structural (harder to fix)
    ROUND(SUM(mortality_flag) * 100.0 / COUNT(*), 2)   AS mortality_rate_pct,
    ROUND(SUM(hospital_acquired_infection) * 100.0
        / COUNT(*), 2)                                  AS hai_rate_pct,
    ROUND(AVG(patient_satisfaction_score), 2)           AS avg_satisfaction
FROM hospitals_appended
WHERE discharge_date IS NOT NULL
GROUP BY hospital_name
ORDER BY denial_rate_pct DESC;


-- ------------------------------------------------------------
-- Q43. GAP ANALYSIS — Revenue recovered if GGH denial rate = RMC
-- ------------------------------------------------------------
WITH hospital_metrics AS (
    SELECT
        hospital_name,
        COUNT(*)                                        AS total_claims,
        ROUND(AVG(billed_amount), 2)                    AS avg_billed,
        ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END)
            * 1.0 / COUNT(*), 4)                        AS denial_rate
    FROM hospitals_appended
    GROUP BY hospital_name
),
rmc_rate AS (
    SELECT denial_rate AS target_rate
    FROM hospital_metrics
    WHERE hospital_name = 'Riverside Medical Centre'
)
SELECT
    h.hospital_name,
    ROUND(h.denial_rate * 100, 2)                       AS current_denial_rate,
    ROUND(r.target_rate * 100, 2)                       AS target_denial_rate,
    ROUND((h.denial_rate - r.target_rate) * 100, 2)     AS denial_rate_gap,
    ROUND((h.denial_rate - r.target_rate)
        * h.total_claims)                               AS Claims_recovered,
    ROUND((h.denial_rate - r.target_rate)
        * h.total_claims * h.avg_billed, 2)             AS Est_revenue_recovered
FROM hospital_metrics h
CROSS JOIN rmc_rate r
WHERE h.hospital_name != 'Riverside Medical Centre'
ORDER BY Est_revenue_recovered DESC;


-- ------------------------------------------------------------
-- Q44. GAP ANALYSIS — GGH collection rate if OOP mix = RMC level
-- ------------------------------------------------------------
WITH oop_stats AS (
    SELECT
        hospital_name,
        SUM(CASE WHEN payer_type = 'Out-of-Pocket' 
            THEN 1 ELSE 0 END)                          AS oop_encounters,
        COUNT(*)                                        AS total_encounters,
        ROUND(SUM(CASE WHEN payer_type = 'Out-of-Pocket' 
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)  AS oop_pct,
        ROUND(SUM(CASE WHEN payer_type = 'Out-of-Pocket' 
            THEN paid_amount ELSE 0 END) /
            NULLIF(SUM(CASE WHEN payer_type = 'Out-of-Pocket' 
            THEN billed_amount ELSE 0 END), 0) * 100, 2) AS oop_collection_rate_pct
    FROM hospitals_appended
    GROUP BY hospital_name
)
SELECT
    hospital_name,
    oop_encounters,
    total_encounters,
    oop_pct                                             AS oop_mix_pct,
    oop_collection_rate_pct
FROM oop_stats
ORDER BY hospital_name;


WITH oop_stats AS (
    SELECT
        hospital_name,
        ROUND(SUM(CASE WHEN payer_type = 'Out-of-Pocket' 
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)  AS oop_mix_pct,
        ROUND(SUM(CASE WHEN payer_type = 'Out-of-Pocket' 
            THEN paid_amount ELSE 0 END) /
            NULLIF(SUM(CASE WHEN payer_type = 'Out-of-Pocket' 
            THEN billed_amount ELSE 0 END), 0) * 100, 2) AS oop_collection_rate_pct,
        COUNT(*)                                        AS total_encounters,
        ROUND(AVG(billed_amount)::NUMERIC, 2)           AS avg_billed
    FROM hospitals_appended
    GROUP BY hospital_name
),
rmc AS (
    SELECT oop_mix_pct AS rmc_oop_pct
    FROM oop_stats
    WHERE hospital_name = 'Riverside Medical Centre'
)
SELECT
    g.hospital_name,
    g.oop_mix_pct                                       AS current_oop_mix_pct,
    r.rmc_oop_pct                                       AS target_oop_mix_pct,
    ROUND(g.oop_mix_pct - r.rmc_oop_pct, 2)            AS oop_mix_gap_pct,
    g.oop_collection_rate_pct                           AS current_oop_collection_rate,
    -- Encounters that would shift from OOP to insured
    ROUND((g.oop_mix_pct - r.rmc_oop_pct)
        / 100 * g.total_encounters)                     AS encounters_that_would_shift,
    -- Revenue uplift if those encounters had insured collection rates (~45%)
    ROUND((g.oop_mix_pct - r.rmc_oop_pct) / 100
        * g.total_encounters * g.avg_billed * 0.45, 2) AS estimated_revenue_uplift
FROM oop_stats g
CROSS JOIN rmc r
WHERE g.hospital_name != 'Riverside Medical Centre'
ORDER BY g.hospital_name;


-- QUALITY INCIDENT / HAI VS MORTALITY CHECK

SELECT COUNT(*)
FROM hospitals_appended
WHERE quality_incident_flag = 1;

SELECT COUNT(*) AS total_count, severity_level, diagnosis_description, quality_incident
FROM hospitals_appended
WHERE quality_incident_flag = 1 AND complication_flag =1 AND mortality_flag = 1
GROUP BY quality_incident, severity_level, diagnosis_description
ORDER BY total_count DESC;

SELECT COUNT(*)
FROM hospitals_appended
WHERE hospital_acquired_infection = 1 AND complication_flag =1 AND mortality_flag = 1;

SELECT COUNT(*)
FROM hospitals_appended
WHERE mortality_flag = 1;

SELECT hospital_name, severity_level, COUNT(*) AS total_cases
FROM hospitals_appended
GROUP BY hospital_name, severity_level
ORDER BY total_cases ;