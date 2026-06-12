DROP TABLE IF EXISTS hospitals_appended;
CREATE TABLE hospitals_appended (
 
    -- ── IDENTIFIERS ─────────────────────────────────────────
    encounter_id                VARCHAR(20)         PRIMARY KEY,
    claim_id                    VARCHAR(20),
    patient_id                  VARCHAR(15),
 
    -- ── HOSPITAL ATTRIBUTES ──────────────────────────────────
    hospital_name               VARCHAR(60),
    hospital_code               VARCHAR(10),
    hospital_type               VARCHAR(20),
    hospital_city               VARCHAR(30),
    total_licensed_beds         INTEGER,
 
    -- ── PATIENT ATTRIBUTES ───────────────────────────────────
    patient_age                 INTEGER,
    patient_gender              VARCHAR(10),
 
    -- ── PROVIDER ATTRIBUTES ──────────────────────────────────
    provider_id                 VARCHAR(15),
    provider_name               VARCHAR(60),
 
    -- ── ENCOUNTER DETAILS ────────────────────────────────────
    admission_type              VARCHAR(15),
    department                  VARCHAR(40),
    severity_level              SMALLINT,
    admission_date              DATE,
    discharge_date              DATE,
    ed_arrival_time             TIMESTAMP,
    provider_seen_time          TIMESTAMP,
 
    -- ── CLINICAL DETAILS ─────────────────────────────────────
    diagnosis_code              VARCHAR(10),
    diagnosis_description       VARCHAR(100),
    procedure_code              INTEGER,
    procedure_description       VARCHAR(100),
    outcome                     VARCHAR(30),
    discharge_disposition       VARCHAR(40),
    complication_flag           SMALLINT,
    complication_type           VARCHAR(100),
    hospital_acquired_infection SMALLINT,
    quality_incident            VARCHAR(60),
    mortality_flag              SMALLINT,
    patient_satisfaction_score  NUMERIC(4,1),
 
    -- ── FINANCIAL — RAW ──────────────────────────────────────
    payer_type                  VARCHAR(40),
    billed_amount               NUMERIC(10,2),
    allowed_amount              NUMERIC(10,2),
    paid_amount                 NUMERIC(10,2),
 
    -- ── CLAIMS ───────────────────────────────────────────────
    claim_status                VARCHAR(20),
    denial_reason               VARCHAR(60),
    claim_submission_date       DATE,
    claim_processing_days       INTEGER,
 
    -- ── DERIVED — OPERATIONAL ────────────────────────────────
    los                         NUMERIC(6,2),       -- discharge_date - admission_date
    days_to_submit              NUMERIC(6,2),       -- claim_submission_date - discharge_date
    ed_wait_time                NUMERIC(8,2),       -- provider_seen_time - ed_arrival_time (minutes)
 
    -- ── DERIVED — FINANCIAL ──────────────────────────────────
    write_off_amount            NUMERIC(10,2),      -- billed_amount - allowed_amount
    underpayment                NUMERIC(10,2),      -- allowed_amount - paid_amount
    collection_rate             NUMERIC(6,4),       -- paid_amount / billed_amount
    charge_efficiency           NUMERIC(6,4),       -- allowed_amount / billed_amount
    cost_per_los_day            NUMERIC(10,2),      -- billed_amount / los
 
    -- ── DERIVED — FLAGS ──────────────────────────────────────
    denial_flag                 SMALLINT,           -- 1 if claim_status = 'Denied' else 0
    revenue_at_risk             NUMERIC(10,2),      -- billed_amount if denial_flag = 1 else 0
    quality_incident_flag       SMALLINT            -- 1 if quality_incident is not null else 0
 
);


UPDATE hospitals_appended
SET provider_name = CASE
    WHEN TRIM(provider_name) IN ('BabaT Dr.', 'Dr. Babatunde',
                                  'Dr. Baba', 'Dr. Ola')             THEN 'Dr. Babatunde Oladele'
    WHEN TRIM(provider_name) IN ('Dr.  Hoffmann', 'Dr. Amelia',
                                  'Dr.  Hoff')                        THEN 'Dr. Amelia Hoffmann'
    WHEN TRIM(provider_name) IN ('Dr. Chloe B', 'Dr. Chloe ]')       THEN 'Dr. Chloe Beaumont'
    WHEN TRIM(provider_name) IN ('Dr. Nwachukwu', 'Dr. Adaora')      THEN 'Dr. Adaora Nwachukwu'
    WHEN TRIM(provider_name) IN ('Vera')                              THEN 'Dr. Vera Johansson'
    WHEN TRIM(provider_name) IN (' Mendoza', 'Mendoza',
                                  'Dr. Sofia Mendoza')                THEN 'Dr. Carlos Mendoza'
    WHEN TRIM(provider_name) IN ('Weber', 'Dr. Webs',
                                  'Dr. Thomas Weber')                 THEN 'Dr. Jonas Weber'
    WHEN TRIM(provider_name) IN ('Dr.nonso', 'Dr. Nonso')            THEN 'Dr. Chinonso Obiechina'
    WHEN TRIM(provider_name) IN ('Dr. Linh')                         THEN 'Dr. Linh Nguyen'
    WHEN TRIM(provider_name) IN ('Dr. Abena')                        THEN 'Dr. Abena Mensah-Bonsu'
    WHEN TRIM(provider_name) IN ('Dr.  Diallo', 'Dr.Diallo')         THEN 'Dr. Fatou Diallo'
    WHEN TRIM(provider_name) IN ('Dr.  Fashola', 'Dr. Ekundayo F')   THEN 'Dr. Ekundayo Fashola'
    WHEN TRIM(provider_name) IN ('Mensah-Bonsu')                     THEN 'Dr. Abena Mensah-Bonsu'
    WHEN TRIM(provider_name) IN ('Dr. Brend Callahan')               THEN 'Dr. Brendan Callahan'
    ELSE TRIM(provider_name)
