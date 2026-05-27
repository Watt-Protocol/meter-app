-- ═══════════════════════════════════════════════════════════════════════════
--  WATT — full Supabase redo (run in SQL Editor, project bpearpzh...)
--
--  ORDER (one query at a time, or paste each file in full):
--    1. 001_waitlist_login.sql        (if login not set up)
--    2. 002_user_profile_rpc.sql
--    3. 003_user_meters.sql
--    4. 004_mining_events_rpc.sql
--    5. 005_user_profile_referral.sql
--    6. 006_mvp_energy_mining.sql     ← FIXED (device_id patch)
--    7. 007_sensor_readings_rls.sql
--    8. 008_sensor_readings_realtime.sql
--    9. 009_get_user_meters_readings.sql
--   10. 010_wifi_config_insert.sql
--   11. 011_mining_user_cif_tracking.sql
--   12. 012_reset_meter_fresh_start.sql
--
--  If 006 already failed with "device_id does not exist", run ONLY section A below,
--  then continue from step 7 (007…) if those are not applied yet.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── A) Quick fix when mining_events exists without device_id ───────────────
ALTER TABLE public.mining_events
  ADD COLUMN IF NOT EXISTS device_id TEXT;

ALTER TABLE public.mining_events
  ADD COLUMN IF NOT EXISTS kwh NUMERIC;

ALTER TABLE public.mining_events
  ADD COLUMN IF NOT EXISTS watt_earned NUMERIC;

ALTER TABLE public.mining_events
  ADD COLUMN IF NOT EXISTS user_amount NUMERIC NOT NULL DEFAULT 0;

ALTER TABLE public.mining_events
  ADD COLUMN IF NOT EXISTS cif_amount NUMERIC NOT NULL DEFAULT 0;

ALTER TABLE public.mining_events
  ADD COLUMN IF NOT EXISTS cif_tx_hash TEXT;

ALTER TABLE public.mining_events
  ADD COLUMN IF NOT EXISTS error_message TEXT;

UPDATE public.mining_events
SET device_id = 'esp32_001'
WHERE device_id IS NULL OR trim(device_id) = '';

UPDATE public.mining_events
SET kwh = COALESCE(kwh, watt_earned, 0)
WHERE kwh IS NULL;

UPDATE public.mining_events
SET watt_earned = COALESCE(watt_earned, kwh, 0)
WHERE watt_earned IS NULL;

CREATE INDEX IF NOT EXISTS idx_mining_events_user_created
  ON public.mining_events (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_mining_events_device_created
  ON public.mining_events (device_id, created_at DESC);

-- meter_energy_state (energy-worker)
CREATE TABLE IF NOT EXISTS public.meter_energy_state (
  device_id         TEXT PRIMARY KEY,
  user_id           BIGINT REFERENCES public.waitlist_users (id) ON DELETE SET NULL,
  last_energy_kwh   NUMERIC NOT NULL DEFAULT 0,
  pending_kwh       NUMERIC NOT NULL DEFAULT 0,
  last_reading_id   BIGINT,
  paused            BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.meter_energy_state (device_id, user_id, last_energy_kwh, pending_kwh)
VALUES ('esp32_001', 2, 0, 0)
ON CONFLICT (device_id) DO UPDATE SET
  user_id = EXCLUDED.user_id,
  updated_at = NOW();

-- ── B) After 011: fix on-chain mints still showing Pending in app ───────────
-- Run: meter-app/supabase/migrations/013_reconcile_confirmed_mints.sql

-- ── C) After 012: fresh start (keeps waitlist_users) ───────────────────────
-- SELECT reset_watt_meter_fresh_start(2, 'esp32_001');
