# Evaluation: jqssun/android-airplay-server as a base for a paid Google TV AirPlay receiver

Date: 2026-10-18. Evaluated at upstream commit e347ee5 (v0.0.33, released the same day).

**TL;DR:** Go on the engineering side. It builds, installs and runs on your TCL Google TV, advertises itself within a second, and a 10-minute Mac mirroring session on this 32-bit MediaTek set ran clean: hardware H.264 at 1080p, no crash, no SELinux denial, issue #50 does not reproduce here. Two things are still open: (1) the iPhone-only checks (Photos video, YouTube, Music), which need you and the phone; and (2) whether a paid fork of a free GPL app can justify its price, which is positioning, not engineering.

## Build health

Result: builds on this Mac. Debug APK at `app/build/outputs/apk/debug/app-debug.apk`.

| Item | Value |
|---|---|
| Toolchain used | Android Studio 2025.3 bundled JDK 21, Gradle 9.8.1 (wrapper downloads it), AGP 9.4.1, Kotlin 2.2.10, KSP 2.3.12, Hilt 2.60.1 |
| SDK components Gradle auto-installed | NDK 27.0.12077973, CMake 3.22.1, Build-Tools 36.0.0, Platform android-37 (licenses were already accepted) |
| Setup needed | `local.properties` with `sdk.dir=/Users/gamalier/Library/Android/sdk`; `JAVA_HOME` pointed at Android Studio's JBR because the system `java` is a stub |
| APK | 48.9 MB debug, native libs for arm64-v8a, armeabi-v7a, x86_64; minSdk 24, targetSdk 37; leanback declared not-required so it installs on phones and TVs |
| Clean native build time | roughly 6 minutes per ABI (OpenSSL 3.4.4 and FFmpeg compiled from source); incremental rebuilds under 2 minutes |
| Compiler warnings | about 5,300 lines, almost all from third-party C (libplist, FFmpeg). Not a concern. |

Build-hygiene notes for a fork:

- openssl-cmake downloads the OpenSSL tarball at build time with no hash pinned (CMake warns "no hash specified"). It re-downloads on each clean configure, and a half-finished extraction breaks the next run with "directory not empty". Pin `URL_HASH` or vendor the tarball. Upstream CI avoids this by always building clean.
- KSP/Hilt can fail on a cold first build with a missing generated file (`MainViewModel_HiltModules.java`); a plain rerun fixes it.
- Gradle's NDK auto-install can report a failure on the first run even though the install completed; rerun.

Caveat: two Claude sessions ran Gradle in this folder at the same time for part of today, which corrupted the native build directory and caused most of the five attempts. One clean, uninterrupted run would most likely succeed first time, so do not read the retry count as fragility.

## Repo health

| Item | Value |
|---|---|
| Created | 2026-04-08 (six months old) |
| Last push | 2026-10-18 |
| Stars / forks | 624 / 98 |
| Releases | v0.0.29 (Aug 3) → v0.0.30 (Aug 4) → v0.0.31 (Aug 23) → v0.0.32 (Oct 16) → v0.0.33 (Oct 18) |
| Commits on main | 58 |
| Contributors | 10, but jqssun has 42 commits and the next has 5 |
| Open issues | 12 |
| License | GPL-3.0 |
| Distribution | Free on Google Play, F-Droid and GitHub releases |

Bus factor is one. The author ships fast and closes issues (recent closed ones cover Fire TV sleep, Mac mirroring drops, keyframe instability on older Google TV, screensaver during mirroring). If jqssun stops, you inherit the native layer alone, which is why the architecture split below matters.

Open issues that matter for a Google TV product:

- #50 Mirroring dies in under a second on some devices: SELinux blocks `/dev/ashmem`. Device-specific, needs testing on your TV.
- #51 HEVC decoder not detected even when hardware supports it.
- #49 AirPlay video (HLS) playback fails with an ExoPlayer source error on the local proxy.
- #41 Photos app images and videos fail to AirPlay.
- #52 "Open app on connect" doesn't come to the foreground when PIN is on.
- #36 and #53 Volume handling problems when used as an audio receiver.

