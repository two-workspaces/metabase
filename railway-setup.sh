#!/bin/bash
# First boot: finish Metabase's setup wizard with MB_ADMIN_EMAIL and
# MB_ADMIN_PASSWORD. After that the setup token is gone and this does nothing.
url="http://localhost:${MB_JETTY_PORT:-3000}"
until curl -fs "$url/api/health" >/dev/null; do sleep 0.5; done

token=$(curl -fs "$url/api/session/properties" | sed -n 's/.*"setup-token":"\([^"]*\)".*/\1/p')
[ -n "$token" ] || exit 0

if [ -z "$MB_ADMIN_EMAIL" ] || [ -z "$MB_ADMIN_PASSWORD" ]; then
  echo "[railway-setup] MB_ADMIN_EMAIL or MB_ADMIN_PASSWORD is empty: open the site to finish setup yourself"
  exit 0
fi

body=$(printf '{"token":"%s","user":{"email":"%s","password":"%s","first_name":"Admin","last_name":"User"},"prefs":{"site_name":"%s"}}' \
  "$token" "$MB_ADMIN_EMAIL" "$MB_ADMIN_PASSWORD" "${MB_SITE_NAME:-Metabase}")
resp=$(curl -s -X POST "$url/api/setup" -H 'Content-Type: application/json' -d "$body")
session=$(printf '%s' "$resp" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
if [ -z "$session" ]; then
  echo "[railway-setup] creating the admin failed: $resp"
  exit 1
fi

# Setup turns on anonymous usage tracking; turn it back off.
curl -fs -o /dev/null -X PUT "$url/api/setting/anon-tracking-enabled" \
  -H 'Content-Type: application/json' -H "X-Metabase-Session: $session" -d '{"value":false}'
echo "[railway-setup] admin created: sign in as $MB_ADMIN_EMAIL with the password in MB_ADMIN_PASSWORD"
