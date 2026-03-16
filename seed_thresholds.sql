-- =====================================================
-- SEED DATA: Health Thresholds
-- =====================================================

-- Seed dữ liệu đơn giản theo nhóm tuổi lớn
-- INSERT INTO public.thresholds (metric_type, from_age, to_age, min_value, max_value, level, unit) VALUES

-- -- ─── BLOOD PRESSURE (systolic / mmHg) ───────────────
-- ('blood_pressure', 0,   17,  75,  115, 'NORMAL',   'mmHg'),
-- ('blood_pressure', 18,  59,  90,  120, 'NORMAL',   'mmHg'),
-- ('blood_pressure', 60,  120, 90,  130, 'NORMAL',   'mmHg'),

-- ('blood_pressure', 0,   17,  60,  74,  'DANGER',   'mmHg'),
-- ('blood_pressure', 0,   17,  116, 129, 'DANGER',   'mmHg'),
-- ('blood_pressure', 18,  59,  70,  89,  'DANGER',   'mmHg'),
-- ('blood_pressure', 18,  59,  121, 139, 'DANGER',   'mmHg'),
-- ('blood_pressure', 60,  120, 70,  89,  'DANGER',   'mmHg'),
-- ('blood_pressure', 60,  120, 131, 149, 'DANGER',   'mmHg'),

-- ('blood_pressure', 0,   17,  0,   59,  'CRITICAL', 'mmHg'),
-- ('blood_pressure', 0,   17,  130, 300, 'CRITICAL', 'mmHg'),
-- ('blood_pressure', 18,  59,  0,   69,  'CRITICAL', 'mmHg'),
-- ('blood_pressure', 18,  59,  140, 300, 'CRITICAL', 'mmHg'),
-- ('blood_pressure', 60,  120, 0,   69,  'CRITICAL', 'mmHg'),
-- ('blood_pressure', 60,  120, 150, 300, 'CRITICAL', 'mmHg'),

-- -- ─── BLOOD SUGAR (fasting / mg/dL) ──────────────────
-- ('blood_sugar', 0,   17,  70,  99,  'NORMAL',   'mg/dL'),
-- ('blood_sugar', 18,  59,  70,  99,  'NORMAL',   'mg/dL'),
-- ('blood_sugar', 60,  120, 70,  105, 'NORMAL',   'mg/dL'),

-- ('blood_sugar', 0,   17,  54,  69,  'DANGER',   'mg/dL'),
-- ('blood_sugar', 0,   17,  100, 125, 'DANGER',   'mg/dL'),
-- ('blood_sugar', 18,  59,  54,  69,  'DANGER',   'mg/dL'),
-- ('blood_sugar', 18,  59,  100, 125, 'DANGER',   'mg/dL'),
-- ('blood_sugar', 60,  120, 54,  69,  'DANGER',   'mg/dL'),
-- ('blood_sugar', 60,  120, 106, 125, 'DANGER',   'mg/dL'),

-- ('blood_sugar', 0,   120, 0,   53,  'CRITICAL', 'mg/dL'),
-- ('blood_sugar', 0,   120, 126, 600, 'CRITICAL', 'mg/dL'),

-- -- ─── SPO2 (%) ────────────────────────────────────────
-- ('spo2', 0, 120, 95, 100, 'NORMAL',   '%'),
-- ('spo2', 0, 120, 91, 94,  'DANGER',   '%'),
-- ('spo2', 0, 120, 0,  90,  'CRITICAL', '%'),

-- -- ─── BMI ─────────────────────────────────────────────
-- ('bmi', 5,   17,  14.0, 22.9, 'NORMAL',   'BMI'),
-- ('bmi', 18,  59,  18.5, 24.9, 'NORMAL',   'BMI'),
-- ('bmi', 60,  120, 18.5, 26.9, 'NORMAL',   'BMI'),

-- ('bmi', 5,   17,  12.0, 13.9, 'DANGER',   'BMI'),
-- ('bmi', 5,   17,  23.0, 27.4, 'DANGER',   'BMI'),
-- ('bmi', 18,  59,  16.0, 18.4, 'DANGER',   'BMI'),
-- ('bmi', 18,  59,  25.0, 29.9, 'DANGER',   'BMI'),
-- ('bmi', 60,  120, 16.0, 18.4, 'DANGER',   'BMI'),
-- ('bmi', 60,  120, 27.0, 29.9, 'DANGER',   'BMI'),

