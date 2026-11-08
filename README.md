# site-essai

Le site d'essai d'Indos, copie du modèle `ind-os/modele-de-site` : une page
« Hello World », publiée par son dépôt sur le banc d'essai d'Indos
(`ind-os/serveur-essai`). Il sert les essais du kit sur un site publié par son
dépôt (l'installation, le retrait, la publication par une poussée sur `main`)
et la remontée du banc sur une machine neuve, qui le reprend à sa route. Il ne
sert que le banc : les secrets de redéploiement de son dépôt sont ceux du banc.

- Astro 7, sortie statique, une page « Hello World » ; pnpm 12, épinglé par
  `packageManager`.
- L'image : Astro construit les pages, nginx les sert sur le port 80. Le site
  n'a aucune route serveur ; nginx suffit, sans runtime Node à l'exécution.

## Travailler dessus

```bash
pnpm install
pnpm dev            # http://localhost:4321
pnpm build          # dist/
```

Hors d'un terminal interactif (Claude Code), `astro dev` démarre en arrière-plan
et rend la main ; `pnpm astro dev status` et `pnpm astro dev stop` le suivent.

## Construire et lancer l'image

```bash
docker build --build-arg GIT_SHA="$(git rev-parse HEAD)" -t site .
docker run --rm -p 8080:80 site
```

- Un seul port exposé : **80**.
- La sonde : `GET /healthz.json` rend `{"ok":true,"sha":"<GIT_SHA>"}`, avec
  `Cache-Control: no-store`. Le commit est l'argument de build `GIT_SHA`, écrit
  dans la page au moment de `pnpm build` ; vide sans lui.
- Le `HEALTHCHECK` demande la sonde par le `wget` de busybox (l'image nginx
  alpine n'a pas curl).

## La publication

`.github/workflows/publier.yml`, à chaque poussée sur `main` :

1. construit l'image avec `GIT_SHA` au commit et la pousse sur
   `ghcr.io/<compte>/<dépôt>`, étiquetée `main` et par le commit, avec le
   `GITHUB_TOKEN` du workflow (`packages: write`) ;
2. si les secrets `REDEPLOIEMENT_ADRESSE` et `REDEPLOIEMENT_JETON` existent :
   `POST` sur l'adresse, avec le jeton en `Authorization: Bearer`, puis attend
   que `<SITE_ADRESSE>/healthz.json` rende ce commit ; rouge après dix minutes.
   Sans ces deux secrets, le résumé du workflow dit que rien n'est publié, et le
   workflow finit vert.

Les poussées passent l'une après l'autre (`concurrency`, sans annulation de la
publication en cours). GitHub ne garde qu'une publication en attente : d'une
rafale de poussées, la dernière est publiée, et celles d'entre deux sont
annulées avant de commencer.

Ce que le dépôt reçoit du serveur qui sert le site, posé par le kit d'Indos à
l'installation :

| Nom | Sorte | Contenu |
| --- | --- | --- |
| `REDEPLOIEMENT_ADRESSE` | secret | l'adresse qui fait reprendre l'image `main` au serveur |
| `REDEPLOIEMENT_JETON` | secret | le jeton de cette adresse |
| `SITE_ADRESSE` | variable | l'adresse du site en ligne, `https://site.exemple.ch` |

Le serveur tire l'image sans identifiant : le paquet GHCR se rend public une
fois, après la première poussée, dans les réglages du paquet sur GitHub. Un
paquet naît privé.

## Claude Code

- `CLAUDE.md` : les gestes de la personne, pour Claude Code : préparer
  l'ordinateur, prévisualiser, publier, revenir à une version d'avant.
- `.claude/settings.json` : Claude ne modifie ni `.github/` ni `.claude/`, ne
  lance ni `gh secret`, ni `gh api`, ni `gh variable set` ou `delete`, ni les
  gestes de `gh auth` qui rendent ou changent le jeton, et ne force aucune
  poussée.
