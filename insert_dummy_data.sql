-- User ID: 773bff1d-ea86-4b44-9e6d-da4de8b28a22

DO $$
DECLARE
    target_user_id UUID := '773bff1d-ea86-4b44-9e6d-da4de8b28a22';
    day_offset INTEGER;
    record_date TIMESTAMP;
BEGIN
    FOR day_offset IN 0..29 LOOP
        record_date := NOW() - (day_offset || ' days')::INTERVAL;

        -- 1. Huyết áp (Blood Pressure)
        INSERT INTO blood_pressure_records (user_id, created_at, systolic, diastolic, pulse, result, note)
        VALUES (target_user_id, record_date, 110 + (random() * 30)::INTEGER, 70 + (random() * 20)::INTEGER, 60 + (random() * 20)::INTEGER, 'Bình thường', 'Dữ liệu test 30 ngày');

        -- 2. Đường huyết (Blood Sugar)
        -- Chú ý: dùng 'mgDl' và 'beforeMeal'
        INSERT INTO blood_sugar_records (user_id, created_at, glucose_value, sugar_unit, sugar_measurement_type, result, note)
        VALUES (target_user_id, record_date, 80 + (random() * 40)::INTEGER, 'mgDl', 'beforeMeal', 'Ổn định', 'Dữ liệu test 30 ngày');

        -- 3. SpO2
        -- Chú ý: dùng 'resting'
        INSERT INTO spo2_condition_records (user_id, created_at, spo2, condition, result, note)
        VALUES (target_user_id, record_date, 95 + (random() * 4)::INTEGER, 'resting', 'Tốt', 'Dữ liệu test 30 ngày');

        -- 4. Cân nặng (Weight)
        INSERT INTO weight_records (user_id, created_at, weight, body_fat, result, note)
        VALUES (target_user_id, record_date, 70 + (random() * 5)::NUMERIC(4,1), 20 + (random() * 5)::NUMERIC(3,1), 'Ổn định', 'Dữ liệu test 30 ngày');
    END LOOP;
END $$;
