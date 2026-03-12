# M3U/IPTV Player

A modern, ultra-performant, and responsive IPTV player written in Flutter. Optimized to parse and handle massive M3U playlists (80,000+ items) without stuttering, offering a premium style User Experience (UX).

> 🚧 Warning
>
> This is a personal project and is not intended for production use. It is still under development and may contain bugs.

![Movie View](/assets/images/movie_view.png)

## Key Features
- **High Performance Parsing**: Custom reading engine that utilizes Dart's Stream and Isolate (compute) to parse tens of thousands of M3U lines in the background, keeping the UI running at a buttery smooth 60/120fps.
- **Smart Categorization**: Automatically recognizes and separates content into three main categories:
  - Live Channels
  - Movies
  - TV Series
- **Load Efficiency**: The data are loaded efficiently thanks to pagination and lazy loading.
- **Reactive Search**: You can easily filter the catalog by searching the title.
- **IMDb/TMDB Integration**: Enriches raw M3U content by fetching posters, plots, casts, directors and rating from IMDb and TMDB.

![Series Details View](/assets/images/series_details.png)

## Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (Dart 3)
- **State Management:** [Riverpod](https://riverpod.dev/)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router)
- **UI Design System:** [Shadcn UI for Flutter](https://shadcn-ui.dev/)
- **Loading Animations:** [Skeletonizer](https://pub.dev/packages/skeletonizer)
- **Video Player:** [Video Player](https://pub.dev/packages/video_player)
- **Image Caching:** [CachedNetworkImage](https://pub.dev/packages/cached_network_image)

This project is a starting point for a Flutter application.

---
## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- A valid `.m3u` file or playlist link to test the app.

### Installation
1. Clone the repository
2. Navigate to the project directory
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

A few resources to get you started if this is your first Flutter project:

## Roadmap
- [x] Optimized M3U Parser
- [x] Series TV Aggregator
- [x] IMDb/TMDB Integration
- [x] Search Functionality
- [x] Responsive Design
- [x] Video Player integration
- [ ] Select Resolution Quality
- [ ] Favorites / Continue watching management
- [ ] EPG (Electronic Program Guide) support
- [ ] Theming
- [ ] Picture in Picture
- [ ] AirPlay
- [ ] More...

---
Built with ❤️ using Flutter and Riverpod.