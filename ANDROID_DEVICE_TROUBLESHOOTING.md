# Guide de dépannage pour la connexion Android

Votre Galaxy Z Fold 5 est détecté en USB mais pas par ADB. Suivez ces étapes :

## Étapes à suivre sur votre téléphone

### 1. Activer le mode développeur
1. Allez dans **Paramètres** > **À propos du téléphone**
2. Trouvez **Numéro de build** (ou **Numéro de version**)
3. **Tapez 7 fois** sur "Numéro de build" jusqu'à voir "Vous êtes maintenant développeur !"

### 2. Activer le débogage USB
1. Retournez dans **Paramètres**
2. Allez dans **Options pour les développeurs** (ou **Paramètres développeur**)
3. Activez **Débogage USB**
4. Activez aussi **Restaurer les autorisations USB** (optionnel mais recommandé)

### 3. Autoriser le débogage USB
1. Connectez votre téléphone via USB
2. Sur votre téléphone, une popup devrait apparaître : **"Autoriser le débogage USB ?"**
3. Cochez **"Toujours autoriser depuis cet ordinateur"**
4. Cliquez sur **"Autoriser"**

### 4. Vérifier le mode de connexion USB
1. Dans la barre de notification, vérifiez le mode USB
2. Il devrait être en **"Transfert de fichiers"** ou **"MTP"**
3. Si c'est en **"Chargement uniquement"**, changez-le

### 5. Si la popup n'apparaît pas
1. Déconnectez et reconnectez le câble USB
2. Essayez un autre port USB sur votre Mac
3. Essayez un autre câble USB (de préférence un câble de données, pas juste de chargement)

## Vérification sur le Mac

Après avoir suivi les étapes ci-dessus, exécutez ces commandes :

```bash
# Redémarrer ADB
~/Library/Android/sdk/platform-tools/adb kill-server
~/Library/Android/sdk/platform-tools/adb start-server

# Vérifier les appareils
~/Library/Android/sdk/platform-tools/adb devices

# Vérifier avec Flutter
flutter devices
```

## Si ça ne fonctionne toujours pas

1. **Révoquer les autorisations USB** :
   - Sur le téléphone : Paramètres > Options pour les développeurs > Révoquer les autorisations de débogage USB
   - Redéconnectez et reconnectez

2. **Installer Samsung USB Driver** (si nécessaire) :
   - Téléchargez depuis : https://developer.samsung.com/mobile/android-usb-driver.html
   - Sur macOS, cela peut ne pas être nécessaire, mais essayez si rien d'autre ne fonctionne

3. **Vérifier les permissions macOS** :
   - Assurez-vous que votre Mac autorise les connexions USB
   - Vérifiez dans Préférences Système > Sécurité et confidentialité

4. **Mode PTP au lieu de MTP** :
   - Parfois, passer en mode PTP (Appareil photo) peut aider

## Installation manuelle de l'APK

Si ADB ne fonctionne toujours pas, vous pouvez installer l'APK manuellement :

1. L'APK est déjà construit : `build/app/outputs/flutter-apk/app-debug.apk`
2. Transférez-le sur votre téléphone (via email, cloud, etc.)
3. Sur le téléphone, allez dans Paramètres > Sécurité > Autoriser les sources inconnues
4. Ouvrez le fichier APK et installez-le