END;

-- ------------------------------------------------------------
-- Admission Type
-- ------------------------------------------------------------
UPDATE hospitals_appended
SET admission_type = INITCAP(LOWER(TRIM(admission_type)));


-- ------------------------------------------------------------
-- Department
-- ------------------------------------------------------------
UPDATE hospitals_appended
SET department = CASE
    WHEN LOWER(TRIM(department)) IN ('intmed', 'int.medicine',
                                      'internal med')      THEN 'Internal Medicine'
    WHEN LOWER(TRIM(department)) IN ('surgery',
                                      'gen surge',
                                      'general surg')      THEN 'General Surgery'
    WHEN LOWER(TRIM(department)) = 'emergency'             THEN 'Emergency Medicine'
    ELSE TRIM(department)
END;


-- ------------------------------------------------------------
-- Claim Status
-- ------------------------------------------------------------
UPDATE hospitals_appended
SET claim_status = CASE
    WHEN LOWER(TRIM(claim_status)) IN ('appealling', 'appealing',
                                        'appell', 'appeal',
                                        'appealed', 'under appeal') THEN 'Appealed'
    ELSE INITCAP(LOWER(TRIM(claim_status)))
END;


SELECT * FROM hospitals_appended;


-- ── DIMENSION VIEWS ──────────────────────────────────────

CREATE OR REPLACE VIEW dim_hospitals AS
SELECT DISTINCT
    hospital_code           AS hospital_id,
    hospital_name,
    hospital_type,
    hospital_city,
    total_licensed_beds
FROM hospitals_appended;


CREATE OR REPLACE VIEW dim_patients AS
SELECT DISTINCT
    patient_id,
    patient_age,
    patient_gender
FROM hospitals_appended;


CREATE VIEW dim_providers AS
SELECT DISTINCT
    provider_id,
    provider_name
FROM hospitals_appended
WHERE provider_id IS NOT NULL
ORDER BY provider_id;


CREATE OR REPLACE VIEW dim_diagnoses AS
SELECT DISTINCT
    diagnosis_code,
    diagnosis_description
FROM hospitals_appended;


CREATE OR REPLACE VIEW dim_procedures AS
SELECT DISTINCT
    procedure_code,
    procedure_description
FROM hospitals_appended;


CREATE OR REPLACE VIEW dim_claims AS
SELECT DISTINCT
    claim_id,
    payer_type,
    claim_status,
    denial_reason,
    claim_submission_date,
    claim_processing_days
FROM hospitals_appended;


CREATE OR REPLACE VIEW dim_date AS
SELECT DISTINCT
    admission_date                              AS full_date,
    EXTRACT(YEAR FROM admission_date)::INT      AS year,
    EXTRACT(QUARTER FROM admission_date)::INT   AS quarter,
    EXTRACT(MONTH FROM admission_date)::INT     AS month_number,
    TO_CHAR(admission_date, 'Month')            AS month_name,
    EXTRACT(WEEK FROM admission_date)::INT      AS week_number,
    TO_CHAR(admission_date, 'Day')              AS day_of_week
FROM hospitals_appended
ORDER BY full_date;


-- ── FACT VIEW ────────────────────────────────────────────
DROP VIEW IF EXISTS fact_encounters;

CREATE OR REPLACE VIEW fact_encounters AS
SELECT
    encounter_id,
    claim_id,
    patient_id,
    hospital_code                   AS hospital_id,
    provider_id,
    diagnosis_code,
    procedure_code,
    admission_date                  AS date_id,
    admission_type,
	department,
	quality_incident,
    severity_level,
	total_licensed_beds,
	outcome,
	
    -- ── RAW FINANCIAL ──────────────────────────
    billed_amount,
    allowed_amount,
    paid_amount,

    -- ── DERIVED FINANCIAL ──────────────────────
    write_off_amount,
    underpayment,
    collection_rate,
    charge_efficiency,
    cost_per_los_day,
    revenue_at_risk,

    -- ── DERIVED OPERATIONAL ────────────────────
    los,
    days_to_submit,
    ed_wait_time,

    -- ── FLAGS ──────────────────────────────────
    denial_flag,
    mortality_flag,
    complication_flag,
    hospital_acquired_infection,
    quality_incident_flag,

    -- ── OUTCOME ────────────────────────────────
    patient_satisfaction_score

FROM hospitals_appended;
