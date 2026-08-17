# Professional Google AdMob Integration Plan

This plan outlines the integration of Google AdMob into the **InstaWall** Flutter application, following professional architectural patterns and ensuring compliance with the latest Android requirements.

## User Review Required

> [!IMPORTANT]
> **AdMob App ID Missing**: The provided screenshots contain **Ad Unit IDs**, but the **AdMob App ID** (formatted as `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`) is missing. I will use the official Google Test App ID for the initial implementation. You MUST replace it in `android/app/src/main/AndroidManifest.xml` before publishing.

> [!NOTE]
> **Meta Audience Network**: The project currently uses `easy_audience_network_plus` (Meta). This plan focuses on integrating Google AdMob as the primary ad provider. I will update the existing `AdManager` and `BannerAdWidget` to support AdMob.

## Proposed Changes

### 1. Build Configuration & Dependencies

Update the project to include the AdMob SDK and ensure Android compatibility.

#### [MODIFY] [pubspec.yaml](file:///C:/Users/user/StudioProjects/instaWall/pubspec.yaml)
- Add `google_mobile_ads: ^5.2.0` dependency.

#### [MODIFY] [AndroidManifest.xml](file:///C:/Users/user/StudioProjects/instaWall/android/app/src/main/AndroidManifest.xml)
- Add the `com.google.android.gms.ads.APPLICATION_ID` meta-data tag.
- Ensure `INTERNET` and `ACCESS_NETWORK_STATE` permissions are present (already exist).

---

### 2. AdMob Infrastructure

Create a clean, reusable service layer for AdMob.

#### [NEW] [ad_mob_service.dart](file:///C:/Users/user/StudioProjects/instaWall/lib/ad_mob_service.dart)
- `AdMobService` class: Singleton to manage ad lifecycles.
- Implementation of:
    - **App Open Ad**: Logic for loading and showing on app launch/resume.
    - **Interstitial Ad**: Pre-loading and showing with frequency control.
    - **Rewarded Ad**: Secure reward handling with server-side verification readiness.
    - **Banner Ad**: Factory method for creating banner widgets.
- `AdMobConfig`: Centralized storage for all Ad Unit IDs (mapped from your screenshots).

#### [MODIFY] [ad_manager.dart](file:///C:/Users/user/StudioProjects/instaWall/lib/ad_manager.dart)
- Update to wrap `AdMobService` methods.
- Maintain existing frequency logic but bridge it to AdMob.

#### [MODIFY] [banner_ad_widget.dart](file:///C:/Users/user/StudioProjects/instaWall/lib/banner_ad_widget.dart)
- Refactor to display AdMob Banner ads instead of Meta ads.

---

### 3. Application Integration

Wire up the ads into the UI and lifecycle.

#### [MODIFY] [main.dart](file:///C:/Users/user/StudioProjects/instaWall/lib/main.dart)
- Initialize `MobileAds` in `main()`.
- Wrap `GetMaterialApp` with a lifecycle observer to trigger **App Open Ads** on resume.

#### [MODIFY] [Home_screen.dart](file:///C:/Users/user/StudioProjects/instaWall/lib/Home_screen.dart)
- Ensure navigation points correctly trigger interstitials via `AdManager`.
- Update the "Claim Bonus" button logic to use AdMob Rewarded ads.

#### [MODIFY] [splash_screen.dart](file:///C:/Users/user/StudioProjects/instaWall/lib/splash_screen.dart)
- Logic to wait for (or skip) the initial App Open Ad load to ensure a professional first-start experience.

## Verification Plan

### Automated Checks
- `flutter pub get` to verify dependency resolution.
- `flutter analyze` to ensure no linting errors.

### Manual Verification
- **Cold Start**: Verify App Open Ad appears after splash if ready.
- **App Resume**: Verify App Open Ad appears when returning from background.
- **Navigation**: Verify Interstitial appears every 3 taps (as per existing frequency).
- **Rewarded**: Verify "Claim Bonus" shows a Rewarded Ad and grants the reward only on completion.
- **Banners**: Verify Banners appear at the bottom of the Home Screen with proper spacing.
- **Error Handling**: Disable internet and verify the app remains fully functional without crashing.
