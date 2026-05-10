# TODO - pelaporankejadian_app

## Step 1: Setup dependencies & theme toggling
- Update `pubspec.yaml` dengan dependensi:
  - image_picker, geolocator, flutter_map, latlong2
  - flutter_image_compress
  - share_plus
  - (opsional) cupertino_icons
- Replace `lib/main.dart` menjadi app skeleton dengan light/dark mode + routing.

## Step 2: Create app structure
- Create folders:
  - `lib/models`, `lib/state`, `lib/screens` (auth/home/add/detail/map), `lib/widgets`
- Add basic models (User, ReportPost)
- Add `AppState` (in-memory posts/users + current user + themeMode).

## Step 3: Auth (Sign in / Sign up)
- Implement sign up screen
- Implement sign in screen
- After auth -> navigate to Home.

## Step 4: Home + Add Post
- Home screen:
  - show list posts
  - button Add Post
  - theme toggle
- Add Post screen:
  - fields: description/category
  - image picker + compress
  - current location via geolocator
  - map preview + open map
  - save post to AppState.

## Step 5: Map screen (flutter_map)
- Show marker untuk lokasi user / post
- Optional: marker semua post (tergantung implementasi).

## Step 6: Detail screen + Share
- Detail screen menampilkan:
  - image
  - description
  - lat/lng + map preview
  - button Share (share_plus)

## Step 7: Run & test
- `flutter pub get`
- `flutter run`
- Test end-to-end flow: sign up -> sign in -> home -> add post -> map/detail -> share


