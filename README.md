# Clima ☁ - Flutter Weather App

A beautiful and functional weather application built with Flutter that provides real-time weather information based on your current location or any city worldwide.

![Finished App](https://github.com/londonappbrewery/Images/blob/master/clima-demo.gif)

## ✨ Features

- 🌍 **Current Location Weather** - Automatically detects your location and shows weather data
- 🔍 **City Search** - Search for weather information in any city worldwide
- 🌡️ **Temperature Display** - Shows current temperature with weather icons
- 💬 **Smart Messages** - Contextual clothing suggestions based on weather conditions
- 🎨 **Beautiful UI** - Clean design with custom backgrounds and animations
- 🔒 **Secure API Management** - Environment variables for API key security
- 📱 **Cross-Platform** - Works on iOS, Android, and Web

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- OpenWeatherMap API key ([Get one here](https://openweathermap.org/api))
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/csesaidul/clima_flutter_master.git
   cd clima_flutter_master
   ```

2. **Set up environment variables**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   ```

3. **Configure your API key**
   
   Open the `.env` file and add your OpenWeatherMap API key:
   ```env
   OPENWEATHER_API_KEY=your_api_key_here
   OPENWEATHER_BASE_URL=https://api.openweathermap.org/data/2.5/weather
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Key Setup

### Getting Your OpenWeatherMap API Key

1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Navigate to API Keys section
4. Generate a new API key
5. Copy the key to your `.env` file

### Environment Variables

This project uses `flutter_dotenv` for secure API key management:

- **`.env`** - Your actual API keys (never commit this file)
- **`.env.example`** - Template file for other developers
- **`.gitignore`** - Ensures `.env` files are not committed to version control

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point with environment setup
├── screens/
│   ├── loading_screen.dart   # Initial loading screen with location request
│   ├── location_screen.dart  # Main weather display screen
│   └── city_screen.dart      # City search input screen
├── services/
│   ├── weather.dart          # Weather API integration
│   ├── location.dart         # GPS location services
│   └── networking.dart       # HTTP networking helper
└── utilities/
    └── constants.dart        # UI constants and styling
```

## 🛠️ Technologies Used

- **Flutter** - UI framework
- **Dart** - Programming language
- **OpenWeatherMap API** - Weather data source
- **Geolocator** - Location services
- **HTTP** - API networking
- **Flutter Dotenv** - Environment variable management
- **Flutter SpinKit** - Loading animations

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  geolocator: ^14.0.2
  http: ^1.4.0
  flutter_spinkit: ^5.2.1
  flutter_dotenv: ^5.1.0
```

## 🔧 Configuration

### Location Permissions

The app requires location permissions to fetch weather data for your current location:

- **iOS**: Location permission is requested automatically
- **Android**: Location permission is requested at runtime

### API Rate Limits

OpenWeatherMap free tier provides:
- 1,000 API calls per day
- 60 calls per minute

## 🎨 UI Components

### Weather Icons
- 🌩 Thunderstorm
- 🌧 Drizzle
- ☔️ Rain
- ☃️ Snow
- 🌫 Mist/Fog
- ☀️ Clear Sky
- ☁️ Clouds

### Smart Messages
Temperature-based clothing suggestions:
- Above 25°C: "It's 🍦 time"
- 20-25°C: "Time for shorts and 👕"
- Below 10°C: "You'll need 🧣 and 🧤"
- 10-20°C: "Bring a 🧥 just in case"

## 🚨 Troubleshooting

### Common Issues

1. **API Key Not Working**
   - Verify your API key is correct in `.env` file
   - Ensure your OpenWeatherMap account is activated
   - Check if you've exceeded API rate limits

2. **Location Permission Denied**
   - Enable location services in device settings
   - Grant location permission to the app
   - Try searching for a city manually

3. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart SDK versions
   - Verify all dependencies are properly installed

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Copy `.env.example` to `.env` and add your API key
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎓 Learning Objectives

This project demonstrates:

- **Asynchronous Programming** - Using async/await and Futures
- **HTTP Networking** - Making API calls and handling responses
- **JSON Parsing** - Converting API responses to Dart objects
- **State Management** - Managing app state with StatefulWidget
- **Navigation** - Passing data between screens
- **Location Services** - Getting device GPS coordinates
- **Error Handling** - Proper exception handling with try/catch
- **Security** - Secure API key management
- **UI/UX Design** - Creating beautiful and functional interfaces

## 🔗 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [OpenWeatherMap API Docs](https://openweathermap.org/api)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [HTTP Package](https://pub.dev/packages/http)
- [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv)

## 📞 Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/your-username/clima_flutter_master/issues) section
2. Create a new issue with detailed information
3. Include error logs and steps to reproduce

---
**Made with ❤️ and Flutter**
