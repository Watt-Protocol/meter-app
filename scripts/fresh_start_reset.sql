-- Run in Supabase SQL Editor after migration 012 is applied.
-- Replace user id and device id with yours (see waitlist_users.id, user_meters.device_id).

-- 1) Apply migration 012_reset_meter_fresh_start.sql if not already applied.

-- 2) Clear readings, mining, worker state, and user balances for one meter:
SELECT reset_watt_meter_fresh_start(2, 'esp32_001');

-- 3) Restart services on your machine:
--    cd services/energy-worker && node index.js
--    cd watt-minter && node index.js
--    ESP32 posting sensor_readings again

-- Optional: wipe ALL users/devices (dev only):
-- SELECT reset_watt_meter_fresh_start(NULL, NULL);
