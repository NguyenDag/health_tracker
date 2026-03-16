-- =====================================================
-- STEP 1: Helper function to check admin role
-- security definer = runs as owner, bypasses RLS
-- Fixes infinite recursion when policies query public.users
-- =====================================================

create or replace function is_admin()
returns boolean
security definer
set search_path = public
language sql
as $$
  select exists (
    select 1 from public.users
    where id = auth.uid() and role = 'admin'
  );
$$;

-- =====================================================
-- STEP 2: Function to fetch all users for admin panel
-- Joins auth.users to get email + last_sign_in_at
-- =====================================================

create or replace function get_all_users_for_admin()
returns table (
  id              uuid,
  email           text,
  first_name      text,
  last_name       text,
  gender          text,
  height          double precision,
  weight          double precision,
  phone           text,
  role            text,
  dob             timestamp,
  status          text,
  created_at      timestamp,
  last_sign_in_at timestamptz
)
security definer
set search_path = public
language sql
as $$
  select
    u.id,
    au.email,
    u.first_name,
    u.last_name,
    u.gender,
    u.height,
    u.weight,
    u.phone,
    u.role,
    u.dob,
    u.status,
    u.created_at,
    au.last_sign_in_at
  from public.users u
  join auth.users au on u.id = au.id
  where is_admin()
    and u.role = 'user'
  order by u.created_at desc;
$$;

-- =====================================================
-- STEP 3: RLS policies using is_admin() – no recursion
-- Drop old ones first
-- =====================================================

drop policy if exists "admin can view all users" on public.users;
drop policy if exists "admin can update all users" on public.users;
drop policy if exists "admin can delete all users" on public.users;

-- SELECT policy: admin xem được tất cả user
-- (cần thiết để UPDATE hoạt động – PostgreSQL yêu cầu row phải SELECT được trước)
create policy "admin can view all users"
on public.users
for select
using (is_admin() or auth.uid() = id);

-- UPDATE policy: admin update được tất cả user
create policy "admin can update all users"
on public.users
for update
using (is_admin())
with check (is_admin());

-- =====================================================
-- STEP 4: Thresholds RLS
-- =====================================================

alter table public.thresholds enable row level security;

drop policy if exists "anyone can read thresholds" on public.thresholds;
drop policy if exists "admin can manage thresholds" on public.thresholds;

-- All authenticated users can read thresholds
create policy "anyone can read thresholds"
on public.thresholds
for select
using (auth.uid() is not null);

-- Only admin can insert / update / delete
create policy "admin can manage thresholds"
on public.thresholds
for all
using (is_admin())
with check (is_admin());
