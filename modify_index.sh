#!/bin/bash

echo "🏗️ Modification de build/web/index.html pour Renovily..."

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX_PATH="$PROJECT_ROOT/build/web/index.html"

if [ ! -f "$INDEX_PATH" ]; then
  echo "❌ Fichier introuvable : $INDEX_PATH"
  exit 1
fi

# Désactiver le service worker
sed -i '/flutter_service_worker\.js/d' "$INDEX_PATH"

# Titre et description
sed -i 's|<title>.*</title>|<title>Renovily – Trouvez un professionnel du BTP en Algérie</title>|' "$INDEX_PATH"
sed -i 's|<meta name="description" content="[^"]*">|<meta name="description" content="Renovily vous aide à trouver des professionnels du BTP en Algérie : maçon, plombier, peintre, carreleur, électricien et autres artisans. Consultez les annonces, comparez les profils et trouvez le bon pro facilement.">|' "$INDEX_PATH"

# Keywords + robots
sed -i '/<meta name="description"/a\
<meta name="keywords" content="BTP Algérie, maçon Algérie, plombier Algérie, peintre Algérie, carreleur Algérie, électricien Algérie, artisans Algérie, Renovily">\
<meta name="robots" content="index, follow">' "$INDEX_PATH"

# Icônes
sed -i 's|<link rel="icon"[^>]*>|<link rel="icon" type="image/png" href="assets/assets/icons/renovily-icon.png"/>|' "$INDEX_PATH"
sed -i 's|<link rel="apple-touch-icon"[^>]*>|<link rel="apple-touch-icon" href="assets/assets/icons/renovily-icon-192.png">|' "$INDEX_PATH"

# Open Graph
sed -i '/<meta name="robots"/a\
<meta property="og:title" content="Renovily – Trouvez un professionnel du BTP en Algérie">\
<meta property="og:description" content="Renovily facilite la recherche de professionnels du BTP en Algérie : maçon, plombier, peintre, carreleur, électricien et autres artisans.">\
<meta property="og:image" content="assets/assets/icons/renovily-icon.png">\
<meta property="og:type" content="website">' "$INDEX_PATH"

echo "✅ index.html modifié avec succès."