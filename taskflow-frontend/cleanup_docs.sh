#!/bin/bash

# 🧹 Script de nettoyage de documentation - TaskFlow Frontend
# Ce script supprime les fichiers de documentation redondants
# Usage: bash cleanup_docs.sh

echo "🧹 Nettoyage de la documentation TaskFlow..."
echo ""

# Fichiers à supprimer dans DOCS/
FILES_TO_DELETE=(
    "DOCS/DOCUMENTATION_INDEX.md"
    "DOCS/NEXT_STEPS.md"
    "DOCS/README_SUMMARY.md"
    "DOCS/CHANGES_SUMMARY.md"
    "DOCS/TECHNICAL_CHANGES_SUMMARY.md"
)

# Suppression des fichiers individuels
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        echo "❌ Suppression de : $file"
        rm "$file"
    else
        echo "⏭️  Fichier non trouvé : $file"
    fi
done

# Suppression du dossier Bootstrap Documentation/
if [ -d "DOCS/Bootstrap Documentation" ]; then
    echo "❌ Suppression du dossier : DOCS/Bootstrap Documentation/"
    rm -rf "DOCS/Bootstrap Documentation"
else
    echo "⏭️  Dossier non trouvé : DOCS/Bootstrap Documentation/"
fi

echo ""
echo "✅ Nettoyage terminé!"
echo ""
echo "📚 Documentation restante :"
echo "   • README.md (Point d'entrée principal)"
echo "   • TODO.md (Prochaines étapes)"
echo "   • DOCS/BOOTSTRAP_GUIDE_FR.md (Guide complet)"
echo "   • DOCS/CHANGELOG.md (Détails techniques)"
echo "   • DOCS/PROJECT_STRUCTURE.md (Arborescence)"
echo ""

