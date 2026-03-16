-- =====================================================
-- SEED DATA: Health Thresholds (new schema)
-- Columns: metric_type, from_age, to_age,
--          normal_min, normal_max, danger_min, danger_max, unit
-- 3 age groups: 0-17, 18-59, 60+
-- Metrics: blood_pressure_systolic, blood_pressure_diastolic,
--          blood_pressure_pulse, blood_sugar, spo2
-- =====================================================


--value trong [normal_min, normal_max]   → NORMAL
--value trong [danger_min, normal_min)   → DANGER  
--value trong (normal_max, danger_max]   → DANGER
--ngoài danger range                     → CRITICAL

-- Drop & recreate table with new schema
DROP TABLE IF EXISTS public.thresholds;

CREATE TABLE public.thresholds (
  id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_type TEXT    NOT NULL,
  from_age    INT,
  to_age      INT,
  normal_min  FLOAT8  NOT NULL,
  normal_max  FLOAT8  NOT NULL,
  danger_min  FLOAT8  NOT NULL,
  danger_max  FLOAT8  NOT NULL,
  unit        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── SEED ────────────────────────────────────────────

INSERT INTO public.thresholds (metric_type, from_age, to_age, normal_min, normal_max, danger_min, danger_max, unit) VALUES

-- Blood Pressure Systolic (mmHg)
('blood_pressure_systolic', 0,  17,  80,  120, 60,  139, 'mmHg'),
('blood_pressure_systolic', 18, 59,  90,  120, 70,  139, 'mmHg'),
('blood_pressure_systolic', 60, 120, 90,  130, 70,  149, 'mmHg'),

-- Blood Pressure Diastolic (mmHg)
('blood_pressure_diastolic', 0,  17,  50,  75,  35,  85,  'mmHg'),
('blood_pressure_diastolic', 18, 59,  60,  80,  50,  89,  'mmHg'),
('blood_pressure_diastolic', 60, 120, 60,  80,  50,  89,  'mmHg'),

-- Blood Pressure Pulse (bpm)
('blood_pressure_pulse', 0,  17,  70,  120, 55,  150, 'bpm'),
('blood_pressure_pulse', 18, 59,  60,  100, 50,  110, 'bpm'),
('blood_pressure_pulse', 60, 120, 60,  100, 50,  110, 'bpm'),

-- Blood Sugar - fasting (mg/dL)
('blood_sugar', 0,  17,  70,  99,  54,  125, 'mg/dL'),
('blood_sugar', 18, 59,  70,  99,  54,  125, 'mg/dL'),
('blood_sugar', 60, 120, 70,  105, 54,  125, 'mg/dL'),

-- SpO2 (%)
('spo2', 0, 120, 95, 100, 91, 100, '%');
