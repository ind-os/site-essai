// La sonde du site : {"ok":true,"sha":"<commit>"}. Le commit est l'argument de
// build GIT_SHA, lu au moment de `pnpm build` ; vide sans lui. nginx la sert
// avec `Cache-Control: no-store` (nginx.conf).
export function GET() {
  const sha = process.env.GIT_SHA ?? "";
  return new Response(JSON.stringify({ ok: true, sha }), {
    headers: { "Content-Type": "application/json" },
  });
}