-- ('bmi', 5,   120, 0,    11.9, 'CRITICAL', 'BMI'),
-- ('bmi', 5,   120, 30.0, 99.9, 'CRITICAL', 'BMI');






-- Seed dữ liệu chi tiết theo nhóm tuổi lâm sàng

INSERT INTO public.thresholds (metric_type, from_age, to_age, min_value, max_value, level, unit) VALUES

-- ─── BLOOD PRESSURE (systolic / mmHg) ───────────────
-- Sơ sinh (0–1)
('blood_pressure', 0,  1,   60,  90,  'NORMAL',   'mmHg'),
('blood_pressure', 0,  1,   45,  59,  'DANGER',   'mmHg'),
('blood_pressure', 0,  1,   91,  105, 'DANGER',   'mmHg'),
('blood_pressure', 0,  1,   0,   44,  'CRITICAL', 'mmHg'),
('blood_pressure', 0,  1,   106, 300, 'CRITICAL', 'mmHg'),
-- Trẻ nhỏ (2–5)
('blood_pressure', 2,  5,   70,  100, 'NORMAL',   'mmHg'),
('blood_pressure', 2,  5,   55,  69,  'DANGER',   'mmHg'),
('blood_pressure', 2,  5,   101, 115, 'DANGER',   'mmHg'),
('blood_pressure', 2,  5,   0,   54,  'CRITICAL', 'mmHg'),
('blood_pressure', 2,  5,   116, 300, 'CRITICAL', 'mmHg'),
-- Trẻ em (6–11)
('blood_pressure', 6,  11,  80,  110, 'NORMAL',   'mmHg'),
('blood_pressure', 6,  11,  60,  79,  'DANGER',   'mmHg'),
('blood_pressure', 6,  11,  111, 124, 'DANGER',   'mmHg'),
('blood_pressure', 6,  11,  0,   59,  'CRITICAL', 'mmHg'),
('blood_pressure', 6,  11,  125, 300, 'CRITICAL', 'mmHg'),
-- Thiếu niên (12–17)
('blood_pressure', 12, 17,  85,  120, 'NORMAL',   'mmHg'),
('blood_pressure', 12, 17,  65,  84,  'DANGER',   'mmHg'),
('blood_pressure', 12, 17,  121, 139, 'DANGER',   'mmHg'),
('blood_pressure', 12, 17,  0,   64,  'CRITICAL', 'mmHg'),
('blood_pressure', 12, 17,  140, 300, 'CRITICAL', 'mmHg'),
-- Người lớn (18–59)
('blood_pressure', 18, 59,  90,  120, 'NORMAL',   'mmHg'),
('blood_pressure', 18, 59,  70,  89,  'DANGER',   'mmHg'),
('blood_pressure', 18, 59,  121, 139, 'DANGER',   'mmHg'),
('blood_pressure', 18, 59,  0,   69,  'CRITICAL', 'mmHg'),
('blood_pressure', 18, 59,  140, 300, 'CRITICAL', 'mmHg'),
-- Người cao tuổi (60+)
('blood_pressure', 60, 120, 90,  130, 'NORMAL',   'mmHg'),
('blood_pressure', 60, 120, 70,  89,  'DANGER',   'mmHg'),
('blood_pressure', 60, 120, 131, 149, 'DANGER',   'mmHg'),
('blood_pressure', 60, 120, 0,   69,  'CRITICAL', 'mmHg'),
('blood_pressure', 60, 120, 150, 300, 'CRITICAL', 'mmHg'),

