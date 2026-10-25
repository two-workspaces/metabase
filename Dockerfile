# Official Metabase image plus a first-boot step that creates the admin
# account from Railway variables, so the setup wizard is never left open on a
# public URL.
FROM metabase/metabase:v0.64.3.4
COPY --chmod=755 railway-entrypoint.sh railway-setup.sh /app/
ENTRYPOINT ["/app/railway-entrypoint.sh"]
