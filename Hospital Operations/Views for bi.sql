CREATE VIEW fact_admissions AS
SELECT
    a.admission_id,
    a.patient_id,
    a.department,
    a.admission_type,
    a.discharge_disposition,
    a.admission_datetime,
    a.discharge_datetime,

    -- LOS
    ROUND(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime))/86400,2) AS los_days,
    ROUND(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime))/3600,2) AS los_hours,

    -- Date breakdown
    DATE(a.admission_datetime) AS admission_day,
    EXTRACT(HOUR FROM a.admission_datetime) AS admission_hour,
    EXTRACT(DOW FROM a.admission_datetime) AS admission_weekday,
    TO_CHAR(a.admission_datetime, 'Day') AS admission_day_name,

    -- Age + grouping
    p.age,
    CASE 
        WHEN p.age IS NULL THEN 'Unknown'
        WHEN p.age < 18 THEN 'Pediatrics'
        WHEN p.age BETWEEN 18 AND 34 THEN 'Young Adult'
        WHEN p.age BETWEEN 35 AND 59 THEN 'Adult'
        ELSE '60+ (Older)'
    END AS age_group

FROM admissions a
LEFT JOIN patients p 
    ON p.patient_id = a.patient_id

WHERE a.discharge_datetime IS NOT NULL;
--answers q1-12

CREATE VIEW fact_diagnosis AS
SELECT
    a.admission_id,
    d.icd10_code,

    CASE 
        WHEN d.icd10_code = 'O80' THEN 'Normal delivery'
        WHEN d.icd10_code = 'E11' THEN 'Type II Diabetes'
        WHEN d.icd10_code = 'I10' THEN 'Hypertension'
        WHEN d.icd10_code = 'K35' THEN 'Appendicitis'
        WHEN d.icd10_code = 'N39' THEN 'UTI'
        WHEN d.icd10_code = 'J18' THEN 'Pneumonia'
        WHEN d.icd10_code = 'A09' THEN 'Gastroenteritis'
        ELSE 'Other'
    END AS diagnosis_name,

    ROUND(EXTRACT(EPOCH FROM (a.discharge_datetime - a.admission_datetime))/86400,2) AS los_days

FROM admissions a
JOIN diagnosis d 
    ON a.admission_id = d.admission_id

WHERE a.discharge_datetime IS NOT NULL;
--answers q13 and q14
