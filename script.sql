-- =====================================================
-- EXTENSIONS
-- =====================================================

create extension if not exists "pgcrypto";

-- =====================================================
-- USERS PROFILE
-- =====================================================

create table public.users (
    id uuid primary key references auth.users(id) on delete cascade,
    first_name text,
    last_name text,
    gender text check (gender in ('male','female','other')),
    height double precision,
    weight double precision,
    phone text,
    role text default 'user',
    dob timestamp,
    status text default 'active',
    created_at timestamp default now()
);

-- =====================================================
-- BLOOD PRESSURE RECORDS
-- =====================================================

create table public.blood_pressure_records (
    id uuid primary key default gen_random_uuid(),
    systolic int not null,
    diastolic int not null,
    pulse int,
    note text,
    result text,
    user_id uuid not null references public.users(id) on delete cascade,
    created_at timestamp default now()
);

-- =====================================================
-- BLOOD SUGAR RECORDS
-- =====================================================

create table public.blood_sugar_records (
    id uuid primary key default gen_random_uuid(),
    glucose_value double precision not null,
    sugar_unit text check (sugar_unit in ('mgDl','mmolL')),
    sugar_measurement_type text check (
        sugar_measurement_type in ('fasting','beforeMeal','afterMeal')
    ),
    note text,
    result text,
    user_id uuid not null references public.users(id) on delete cascade,
    created_at timestamp default now()
);

-- =====================================================
-- SPO2 RECORDS
-- =====================================================

create table public.spo2_condition_records (
    id uuid primary key default gen_random_uuid(),
    spo2 int not null,
    condition text check (condition in ('resting','afterExercise')),
    note text,
    result text,
    user_id uuid not null references public.users(id) on delete cascade,
    created_at timestamp default now()
);

-- =====================================================
-- WEIGHT RECORDS
-- =====================================================

create table public.weight_records (
    id uuid primary key default gen_random_uuid(),
    weight double precision not null,
    body_fat double precision,
    note text,
    result text,
    user_id uuid not null references public.users(id) on delete cascade,
    created_at timestamp default now()
);

-- =====================================================
-- THRESHOLDS (CONFIG HEALTH METRICS)
-- =====================================================

create table public.thresholds (
    id uuid primary key default gen_random_uuid(),
    metric_type text not null,
    from_age int,
    to_age int,
    min_value double precision,
    max_value double precision,
    level text check (level in ('NORMAL','DANGER','CRITICAL')),
    unit text,
    created_at timestamp default now()
);

-- =====================================================
-- NOTIFICATIONS
-- =====================================================

create table public.notifications (
    id uuid primary key default gen_random_uuid(),
    type text check (type in ('alert','reminder')),
    title text,
    body text,
    is_read boolean default false,
    triggered_at timestamp,
    user_id uuid references public.users(id) on delete cascade,
    created_at timestamp default now()
);

-- =====================================================
-- INDEXES
-- =====================================================

create index idx_bp_user on public.blood_pressure_records(user_id);
create index idx_bs_user on public.blood_sugar_records(user_id);
create index idx_spo2_user on public.spo2_condition_records(user_id);
create index idx_weight_user on public.weight_records(user_id);
create index idx_notifications_user on public.notifications(user_id);

-- =====================================================
-- AUTO CREATE PROFILE WHEN USER SIGNUP
-- =====================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.users (
    id,
    first_name,
    last_name,
    phone,
    gender,
    height,
    weight,
    dob
  )
  values (
    new.id,
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'gender',
    (new.raw_user_meta_data->>'height')::double precision,
    (new.raw_user_meta_data->>'weight')::double precision,
    (new.raw_user_meta_data->>'dob')::timestamp
  );

  return new;
end;
$$;


create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

alter table public.users enable row level security;
alter table public.blood_pressure_records enable row level security;
alter table public.blood_sugar_records enable row level security;
alter table public.spo2_condition_records enable row level security;
alter table public.weight_records enable row level security;
alter table public.notifications enable row level security;

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- users
create policy "users can view own profile"
on public.users
for select
using (auth.uid() = id);

create policy "users can update own profile"
on public.users
for update
using (auth.uid() = id);

-- blood pressure
create policy "users manage own bp"
on public.blood_pressure_records
for all
using (auth.uid() = user_id);

-- blood sugar
create policy "users manage own sugar"
on public.blood_sugar_records
for all
using (auth.uid() = user_id);

-- spo2
create policy "users manage own spo2"
on public.spo2_condition_records
for all
using (auth.uid() = user_id);

-- weight
create policy "users manage own weight"
on public.weight_records
for all
using (auth.uid() = user_id);

-- notifications
create policy "users read own notifications"
on public.notifications
for all
using (auth.uid() = user_id);