# Deploy and Host Metabase on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/metabase-production?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=metabase-production)

[Metabase](https://www.metabase.com/) is an open-source business intelligence tool. You connect your databases (Postgres, MySQL, BigQuery, Snowflake, ClickHouse, MongoDB and about twenty more), then ask questions with a point-and-click query builder or SQL, turn the answers into charts and dashboards, and share them with your team, by email or Slack, or as embeds in your own app. This template runs Metabase v0.64.3.4 from the official image with its own Postgres as the application database. The admin account is created on first boot, so the setup wizard is never left open on a public URL.

## About Hosting Metabase

The stack is two services: Metabase and Postgres.

- **Upstream's image, pinned.** Metabase runs `metabase/metabase` at a fixed release (v0.64.3.4), not `latest`. A thin wrapper ([source](https://github.com/two-workspaces/metabase)) adds two scripts and changes nothing else. Upgrading means bumping the tag.
- **Admin ready on first boot.** A fresh Metabase shows a setup wizard to whoever opens it first, and on a public Railway domain that could be anyone. Here a small script waits for Metabase to start, finishes the setup with `MB_ADMIN_EMAIL` and the generated `MB_ADMIN_PASSWORD`, and turns anonymous usage tracking back off. On later boots it does nothing.
- **Postgres as the application database.** Questions, dashboards, users and settings live in Postgres on a volume, not in the embedded H2 file Metabase uses by default (upstream warns against H2 for real use). Migrations run on every start.
- **Encrypted connection details.** `MB_ENCRYPTION_SECRET_KEY` is generated at deploy time and encrypts the passwords of the databases you connect.
- **Bounded memory.** The Java heap is capped at 1 GB (`JAVA_OPTS=-Xmx1g`), and every 5 minutes the wrapper drops the page cache of Metabase's 700 MB jar, which Railway would otherwise bill as RAM.
- **Sample data included.** Metabase's Sample Database (an e-commerce dataset) is there from the start, so you can try questions and dashboards before connecting your own data.

## Common Use Cases

- Company dashboards on top of your production database or warehouse: revenue, signups, churn, funnel
- Self-serve analytics for non-technical teammates through the query builder, with SQL for the rest
- Scheduled reports and alerts by email or Slack when a number crosses a threshold
- Charts and dashboards embedded in your own product (guest embeds work in the open-source edition)

## Dependencies for Metabase Hosting

- Postgres 17 (included, private network only, holds Metabase's own data)
- The databases you want to analyze (any you can reach from Railway)
- An email provider for invitations, password resets and subscriptions (optional)

### Deployment Dependencies

- [Metabase documentation](https://www.metabase.com/docs/latest/)
- [Running Metabase on Docker](https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker)
- [Metabase on GitHub](https://github.com/metabase/metabase)
- [Template source on GitHub](https://github.com/two-workspaces/metabase)

### Implementation Details

**Sign in.** Enter your email in `MB_ADMIN_EMAIL` when you deploy. When the deploy is green, open the Metabase service's Railway domain and sign in with that email and the password in the Metabase service's `MB_ADMIN_PASSWORD` variable. Change the password in Metabase afterwards (your avatar, Account settings, Password); the variable isn't used again. The deploy logs show `[railway-setup] admin created` once the account exists.

**Connect your data.** Admin settings, Databases, Add a database. To analyze a database in the same Railway project, use its private host (for example `postgres.railway.internal`) and port; Metabase reaches it over the private network.

**Add teammates.** Admin settings, People, Invite someone. Without email, Metabase gives you a temporary password to send them yourself, and you reset forgotten passwords the same way. Railway only allows outbound SMTP on the Pro plan. Set it up under Admin settings, Email (or with `MB_EMAIL_SMTP_HOST`, `MB_EMAIL_SMTP_PORT`, `MB_EMAIL_SMTP_USERNAME`, `MB_EMAIL_SMTP_PASSWORD`, `MB_EMAIL_SMTP_SECURITY`) for password resets, subscriptions and alerts. Google sign-in and LDAP are also in the open-source edition.

**Custom domains.** After adding one, set `MB_SITE_URL` to `https://<your domain>` so links in emails and embeds point to it.

**More memory.** For many users or large result sets, raise the heap in `JAVA_OPTS` (for example `-Xmx2g`) and redeploy.

**Upgrading.** Bump the image tag in the Dockerfile of your fork and redeploy. Metabase migrates the application database on start and can't be downgraded, so back up Postgres first.

**Back up.** Postgres holds every question, dashboard, user and setting. Also keep `MB_ENCRYPTION_SECRET_KEY`: without it Metabase can't decrypt the connection details of your databases.

**Resources.** On Railway, after setup and a few queries on the Sample Database, Metabase settled at about 1.4 GB of RAM (a 1 GB Java heap plus the JVM itself) and Postgres at about 160 MB, around 1.6 GB in total. That is over the Trial plan's 1 GB per-service limit, so use the Hobby plan or above. The first boot takes about 30 seconds while Metabase sets up its database.

## Why Deploy Metabase on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Metabase on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
