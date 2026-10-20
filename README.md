# WypeLock

[Français](#français) · [English](#english)

## Français

WypeLock bloque temporairement le clavier d'un Mac pour nettoyer les touches sans rien déclencher. L'app vit dans la barre des menus.

Pendant le verrouillage :

- toutes les touches sont ignorées : lettres, chiffres, Cmd, Option, Ctrl, Maj, Fn, Verr. Maj, flèches, touches de fonction et touches média (luminosité, volume, lecture, Mission Control…) ;
- une superposition plein écran affiche le temps restant et un bouton « Déverrouiller » ;
- le trackpad reste actif, sauf si l'option « Verrouiller aussi le trackpad » est activée ;
- le clavier se déverrouille automatiquement à la fin de la minuterie (2 minutes par défaut).

macOS 13 Ventura ou plus récent, Apple Silicon et Intel.

### Installation

1. Téléchargez `WypeLock-<version>.dmg` depuis la page [Releases](https://github.com/pierrecadiet/WypeLock/releases).
2. Ouvrez le DMG et glissez WypeLock dans le dossier Applications.
3. Lancez WypeLock depuis Applications.

Si la release n'est pas notarisée, macOS refuse de l'ouvrir au premier lancement. Deux solutions :

- clic droit (ou Ctrl-clic) sur WypeLock dans Applications, puis **Ouvrir**, puis **Ouvrir** dans la boîte de dialogue ;
- ou tentez d'ouvrir l'app une fois, puis allez dans **Réglages Système > Confidentialité et sécurité** et cliquez sur **Ouvrir quand même** en bas de la page.

Sur macOS 15 et plus récent, seule la seconde méthode fonctionne.

### Autorisation d'Accessibilité

WypeLock doit pouvoir intercepter les frappes. Au premier lancement, la fenêtre de réglages s'ouvre et indique si l'autorisation manque.

1. Cliquez sur **Ouvrir les Réglages Système**.
2. Dans **Confidentialité et sécurité > Accessibilité**, activez WypeLock.

Après une mise à jour d'une version non signée avec un compte développeur, macOS peut considérer l'app comme différente : retirez WypeLock de la liste avec le bouton « – », puis ajoutez-la de nouveau.

### Utilisation

- Cliquez sur l'icône clavier dans la barre des menus, puis sur **Verrouiller le clavier**.
- Nettoyez.
- Cliquez sur **Déverrouiller**, ou attendez la fin du compte à rebours.

Dans **Réglages…** :

- **Déverrouiller automatiquement après** : de 30 secondes à 10 minutes.
- **Verrouiller aussi le trackpad** : le curseur et les clics sont bloqués, seule la minuterie met fin au verrouillage.

Si l'app plante ou est quittée, le blocage disparaît avec elle : l'interception est liée au processus et macOS la retire immédiatement. Si l'app cesse de répondre, macOS désactive aussi l'interception au bout de quelques secondes.

### Limites connues

- Le bouton d'alimentation / Touch ID n'est pas bloquable : il est géré par le matériel. Un appui peut verrouiller la session ou mettre le Mac en veille, un appui long l'éteint.
- Verr. Maj : la frappe est bloquée, mais selon les modèles le voyant et l'état majuscule peuvent quand même basculer.
- Certaines touches spéciales sont traitées par le firmware ou par macOS avant toute app, selon le modèle (rétroéclairage du clavier, touches dédiées sur certains claviers externes).
- Avec le trackpad verrouillé, certains gestes système (balayage à trois ou quatre doigts) peuvent encore passer selon la version de macOS. Le retour haptique du clic reste perceptible.
- Tous les claviers sont bloqués, y compris les claviers externes.
- L'écran de connexion et l'écran de verrouillage de macOS ne sont pas couverts.

### Compiler depuis les sources

Prérequis : Xcode 16 ou plus récent, et `create-dmg` pour le DMG.

```sh
brew install create-dmg
open WypeLock.xcodeproj
```

Le préfixe du bundle identifier et la version se règlent dans `Config.xcconfig` (`BUNDLE_ID_PREFIX`, `MARKETING_VERSION`).

Créer le DMG avec une signature ad hoc :

```sh
./build_dmg.sh
```

Avec un certificat Developer ID et la notarisation :

```sh
SIGN_IDENTITY="Developer ID Application: Nom (TEAMID)" \
APPLE_ID="vous@exemple.com" \
APPLE_TEAM_ID="TEAMID" \
APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
./build_dmg.sh
```

Le DMG est créé dans `build/WypeLock-<version>.dmg`.

### Publier une release

Le workflow `.github/workflows/release.yml` compile l'app, crée le DMG et publie une release GitHub à chaque tag `v*`.

```sh
git tag v1.0.0
git push origin v1.0.0
```

Sans secret configuré, le DMG est signé ad hoc. Pour signer et notariser, ajoutez ces secrets au dépôt :

| Secret | Contenu |
| --- | --- |
| `DEVELOPER_ID_P12` | Certificat Developer ID Application exporté en .p12, encodé en base64 (`base64 -i cert.p12 \| pbcopy`) |
| `DEVELOPER_ID_P12_PASSWORD` | Mot de passe du .p12 |
| `APPLE_ID` | Identifiant Apple du compte développeur |
| `APPLE_TEAM_ID` | Team ID |
| `APPLE_APP_PASSWORD` | Mot de passe d'app généré sur appleid.apple.com |

### Licence

MIT

## English

WypeLock temporarily locks a Mac keyboard so you can clean the keys without triggering anything. It lives in the menu bar.

While locked:

- every key is ignored: letters, numbers, Cmd, Option, Control, Shift, Fn, Caps Lock, arrows, function keys and media keys (brightness, volume, playback, Mission Control…);
- a full-screen overlay shows the remaining time and an Unlock button;
- the trackpad keeps working, unless "Lock the trackpad too" is enabled;
- the keyboard unlocks automatically when the timer ends (2 minutes by default).

Requires macOS 13 Ventura or later, Apple Silicon or Intel.

### Installation

1. Download `WypeLock-<version>.dmg` from the [Releases](https://github.com/pierrecadiet/WypeLock/releases) page.
2. Open the DMG and drag WypeLock to Applications.
3. Launch WypeLock from Applications.

If the release is not notarized, macOS blocks it on first launch. Either:

- right-click (or Control-click) WypeLock in Applications, choose **Open**, then **Open** again in the dialog;
- or try to open the app once, then go to **System Settings > Privacy & Security** and click **Open Anyway** at the bottom of the page.

On macOS 15 and later, only the second method works.

### Accessibility permission

WypeLock needs to intercept key presses. On first launch the settings window opens and shows whether the permission is missing.

1. Click **Open System Settings**.
2. In **Privacy & Security > Accessibility**, enable WypeLock.

After updating a build that is not signed with a developer account, macOS may treat it as a different app: remove WypeLock from the list with the "–" button and add it again.

### Usage

- Click the keyboard icon in the menu bar, then **Lock Keyboard**.
- Clean.
- Click **Unlock**, or wait for the countdown to finish.

In **Settings…**:

- **Unlock automatically after**: from 30 seconds to 10 minutes.
- **Lock the trackpad too**: pointer and clicks are blocked, only the timer ends the lock.

If the app crashes or quits, the lock goes away with it: the event tap belongs to the process and macOS removes it immediately. If the app stops responding, macOS also disables the tap after a few seconds.

### Known limitations

- The power / Touch ID button cannot be blocked: it is handled by the hardware. A press may lock the session or put the Mac to sleep, a long press shuts it down.
- Caps Lock: the key press is blocked, but depending on the model the LED and caps state may still toggle.
- Some special keys are handled by the firmware or by macOS before any app sees them, depending on the model (keyboard backlight, dedicated keys on some external keyboards).
- With the trackpad locked, some system gestures (three or four finger swipes) may still go through depending on the macOS version. Click haptic feedback is still felt.
- All keyboards are blocked, external ones included.
- The macOS login and lock screens are not covered.

### Building from source

Requires Xcode 16 or later, and `create-dmg` for the DMG.

```sh
brew install create-dmg
open WypeLock.xcodeproj
```

The bundle identifier prefix and the version live in `Config.xcconfig` (`BUNDLE_ID_PREFIX`, `MARKETING_VERSION`).

Build the DMG with an ad hoc signature:

```sh
./build_dmg.sh
```

With a Developer ID certificate and notarization:

```sh
SIGN_IDENTITY="Developer ID Application: Name (TEAMID)" \
APPLE_ID="you@example.com" \
APPLE_TEAM_ID="TEAMID" \
APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
./build_dmg.sh
```

The DMG is written to `build/WypeLock-<version>.dmg`.

### Publishing a release

`.github/workflows/release.yml` builds the app, creates the DMG and publishes a GitHub release for every `v*` tag.

```sh
git tag v1.0.0
git push origin v1.0.0
```

Without secrets the DMG is signed ad hoc. To sign and notarize, add these repository secrets:

| Secret | Value |
| --- | --- |
| `DEVELOPER_ID_P12` | Developer ID Application certificate exported as .p12, base64 encoded (`base64 -i cert.p12 \| pbcopy`) |
| `DEVELOPER_ID_P12_PASSWORD` | .p12 password |
| `APPLE_ID` | Apple ID of the developer account |
| `APPLE_TEAM_ID` | Team ID |
| `APPLE_APP_PASSWORD` | App-specific password from appleid.apple.com |

### License

MIT