-- ─── BLOOD SUGAR (fasting / mg/dL) ──────────────────
-- Sơ sinh (0–1): ngưỡng thấp hơn vì hay bị hypoglycemia
('blood_sugar', 0,  1,   50,  90,  'NORMAL',   'mg/dL'),
('blood_sugar', 0,  1,   36,  49,  'DANGER',   'mg/dL'),
('blood_sugar', 0,  1,   91,  120, 'DANGER',   'mg/dL'),
('blood_sugar', 0,  1,   0,   35,  'CRITICAL', 'mg/dL'),
('blood_sugar', 0,  1,   121, 600, 'CRITICAL', 'mg/dL'),
-- Trẻ em & thiếu niên (2–17)
('blood_sugar', 2,  17,  70,  99,  'NORMAL',   'mg/dL'),
('blood_sugar', 2,  17,  54,  69,  'DANGER',   'mg/dL'),
('blood_sugar', 2,  17,  100, 125, 'DANGER',   'mg/dL'),
('blood_sugar', 2,  17,  0,   53,  'CRITICAL', 'mg/dL'),
('blood_sugar', 2,  17,  126, 600, 'CRITICAL', 'mg/dL'),
-- Người lớn (18–59)
('blood_sugar', 18, 59,  70,  99,  'NORMAL',   'mg/dL'),
('blood_sugar', 18, 59,  54,  69,  'DANGER',   'mg/dL'),
('blood_sugar', 18, 59,  100, 125, 'DANGER',   'mg/dL'),
('blood_sugar', 18, 59,  0,   53,  'CRITICAL', 'mg/dL'),
('blood_sugar', 18, 59,  126, 600, 'CRITICAL', 'mg/dL'),
-- Người cao tuổi (60+)
('blood_sugar', 60, 120, 70,  105, 'NORMAL',   'mg/dL'),
('blood_sugar', 60, 120, 54,  69,  'DANGER',   'mg/dL'),
('blood_sugar', 60, 120, 106, 125, 'DANGER',   'mg/dL'),
('blood_sugar', 60, 120, 0,   53,  'CRITICAL', 'mg/dL'),
('blood_sugar', 60, 120, 126, 600, 'CRITICAL', 'mg/dL'),

-- ─── SPO2 (%) ────────────────────────────────────────
-- Không đổi theo tuổi
('spo2', 0, 120, 95, 100, 'NORMAL',   '%'),
('spo2', 0, 120, 91, 94,  'DANGER',   '%'),
('spo2', 0, 120, 0,  90,  'CRITICAL', '%'),

-- ─── BMI ─────────────────────────────────────────────
-- Không áp dụng cho sơ sinh / trẻ dưới 2 (dùng cân nặng theo chuẩn WHO riêng)
-- Trẻ em (2–5): xấp xỉ WHO
('bmi', 2,  5,   14.0, 17.9, 'NORMAL',   'BMI'),
('bmi', 2,  5,   12.5, 13.9, 'DANGER',   'BMI'),
('bmi', 2,  5,   18.0, 19.9, 'DANGER',   'BMI'),
('bmi', 2,  5,   0,    12.4, 'CRITICAL', 'BMI'),
('bmi', 2,  5,   20.0, 99.9, 'CRITICAL', 'BMI'),
-- Trẻ em (6–11)
('bmi', 6,  11,  13.5, 20.9, 'NORMAL',   'BMI'),
('bmi', 6,  11,  12.0, 13.4, 'DANGER',   'BMI'),
('bmi', 6,  11,  21.0, 24.9, 'DANGER',   'BMI'),
('bmi', 6,  11,  0,    11.9, 'CRITICAL', 'BMI'),
('bmi', 6,  11,  25.0, 99.9, 'CRITICAL', 'BMI'),
-- Thiếu niên (12–17)
('bmi', 12, 17,  15.0, 22.9, 'NORMAL',   'BMI'),
('bmi', 12, 17,  13.0, 14.9, 'DANGER',   'BMI'),
('bmi', 12, 17,  23.0, 27.4, 'DANGER',   'BMI'),
('bmi', 12, 17,  0,    12.9, 'CRITICAL', 'BMI'),
('bmi', 12, 17,  27.5, 99.9, 'CRITICAL', 'BMI'),
-- Người lớn (18–59)
('bmi', 18, 59,  18.5, 24.9, 'NORMAL',   'BMI'),
('bmi', 18, 59,  16.0, 18.4, 'DANGER',   'BMI'),
('bmi', 18, 59,  25.0, 29.9, 'DANGER',   'BMI'),
('bmi', 18, 59,  0,    15.9, 'CRITICAL', 'BMI'),
('bmi', 18, 59,  30.0, 99.9, 'CRITICAL', 'BMI'),
-- Người cao tuổi (60+): ngưỡng trên nới lỏng hơn chút
('bmi', 60, 120, 18.5, 26.9, 'NORMAL',   'BMI'),
('bmi', 60, 120, 16.0, 18.4, 'DANGER',   'BMI'),
('bmi', 60, 120, 27.0, 29.9, 'DANGER',   'BMI'),
('bmi', 60, 120, 0,    15.9, 'CRITICAL', 'BMI'),
('bmi', 60, 120, 30.0, 99.9, 'CRITICAL', 'BMI');