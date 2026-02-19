# Fair Chance Workforce Enablement Platform

A Next.js + Supabase build-out of the Fair Chance Workforce Enablement Platform.

## Product Vision
This platform helps employers and social service teams support employees with barriers to employment by combining:

1. **Employee Intake & Self-Referral**
2. **Individualized Development Plans**
3. **Case Management & Documentation**
4. **Program Analytics & KPI Dashboards**
5. **Company-Specific Customization**

## Tech Stack (Implemented)
- **Frontend + API:** Next.js App Router
- **Database:** Supabase Postgres
- **Data Client:** `@supabase/supabase-js`
- **Deployment target:** Vercel

## What’s Included in This Repository
- `src/app/page.tsx` – root UI for the platform deployment
- `src/app/api/*` – vertical-slice API routes
  - `GET /api/health`
  - `POST /api/dev/seed`
  - `POST /api/referrals`
  - `POST /api/cases`
  - `POST /api/progress-notes`
  - `GET /api/kpis`
- `src/lib/supabase.ts` – Supabase server client + token auth context
- `supabase/schema.sql` – starter schema for vertical slice tables
- `docs/*` – blueprint, domain model, KPI config, AI workflows, and planning artifacts

## Local Setup
1. Install dependencies:
   ```bash
   npm install
   ```
2. Configure env vars:
   ```bash
   cp .env.example .env.local
   ```
3. Fill `.env.local` with your Supabase values:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
4. Apply `supabase/schema.sql` in your Supabase SQL editor.
5. Run dev server:
   ```bash
   npm run dev
   ```

## Quick API Flow Test
Use `Authorization: Bearer founder-admin-token`.

1. `POST /api/dev/seed`
2. `POST /api/referrals`
3. `POST /api/cases`
4. `POST /api/progress-notes`
5. `GET /api/kpis`

## Vercel Deployment
This project is now structured as a standard Next.js app, so Vercel can build and serve it directly.

## Notes
- Existing documentation under `docs/` remains as product/architecture guidance.
- Legacy Python pilot files remain in-repo for reference, but the active deploy path is Next.js + Supabase.
