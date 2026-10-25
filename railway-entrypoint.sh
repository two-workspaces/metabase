#!/bin/bash
# Start the admin setup next to Metabase; it waits for /api/health, does its
# one-time work and exits.
/app/railway-setup.sh &
# Railway counts page cache as RAM: every 5 minutes, drop the cached pages of
# the 700 MB jar (read once at start and on lazy class loads).
(while sleep 300; do dd if=/app/metabase.jar iflag=nocache count=0 status=none; done) &
exec /app/run_metabase.sh "$@"
