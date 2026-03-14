#!/bin/bash

echo "🔁 Modification du manifest.json..."

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="$PROJECT_ROOT/build/web/manifest.json"

if [ -f "$MANIFEST_PATH" ]; then
  jq '
    .name = "Renovily" |
    .short_name = "Renovily" |
    .display = "browser" |
    .start_url = "/" |
    .theme_color = "#111827" |
    .background_color = "#F8FAFC" |
    .description = "Renovily vous aide à trouver des professionnels du BTP en Algérie : maçon, plombier, peintre, carreleur, électricien et autres artisans. Consultez les annonces, comparez les profils et trouvez le bon pro facilement."
  ' "$MANIFEST_PATH" > "$MANIFEST_PATH.tmp" && mv "$MANIFEST_PATH.tmp" "$MANIFEST_PATH"

  echo "✅ manifest.json mis à jour avec succès."
else
  echo "❌ Fichier manifest.json non trouvé : $MANIFEST_PATH"
  exit 1
fi