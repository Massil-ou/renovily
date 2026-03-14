#!/bin/bash
set -e

HTACCESS_PATH="build/web/.htaccess"

echo "-----------------------------------------"
echo "Création automatique du fichier .htaccess"
echo "-----------------------------------------"

cat << 'EOF' > $HTACCESS_PATH
# Flutter Web SPA Rewrite
RewriteEngine On

# Si fichier ou dossier existe -> le servir normalement
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Sinon -> redirection vers index.html pour permettre à Flutter Web / go_router de gérer l’URL
RewriteRule ^ index.html [L]

# Protection: empêcher listage des dossiers
Options -Indexes
EOF

echo ".htaccess généré dans build/web/"
echo "-----------------------------------------"
