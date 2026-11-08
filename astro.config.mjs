// @ts-check
import { defineConfig } from "astro/config";

// Un site statique : `pnpm build` écrit les pages dans dist/, que nginx sert.
export default defineConfig({
  devToolbar: {
    enabled: false,
  },
});
