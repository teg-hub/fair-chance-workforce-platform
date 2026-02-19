export default function HomePage() {
  return (
    <main>
      <div className="card">
        <h1>Fair Chance Workforce Enablement Platform</h1>
        <p>Next.js + Supabase vertical slice is now configured for Vercel deployment.</p>
      </div>

      <div className="card">
        <h2>Implemented API Routes</h2>
        <ul>
          <li><code>GET /api/health</code></li>
          <li><code>POST /api/dev/seed</code></li>
          <li><code>POST /api/referrals</code></li>
          <li><code>POST /api/cases</code></li>
          <li><code>POST /api/progress-notes</code></li>
          <li><code>GET /api/kpis</code></li>
        </ul>
      </div>

      <div className="card">
        <h2>Docs</h2>
        <ul>
          <li><a href="/docs/fair-chance-platform-blueprint.md">Platform Blueprint</a></li>
          <li><a href="/docs/domain-model.sql">Domain Model</a></li>
          <li><a href="/README.md">README</a></li>
        </ul>
      </div>
    </main>
  );
}
