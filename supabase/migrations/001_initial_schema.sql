-- MantraStreak – Initial Schema
-- Run this in your Supabase SQL Editor (Dashboard → SQL Editor → New query)

-- -----------------------------------------------------------------------
-- profiles: stores per-user onboarding settings
-- -----------------------------------------------------------------------
create table if not exists public.profiles (
  id              uuid references auth.users on delete cascade primary key,
  selected_deities text[]      not null default '{}',
  reminder_time    text        not null default '06:00',
  reminder_period  text        not null default 'AM',
  selected_days    text[]      not null default '{}',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- Auto-create a profile row when a new user signs up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- -----------------------------------------------------------------------
-- streaks: tracks current / best streak and total prayer count
-- -----------------------------------------------------------------------
create table if not exists public.streaks (
  user_id          uuid references auth.users on delete cascade primary key,
  current_streak   int         not null default 0,
  best_streak      int         not null default 0,
  total_prayer_days int        not null default 0,
  last_prayer_date date,
  updated_at       timestamptz not null default now()
);

-- -----------------------------------------------------------------------
-- prayer_sessions: one row per completed prayer session
-- -----------------------------------------------------------------------
create table if not exists public.prayer_sessions (
  id               uuid        primary key default gen_random_uuid(),
  user_id          uuid        references auth.users on delete cascade not null,
  completed_at     date        not null,
  prayer_title     text,
  deity            text,
  mood             text,
  duration_minutes int,
  created_at       timestamptz not null default now()
);

create index if not exists prayer_sessions_user_id_idx
  on public.prayer_sessions (user_id);

create index if not exists prayer_sessions_completed_at_idx
  on public.prayer_sessions (user_id, completed_at);

-- -----------------------------------------------------------------------
-- Row-Level Security (RLS)
-- Each user can only access their own rows.
-- -----------------------------------------------------------------------
alter table public.profiles       enable row level security;
alter table public.streaks        enable row level security;
alter table public.prayer_sessions enable row level security;

-- profiles policies
create policy "Users can view own profile"
  on public.profiles for select using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

-- streaks policies
create policy "Users can view own streaks"
  on public.streaks for select using (auth.uid() = user_id);

create policy "Users can insert own streaks"
  on public.streaks for insert with check (auth.uid() = user_id);

create policy "Users can update own streaks"
  on public.streaks for update using (auth.uid() = user_id);

-- prayer_sessions policies
create policy "Users can view own sessions"
  on public.prayer_sessions for select using (auth.uid() = user_id);

create policy "Users can insert own sessions"
  on public.prayer_sessions for insert with check (auth.uid() = user_id);
