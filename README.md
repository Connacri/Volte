<p align="center">
  <img src="https://img.shields.io/github/v/release/Connacri/Volte?style=for-the-badge&label=Version&color=6C5CE7" alt="Version">
  <img src="https://img.shields.io/github/actions/workflow/status/Connacri/Volte/volte-ci.yml?style=for-the-badge&label=CI&color=00D084" alt="CI">
  <img src="https://img.shields.io/badge/Flutter-3.44+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
</p>

<h1 align="center">⚡ Volte</h1>
<p align="center"><strong>Réseau décentralisé P2P — Communications, portefeuille et registre distribué.</strong></p>

<p align="center">
  Volte est un réseau peer-to-peer totalement décentralisé avec chiffrement Ed25519, 
  consensus BFT, gossip protocol, DAG ledger, et messagerie instantanée intégrée.
</p>

---

## ✨ Fonctionnalités

| Module | Description |
|--------|-------------|
| 🌐 **P2P** | Connexion directe entre pairs via WebRTC avec serveur de signalisation |
| 🔐 **Chiffrement** | Signatures Ed25519 (cryptographie réelle, pas de placeholder) |
| 🗣️ **Gossip** | Protocol de diffusion avec déduplication et contrôle TTL |
| 📋 **DAG Ledger** | Registre distribué en DAG avec détection de double-dépense |
| ✅ **Consensus** | BFT avec vote pondéré et score de réputation |
| 💰 **Wallet** | Portefeuille Natif (NovaCoin - 50B supply) |
| 💬 **Chat** | Messagerie instantanée P2P chiffrée |
| 🔄 **Sync** | Synchronisation d'état avec horloge vectorielle |

## 🚀 Téléchargement

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Connacri/Volte/releases/latest">
        <img src="https://img.shields.io/badge/Android-APK-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android APK"><br>
        <strong>volte-android-universal.apk</strong>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/Connacri/Volte/releases/latest">
        <img src="https://img.shields.io/badge/Windows-Portable-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows"><br>
        <strong>volte-windows.zip</strong>
      </a>
    </td>
  </tr>
</table>

> Les builds sont générés automatiquement par GitHub Actions à chaque push sur `main`.

## 📐 Architecture

```
┌──────────────────────────────────────────────┐
│                   Volte App                    │
├──────────────────────────────────────────────┤
│  ┌─────────┐  ┌──────┐  ┌────────┐  ┌─────┐  │
│  │ Wallet  │  │ Chat │  │ Ledger │  │Network│  │
│  └────┬────┘  └──┬───┘  └───┬────┘  └──┬───┘  │
│       └──────────┼──────────┼──────────┘       │
│                  ▼          ▼                   │
│  ┌──────────────────────────────────────────┐  │
│  │              P2PNode                       │  │
│  │  ┌────────┐ ┌──────┐ ┌─────┐ ┌────────┐  │  │
│  │  │Crypto  │ │Gossip│ │ DAG │ │Consensus│  │  │
│  │  │Ed25519 │ │Engine│ │Engine│ │  BFT    │  │  │
│  │  └────────┘ └──────┘ └─────┘ └────────┘  │  │
│  │  ┌────────┐ ┌──────────┐ ┌─────────────┐  │  │
│  │  │WebRTC  │ │  Signal  │ │  SyncEngine  │  │  │
│  │  │ Engine │ │  Client  │ │ (VectorClock)│  │  │
│  │  └────────┘ └──────────┘ └─────────────┘  │  │
│  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## 🛠️ Build local

```bash
# Prérequis
flutter --version  # 3.44.0+

# Dépendances
flutter pub get

# Lancement en dev
flutter run

# Build signé
flutter build apk --release --build-name=1.0.0 --build-number=1
```

### Serveur de signalisation

```bash
cd signaling_server
npm install
node server.js   # ws://localhost:8080
```

## 🤖 CI / CD

| Étape | Description |
|-------|-------------|
| `version` | Calcule la version depuis le dernier tag git (incrémente le patch) |
| `quality` | `flutter analyze` + `flutter test` |
| `build-android` | APK (arm64 + universal) + AAB signés |
| `build-windows` | ZIP portable |
| `publish` | Crée le tag git + GitHub Release avec tous les artefacts |

Pour signer les APK en release, ajoutez ces secrets GitHub :

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Keystore encodé en base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Mot de passe du keystore |
| `ANDROID_KEY_PASSWORD` | Mot de passe de la clé |
| `ANDROID_KEY_ALIAS` | Alias de la clé |

> **Sans ces secrets**, le build utilisera la signature de debug (les builds ne seront pas substituables).

## 📄 License

Distribué sous licence MIT. Voir [LICENSE](LICENSE) pour plus d'informations.

---

<p align="center">
  <sub>Built with ❤️ using Flutter, WebRTC, Ed25519 & DAG Consensus</sub>
</p>

## 📖 Tutoriel d'utilisation

Pour tester Volte, il est recommandé d'utiliser deux instances de l'application (par exemple sur deux téléphones ou un téléphone et un PC).

### 1. Connexion au Réseau
- Lancez l'application.
- Allez dans l'onglet **Network**.
- Assurez-vous d'être "Online" (connecté au serveur de signalisation).
- Une fois qu'un autre utilisateur se connecte, il apparaîtra dans la liste des pairs. WebRTC établira alors une connexion directe.

### 2. Création d'un Portefeuille
- Allez dans l'onglet **Wallet**.
- Appuyez sur le bouton **"Créer un wallet"**.
- Un nouveau portefeuille sera généré avec une adresse unique et un solde initial de 1000 NOVA.
- Vos portefeuilles sont sauvegardés localement et persisteront après le redémarrage de l'app.

### 3. Chat P2P
- Allez dans l'onglet **Chat**.
- Si vous avez au moins un pair connecté (indiqué par le bandeau vert), vous pouvez envoyer des messages.
- Les messages sont diffusés directement à tous vos pairs via WebRTC.

### 4. Transactions et Ledger
- Dans l'onglet **Wallet**, utilisez le formulaire **"Send"** pour envoyer des tokens.
- Copiez l'adresse d'un ami (depuis son onglet Wallet) et collez-la dans le champ "Recipient address".
- Indiquez le montant et appuyez sur **"Send"**.
- La transaction est enregistrée localement dans le **DAG** et diffusée sur le réseau.
- Allez dans l'onglet **Ledger** pour voir l'historique complet de toutes les transactions du réseau.
