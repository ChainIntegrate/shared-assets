# shared-assets — ChainIntegrate

Librerie JavaScript e font usati dai frontend ChainIntegrate, **serviti dal
nostro dominio** invece che da CDN di terze parti (Google Fonts, esm.sh,
jsDelivr).

Perché:
- **Privacy** — il browser dei visitatori non contatta servizi esterni solo
  per caricare un font o una libreria (IP e pagina visitata restano a noi).
- **Sicurezza** — il codice eseguito nelle pagine (dove si digitano codici
  segreti e si firmano operazioni) è esattamente quello di questo repo, con
  impronta verificabile, non quello che un CDN decide di servire oggi.
- **Un solo posto** per tutti i progetti sul VPS.

## Contenuto

| Percorso | Versione | Origine | Licenza |
|---|---|---|---|
| `ethers/6.13.4/ethers.min.js` | 6.13.4 | npm `ethers`, file `dist/ethers.min.js` (modulo ES) | MIT |
| `ethers/5.7.2/ethers.umd.min.js` | 5.7.2 | npm `ethers@5.7.2`, file `dist/ethers.umd.min.js` (script classico, globale `ethers`) | MIT |
| `erc725.js/0.28.2/erc725.min.js` | 0.28.2 | npm `@erc725/erc725.js`, impacchettato con esbuild in un unico modulo ES | Apache-2.0 |
| `fonts/ibm-plex/` | Sans 1.1.0, Mono 2.5.0 | npm `@ibm/plex-sans`, `@ibm/plex-mono` (woff2 "complete") | SIL OFL 1.1 |

Font inclusi: IBM Plex Sans 300/400/400 italic/500/600/700, IBM Plex Mono
400/400 italic/500/600/700.

`SHA256SUMS` contiene l'impronta di ogni file. `tools/rebuild.sh` rigenera
tutto dalle versioni esatte in `tools/package.json` e riproduce gli stessi
hash (verificato).

## Regole

1. **Una cartella di versione pubblicata non si modifica mai.** Per
   aggiornare una libreria si aggiunge una nuova cartella (`ethers/6.14.0/`)
   e ogni progetto passa alla nuova versione quando vuole, con la propria PR.
   Così un aggiornamento non rompe mai gli altri progetti.
2. Niente riferimenti "latest" o versioni non fissate.
3. Solo file pubblici e ridistribuibili: questo repo è servito così com'è.

## Installazione sul VPS (una volta)

```bash
cd /var/www
sudo git clone https://github.com/ChainIntegrate/shared-assets.git
cd shared-assets && sha256sum -c SHA256SUMS
```

Poi, nel blocco `server { ... }` di ogni sito che la usa:

```nginx
include /var/www/shared-assets/nginx/shared-assets.conf;
```

e `sudo nginx -t && sudo systemctl reload nginx`.

Aggiornamento: `cd /var/www/shared-assets && git pull && sha256sum -c SHA256SUMS`.

## Uso nelle pagine

```html
<link rel="stylesheet" href="/shared/fonts/ibm-plex/plex.css" />

<script type="module">
  import { ethers } from "/shared/ethers/6.13.4/ethers.min.js";
  // solo dove serve:
  const { ERC725 } = await import("/shared/erc725.js/0.28.2/erc725.min.js");
</script>
```

ethers v5 è un file UMD, non un modulo ES: si include come script classico e
definisce la globale `ethers`:

```html
<script src="/shared/ethers/5.7.2/ethers.umd.min.js"></script>
```

I percorsi `/shared/...` esistono solo dietro Nginx: aprendo un file HTML
direttamente dal disco non vengono trovati.

## Progetti che la usano

| Progetto | Librerie |
|---|---|
| supplier-trust-registry | ethers 6.13.4, erc725.js 0.28.2 (admin), IBM Plex |
| traceability-registry | ethers 5.7.2 (UMD), erc725.js 0.28.2 |

## Licenze

Ogni cartella contiene la licenza originale della libreria o del font.
Il contenuto di questo repo è ridistribuito secondo quelle licenze.
