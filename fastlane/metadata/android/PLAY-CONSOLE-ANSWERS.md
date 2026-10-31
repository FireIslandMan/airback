# Play Console answers for AirBack 1.0.0

Prepared 2026-10-18. Use these when filling the forms; the Console wording changes often, so match by meaning.

## App details

- App name: AirBack: TV Mirroring Receiver
- Default language: English (United States). Add Spanish (United States) and Spanish (Spain) with the texts in `en-US`, `es-US`, `es-ES`.
- App or game: App. Category: Tools (alternative: Video Players & Editors).
- Free or paid: Paid. Price: USD 3.99 one-time. Let Play auto-convert other currencies; round to local .99 where offered.
- Developer name shown on the listing: deJesus.biz. Website: https://dejesus.biz. Support email: the one on the developer account.
- Contains ads: No. In-app purchases: No.
- Form factors: Android TV (Google TV). Also opt in to phones and tablets only if you want upstream's phone experience listed; the fork is tuned for TV, so start TV-only.
- Android TV declaration: the app has a leanback launcher banner, is D-pad navigable, declares touchscreen not required. Note for the reviewer: the first-run card asks for "Display over other apps" so the receiver can come forward when a sender connects.

## Privacy policy

Required for every app. LIVE at https://www.dejesus.biz/airback-privacy (terms at https://www.dejesus.biz/airback-terms; product page https://www.dejesus.biz/listing/airback; mirror https://fireislandman.github.io/airback/privacy.html). Set this URL in Play Console > App content > Privacy policy. The page says: AirBack runs entirely on the user's local network; it does not collect, store or transmit personal data to the developer or any third party; mirrored content is decoded on the device and never leaves it; no analytics, no ads, no accounts. Logs the user exports from the Logs tab stay on the device unless the user shares them.

## Data safety form

- Does your app collect or share any of the required user data types? No.
- Is all user data encrypted in transit? Not applicable (no data sent to the developer). If the form forces an answer: Yes, AirPlay sessions on the LAN are encrypted by the protocol.
- Do you provide a way for users to request deletion? Not applicable (nothing collected).
- Security practices: no data collected, so leave the independent security review unchecked.

## Content rating questionnaire (IARC)

- Category: Utility, Productivity, Communication or Other.
- Violence, sexuality, language, controlled substances, gambling: No to all.
- User-generated content or user interaction: No (users do not communicate through the app).
- Shares location: No. Personal information: No. Digital purchases: No.
- Expected result: Everyone / PEGI 3.

## Target audience and content

- Target age: 18 and over (simplest; avoids the Families policy). The app is not designed for children.
- News app: No. COVID-19 app: No. Government app: No.

## App access

- All functionality is available without special access. Reviewer note: an Apple device on the same Wi-Fi network is needed to test receiving; the app itself needs no login.

## Advertising ID

- Does the app use advertising ID? No. (The release build does not include the Play Services ads SDK; confirm with the merged manifest if the Console flags it.)

## Store listing assets

- Icon 512x512: `en-US/images/icon.png`.
- Feature graphic 1024x500: `en-US/images/featureGraphic.png`.
- TV screenshots 1920x1080 (at least 2): `en-US/images/tvScreenshots/`.
- Promo video: none.

## Release

- Track: start with Internal testing, install from the Play link on the TCL to confirm the Play-signed build works, then promote to Production.
- App signing: let Play manage the app signing key; upload with `~/Keys/airback-upload.jks` (alias airback). Passwords are in the macOS login keychain under "AirBack upload keystore".
- Release notes 1.0.0 (EN): First release. AirPlay receiver for Google TV with auto-restore: when the session ends, your TV goes back to what was on. No ads. English and Spanish.
- Release notes 1.0.0 (ES): Primera versión. Receptor AirPlay para Google TV con restauración automática: al terminar la sesión, el televisor vuelve a lo que estaba viendo. Sin anuncios. En inglés y español.
