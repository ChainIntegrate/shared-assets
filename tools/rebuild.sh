#!/usr/bin/env bash
# Rigenera i file del repo dalle versioni esatte in tools/package.json.
# Serve solo per aggiungere/verificare una versione: sul VPS non si esegue.
# Una cartella di versione gia' pubblicata NON va mai sovrascritta: per
# aggiornare si aggiunge una nuova cartella (es. ethers/6.14.0/).
set -euo pipefail
cd "$(dirname "$0")"
npm ci --no-audit --no-fund 2>/dev/null || npm install --no-audit --no-fund
N=node_modules
R=..

mkdir -p "$R/ethers/6.13.4"
cp "$N/ethers/dist/ethers.min.js" "$R/ethers/6.13.4/ethers.min.js"
cp "$N/ethers/LICENSE.md"         "$R/ethers/6.13.4/LICENSE.md"

# erc725.js non ha un bundle ESM unico per il browser: lo produce esbuild
mkdir -p "$R/erc725.js/0.28.2"
echo 'export * from "@erc725/erc725.js"; export { default } from "@erc725/erc725.js";' > erc725-entry.mjs
npx esbuild erc725-entry.mjs --bundle --format=esm --platform=browser --minify \
  --legal-comments=eof --outfile="$R/erc725.js/0.28.2/erc725.min.js"
cp "$N/@erc725/erc725.js/LICENSE" "$R/erc725.js/0.28.2/LICENSE"
rm erc725-entry.mjs

mkdir -p "$R/fonts/ibm-plex"
for w in Light Regular Italic Medium SemiBold Bold; do
  cp "$N/@ibm/plex-sans/fonts/complete/woff2/IBMPlexSans-$w.woff2" "$R/fonts/ibm-plex/"
done
for w in Regular Italic Medium SemiBold Bold; do
  cp "$N/@ibm/plex-mono/fonts/complete/woff2/IBMPlexMono-$w.woff2" "$R/fonts/ibm-plex/"
done
cp "$N/@ibm/plex-sans/LICENSE.txt" "$R/fonts/ibm-plex/LICENSE.txt"

cd "$R" && find . -type f \( -name '*.js' -o -name '*.woff2' -o -name '*.css' \) -not -path './tools/*' | sort | xargs sha256sum > SHA256SUMS
echo "Fatto. Controlla 'git diff': le versioni gia' pubblicate non devono cambiare."
