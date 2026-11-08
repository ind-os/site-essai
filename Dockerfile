# L'image du site : `docker build --build-arg GIT_SHA=<commit> .` depuis la
# racine du dépôt. Astro construit les pages, nginx les sert sur le port 80.

FROM node:24.21.0-alpine3.24@sha256:ebfe2f90462722a7a4de65e91990e97fe0d401c70e0e762c5b53302f905ec1c1 AS construction

# pnpm à la version de `packageManager` (package.json).
RUN npm install --global pnpm@12.16.1

WORKDIR /site
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

# Le commit que rend la sonde (/healthz.json), vide sans lui.
ARG GIT_SHA=""
RUN GIT_SHA="$GIT_SHA" pnpm build

FROM nginx:1.30.6-alpine3.24@sha256:0e52bd054126cdc040b1276c0af347aeb02a41b9cfe305d6094767ac30e97949

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=construction /site/dist /usr/share/nginx/html

EXPOSE 80

# wget est celui de busybox, présent dans l'image ; curl n'y est pas.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/healthz.json || exit 1
