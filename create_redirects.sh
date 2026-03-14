#!/bin/bash
set -e

REDIRECTS_PATH="build/web/_redirects"

echo "-----------------------------------------"
echo "Création automatique du fichier _redirects"
echo "-----------------------------------------"

cat << 'EOF' > "$REDIRECTS_PATH"
/*    /index.html   200
EOF

echo "_redirects généré dans build/web/"
echo "-----------------------------------------"
