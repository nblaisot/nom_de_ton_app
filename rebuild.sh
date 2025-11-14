#!/bin/bash

# Script pour nettoyer et reconstruire le projet Flutter après les corrections

set -e

echo "🧹 Nettoyage du projet Flutter..."
flutter clean

echo ""
echo "📦 Mise à jour des dépendances..."
flutter pub get

echo ""
echo "🔨 Tentative de build Android..."
flutter build apk --debug

echo ""
echo "✅ Build terminé !"





