# Fluentify App

Flutter app using MVVM architecture with BLoC, EasyLocalization, theming, and reusable components.

## Getting Started

1. Install Flutter and set up your environment.
2. From the project root, run:

```bash
flutter pub get
flutter run
```

## Structure

- `lib/app` — root app widget
- `lib/core/theme` — theme definitions and theme cubit
- `lib/core/resources/assets_manager.dart` — assets paths
- `lib/shared/widgets` — reusable UI components
- `lib/features/home` — Home feature (MVVM with Cubit as ViewModel)
- `assets/translations` — i18n files (EasyLocalization)

## Notes
- Brand color: #04E9C7 applied as primary/secondary/background.
- Toggle theme from the AppBar action on Home.
- Update `assets/images` and `assets/icons` with real files as needed.






https://pub.dev/packages/record


 

// ToD0 :

1 - each status in chat practice (
    initCall - connected - reconnected - failedToConnect -  callEnded
)
2 - cubit states (
    liveStatus - remoteUserModel - localUserModel - duration - isMuted - 
)