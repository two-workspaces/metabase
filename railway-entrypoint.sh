#!/bin/bash
# Start the admin setup next to Metabase; it waits for /api/health, does its
# one-time work and exits.
/app/railway-setup.sh &
exec /app/run_metabase.sh "$@"