Issues #49 and #41 are the ones a paying customer would hit on day one (sending a video from Photos is the second most common use after mirroring).

## Architecture: what is whose

| Layer | Size | Role |
|---|---|---|
| Kotlin app (`app/src/main/kotlin`) | 7,684 lines, 43 files | Compose UI (Material 3), TV focus handling, settings, foreground service, boot receiver, mDNS advertising, MediaCodec video pipeline, Oboe/AudioTrack audio, ExoPlayer HLS, DACP remote control, media session |
| Own native glue (`app/src/main/cpp`, 4 files) | 2,650 lines | JNI bridge, audio engine (Oboe), Android DNS-SD shim, RAOP callbacks |
| UxPlay (submodule, v1.73.7 + local patches) | third party | AirPlay/RAOP protocol, FairPlay, mirroring stream, HLS relay |
| FFmpeg n8.1.2 (submodule) | third party | Software ALAC decoder only |
| OpenSSL 3.4.4 via openssl-cmake, libplist | third party | Crypto and plist parsing for the protocol |

Toolchain: AGP 9.4.1, Gradle 9.8.1, Kotlin 2.2.10, Compose BOM 2024.12, Hilt, Media3 1.11.0-beta01, NDK 27.0.12077973, CMake 3.22+, minSdk 24, targetSdk and compileSdk 37. JDK 21 (CI uses Zulu 21; Android Studio's bundled JBR 21 works).

What a fork would realistically touch: almost entirely the Kotlin layer. UI and onboarding (`ui/`), settings (`Prefs.kt`, `SettingsScreen.kt`), the service lifecycle and wake handling (`service/AirPlayService.kt`, `BootReceiver.kt`), and the video pipeline for decoder fallbacks (`renderer/`). The protocol work lives in UxPlay and is upstream's problem, which is the right place for it. You would carry UxPlay patches in `app/src/main/cpp/patches/UxPlay` the same way upstream does.

Already present, so not work you need to do: auto-start on boot (default on), foreground service holding a partial wake lock while serving, keep-screen-on, PIN auth, no ads, D-pad navigation, leanback launcher banner, overscan and resolution settings, HEVC, debug overlay, settings over ADB for headless boxes.

Not present: any localization. Strings exist only in English (`res/values`, plus night and television variants), so Spanish is real work, not a toggle.

## Licensing and positioning

- GPL-3 means your fork's source must be public. You can still sell it on Play. Nothing in GPL-3 forbids charging.
- Anyone can rebuild and republish. Your moat is the listing, ratings, brand, support, and release cadence. For a $4.99 TV utility that is enough, since TV users do not sideload.
- The awkward part: upstream is already free and ad-free on Play. A paid fork competes with the author's own listing using the author's code. Legal, but it burns the relationship you most need (bus factor one). Two cleaner options: (a) sponsor jqssun and contribute the Google TV fixes upstream, then ship your own branded build with a TV-first onboarding and paid support, or (b) differentiate on what upstream will not do: a polished first-run flow, Spanish localization, guest-mode for rentals (PIN rotation per stay, which is directly useful in your Fajardo and Villalba units), and a managed update channel.
- Your own LAN shows the competitive reality: two TCL Roku TVs ("LIVING ROOM 55", "LOFT LR 55") already advertise licensed AirPlay 2 out of the box. The market for this app is Google TV sets and dongles that shipped without Apple's license, which is most non-Sony Google TVs, Chromecast with Google TV, and the Google TV Streamer.
- DRM content (Netflix, Disney+, Apple TV+) will never work. Say it in the listing's first line or you inherit AirScreen's one-star reviews.

## Manual test checklist (run on the Google TV with your iPhone)

Install the debug APK, open it once, then run each item and note pass/fail plus any lag you feel.

1. Device name: does the TV appear in the iPhone AirPlay picker within 3 seconds, with the name you set in settings? PASSED, but see the hostname collision section: the default name must change.
2. Screen mirroring: mirror the iPhone home screen, scroll, open an app. Note latency (under ~150 ms feels live), dropped frames, and whether rotation is handled.
3. Mirroring stability: keep mirroring for 10 minutes. Does it survive, or die within a second (issue #50)? PASSED with the Mac as sender, 10 min 42 s, see the test result section. iPhone mirroring also connects and decodes cleanly (short session).
4. Photos video: AirPlay a 4K60 video from the Photos app (not mirroring, the AirPlay button inside the video). Does it play with seek working (issues #41, #49)?
5. Photos stills: AirPlay a photo and swipe through several.
6. YouTube: tap AirPlay inside the YouTube app. Expect it to work; note if it falls back to mirroring.
7. Apple Music: play a track. Check cover art, track info, volume control from the iPhone, and that audio does not clip or jump to 100% (issues #36, #53).
8. Sleep and wake: let the TV sleep with the app idle, wake it, and reconnect from the iPhone without opening the app by hand.
9. Reboot: power-cycle the TV and confirm the receiver is advertised again without touching the remote (BootReceiver).
10. PIN: enable PIN, connect, and check that the TV brings the PIN screen forward (issue #52).
11. HEVC: in the debug overlay, confirm the codec shows hevc when mirroring from a recent iPhone (issue #51).
12. Mac: mirror from the Mac for 5 minutes (issue #54 regression check). PASSED, 10 min 42 s without a drop.

Pass on 1, 2, 3, 4, 8 and 9 is the go bar. Items 1, 2, 3 and 12 have passed. Fail on 4 on your TV model means the fork starts with HLS and ExoPlayer debugging (issues #41, #49), which changes the scope estimate below.

## Go / no-go and two-week scope

Go if the checklist passes the bar above. The engineering risk is low: the hard protocol work is upstream and maintained, and the Kotlin layer is small enough to read in an afternoon.

Two-week scope if go:

- Days 1 to 2: fork under the Lalus GitHub org, keep GPL-3 and the credits, rename package ID and branding, set up a signing key and a Play Console listing (paid, no ads, DRM disclaimer up top).
- Days 3 to 6: TV-first onboarding (one screen: name, PIN, autostart) and settings cleanup. Default the receiver name to the Google TV device name (see the hostname collision section). Spanish localization. Remove anything phone-oriented from the TV flow.
- Days 7 to 9: stability pass on your TV model: wake lock and sleep handling, reconnect after network change, decoder fallback on mirroring start failure.
- Days 10 to 11: internal testing track, test on a second Google TV model if you can borrow one (Chromecast with Google TV is the most common device and is 32-bit).
- Days 12 to 14: listing assets, release build, submit. Open PRs upstream for any fix that is not branding.

Kill criteria: if the Play listing does not reach 50 paid installs in its first 60 days with zero ad spend, stop and leave the fork public as a contribution.

## Install on the Google TV

Target found on the LAN: "Living Room TV", Cast model "Smart TV Pro", Cast firmware 3.72.446070, IP 192.168.40.110. ADB over TCP on port 5555 is enabled on it. At the time of writing the Mac is listed as `unauthorized`, which means the TV is showing an "Allow USB debugging?" prompt that has to be accepted with the remote (tick "Always allow from this computer").

Install command once authorized:

```bash
~/Library/Android/sdk/platform-tools/adb connect 192.168.40.110:5555 && ~/Library/Android/sdk/platform-tools/adb install -r app/build/outputs/apk/debug/app-debug.apk
```

Install status: done. Authorized, installed with `adb install -r`, launched, server started on port 7000 and registered `_airplay._tcp` and `_raop._tcp` as "Android AirPlay" within one second (visible from the Mac with `dns-sd -B _airplay._tcp local`). Screenshot of the first launch: `tv-first-launch.png`.

Device facts (from `adb shell getprop`):

| Item | Value |
|---|---|
| Hardware | TCL "Smart TV Pro", product G05_4K_US, SoC MediaTek mt5889, Mali-G52 GPU |
| Android | 11 (API 30), Google TV with leanback |
| ABI | armeabi-v7a only (32-bit). The arm64 and x86_64 libs in the APK are dead weight here; a release build still needs armeabi-v7a, so do not drop it. |
| RAM | 2.7 GB |
| Panel | 1920x1080 reported by `wm size` (4K product name notwithstanding) |
| SELinux | Enforcing |
| Decoders the app picked | avc=OMX.MS.AVC.Decoder, hevc=OMX.MS.HEVC.Decoder (hardware). Issue #51, HEVC not detected, does not reproduce on this set. |

First-launch observations:

- The service auto-started and advertised without any taps. Boot auto-start is on by default.
- No errors or SELinux denials from the app in logcat at idle. Whether `/dev/ashmem` gets denied once mirroring starts (issue #50, reported on a MediaTek Android 10 set) can only be seen during an actual mirroring session. This is the single most important test on the checklist.
- The UI is a phone layout scaled to the TV: a bottom navigation bar (Overview, Logs, Settings), Material 3 light purple, a large empty "Waiting for connection" card. It works with the D-pad but does not look like a TV app. That is the most visible thing a fork would change.

## Mirroring test result (Mac sender, 2026-10-18, 17:24 to 17:35)

The iPhone was not available to this session, so the Mac mirrored its built-in display to "Android AirPlay" from System Settings > Displays. The Mac uses the same mirroring path (H.264 stream over the legacy AirPlay protocol) that UxPlay decodes for an iPhone, so this exercises the decoder, the surface and the MediaTek SELinux policy that issue #50 is about. Screenshot of the TV mid-session: `tv-mirroring-mac.png`.

| Item | Result |
|---|---|
| Session length | 10 min 42 s (connect 17:24:42, clean disconnect 17:35:25), no drops |
| Decoder | OMX.MS.AVC.Decoder (hardware H.264), 1920x1080, surface attached on first try |
| Process | Same pid for the whole session, foreground service kept, activity on top at the end |
| CPU (app process, from `top`) | 22% at 5 min, 29% at 10 min, on a 4-core 1.3 GHz MediaTek |
| Memory (RSS) | 139 MB at 5 min, 143 MB at 10 min, no growth to worry about |
| Crashes | 0 (no FATAL, SIGSEGV or SIGABRT in 1,015,640 logcat lines) |
| SELinux denials for the app | 0. Issue #50 (`/dev/ashmem`) does not reproduce on this Android 11 MediaTek set |
| Disconnect | Clean: MediaCodec stopped and released, service dropped back to audio mode, still advertising |

Harmless noise seen in the log: `setPortMode ... DynamicANWBuffer failed w/ err -1010` and three `setting nBufferCountActual ... failed: -22` lines from ACodec at codec start. Both are the MediaTek OMX component refusing optional settings; the decoder ran fine after them.

One real finding for the fork: when the TV was in the Google TV ambient screensaver at connect time, the mirror was invisible for 30 seconds. The service tried to start `MainActivity` the moment the client connected (17:24:42), Android 11 logged it as a blocked background activity start, and the screensaver only ended on its own at 17:25:12. After that the activity was on top and stayed there. A customer would read those 30 seconds as "it doesn't work". The fix lives in the Kotlin layer: launch the activity from a full-screen-intent notification (the Android 10+ sanctioned way for a foreground service), and set `setTurnScreenOn` and `setShowWhenLocked` on the activity so it also comes up from standby. Upstream issue #52 is the same bug seen from the PIN flow. This belongs in the days 7 to 9 stability pass and is a good first upstream PR.

## iPhone test result and the hostname collision (2026-10-18, 17:38 to 17:49)

First iPhone attempt: "Android AirPlay" was listed in the AirPlay picker but the connection spun and never completed. The TV log showed zero connection attempts and `netstat` showed no TCP traffic on port 7000, so the phone's unicast traffic was going somewhere else.

Cause: the app registers its services through Android's `NsdManager`, which advertises them under the system mDNS hostname, which on Google TV is the generic `Android.local`. Another device on this LAN (192.168.40.38, it also advertises `_googlecast` and `_androidtvremote2`, so another Android TV box) already owned `Android.local`, and the TV's records were renamed to `Android-2.local` by conflict resolution. The iPhone had the earlier `Android.local` target cached for the "Android AirPlay" instance, resolved it to 192.168.40.38, where nothing listens on 7000, and spun. The Mac was unaffected because it resolved fresh.

Fix applied for the test: renamed the receiver over ADB (`server_name` = "Living Room TV"), which creates records the phone has never cached. After a Wi-Fi toggle on the phone it connected first try: portrait mirror 498x1080, hardware H.264, no errors, no SELinux denials, same process. The phone sent H.264, not HEVC, so item 11 is still open.

Why this matters for a product: any home with two Android TV devices hits this, and Chromecast with Google TV plus a second Google TV set is a common pairing. Two fork items: (1) default `server_name` to the Google TV device name (`settings get global device_name` returns "Living Room TV" here) instead of the generic "Android AirPlay", so two receivers never share an instance name; and (2) advertise under a unique hostname. `NsdServiceInfo.setHostname` only exists from API 34, so on Android 11 to 13 that means registering through UxPlay's built-in mDNS (new in UxPlay 1.74) instead of `NsdManager`, which is the larger change and a candidate upstream PR. Default service name from device name alone would have avoided today's failure.

Still untested because it needs the iPhone in hand: Photos video over HLS (issues #41, #49), YouTube, Apple Music volume and cover art, PIN prompt visibility, HEVC from a recent iPhone, sleep and wake reconnect, and reboot re-advertising.


## Fork work done on 2026-10-18 (branch `lalus-fork`) and features to market

Built, installed and verified on the TCL set:

- Receiver name defaults to the TV's own device name ("Living Room TV") on first launch, so two receivers on one LAN never share a generic name. Verified after a data reset.
- Wake on connect: the service wakes the display when a sender connects. Verified from the screensaver: screensaver gone 0.4 s after connect, down from 30 s.
- Comes forward over live TV: with the "Display over other apps" permission granted (`appops set <pkg> SYSTEM_ALERT_WINDOW allow` for the test; the first-run flow must ask for it), the receiver surfaced 80 ms after a connect while the TV was on the DirecTV input. Without that permission Android 11 blocks the launch and the sender spins with no picture, which is the AirScreen-class complaint.
- Auto-restore on disconnect: when the last sender drops and the receiver had brought itself forward, it steps back so the TV returns to what was showing (the DirecTV input, another app). Stock behavior, in this app and in AirScreen, is to sit on an idle screen. Settings switch "Return to previous screen on disconnect", default on.
- Spanish localization, complete (161 strings).

Marketing angles from the above, in the owner's words: auto-restore on disconnect ("it gives you your TV back"), no ads, no spinner when the TV is asleep or on another input, works in Spanish. The DRM caveat still goes in the listing's first line.

Not done yet: package rename and branding (waiting on the product name), the first-run flow that requests the overlay permission, Play listing, release signing.

## Open questions for Gamalier

- Mirroring stability on this TCL set is settled from both the Mac and the iPhone (see the two test result sections). The iPhone-only checklist items (4 to 7, 10, 11) still need you and the phone; items 4 and 7 are the ones with open upstream bugs.
- The Chromecast with Google TV is also 32-bit; the Google TV Streamer and most 2023+ sets are 64-bit. Test on at least one of each before release.
- Do you want a paid fork, or a sponsored upstream contribution with your own branded build? This changes the Play strategy, not the code.
