import 'dart:convert';
import 'forecast.dart';
import 'about.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

//Imports end

// Function to run the app
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Your weather',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const YourWeatherPage(),
  ));
}

class YourWeatherPage extends StatefulWidget {
  const YourWeatherPage({super.key});

  @override
  State<YourWeatherPage> createState() => _YourWeatherPageState();
}


class _YourWeatherPageState extends State<YourWeatherPage> {
  String? _locationMessage;
  String? _cityName;
  String? _temp;
  String? _desc;
  String? _feels;
  String? _tempMin;
  String? _tempMax;
  String? _sunrise;
  String? _sunset;
  String? _iconCode;
  List<dynamic>? hourlyWeatherData;
  bool isLoading = true;
  int _selectedIndex = 0;
  String? _latitude;
  String? _longitude;

  final apiKey = 'b7586c9d8c62a8bc0ace1e03551a63a9'; // Apikey


  Map<String, String> weatherImages = {
    '01d': 'images/clear_sky.png',
    '01n': 'images/clear_sky_night.png',
    '02d': 'images/few_clouds.png',
    '02n': 'images/few_clouds_night.png',
    '03d': 'images/scattered_clouds.png',
    '03n': 'images/scattered_clouds_night.png',
    '04d': 'images/broken_clouds.png',
    '04n': 'images/broken_clouds_night.png',
    '09d': 'images/shower_rain.png',
    '09n': 'images/shower_rain_night.png',
    '10d': 'images/rain.png',
    '10n': 'images/rain_night.png',
    '11d': 'images/thunderstorm.png',
    '11n': 'images/thunderstorm_night.png',
    '13d': 'images/snow.png',
    '13n': 'images/snow_night.png',
    '50d': 'images/mist.png',
    '50n': 'images/mist_night.png',
  };

  @override
  void initState() {
    super.initState(); // Make sure everything is loaded before executing
    getCurrentLocation();
  }

//Get user location, lat long
  Future<void> getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _locationMessage = '';
      });

      fetchWeatherData(position.latitude, position.longitude);

      DateTime targetDate = DateTime.now();
      fetchHourlyTemperatureData(
              position.latitude, position.longitude, targetDate)
          .then((hourlyData) {
        setState(() {
          hourlyWeatherData = hourlyData;
        });
      });
    } else if (permissionStatus.isPermanentlyDenied) {
      showLocationPermissionDialog();
    } else {
      setState(() {
        _locationMessage = 'Please provide location permission';
      });
    }
  }

// Fetch weatherdata from openweatherAPI
  Future<void> fetchWeatherData(double latitude, double longitude) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final weatherData = json.decode(response.body);
      final temperature = weatherData['main']['temp'].toInt();
      final weatherDescription = weatherData['weather'][0]['description'];
      final cityName = weatherData['name'];
      final feels = weatherData['main']['feels_like'].toInt();
      final sunriseTime = weatherData['sys']['sunrise'];
      final sunsetTime = weatherData['sys']['sunset'];
      final iconCode = weatherData['weather'][0]['icon'];
      final sunrise = DateTime.fromMillisecondsSinceEpoch(sunriseTime * 1000);
      final sunset = DateTime.fromMillisecondsSinceEpoch(sunsetTime * 1000);
      final sunriseTimeset = DateFormat('HH:mm').format(sunrise);
      final sunsetTimeset = DateFormat('HH:mm').format(sunset);

      // Save the data in strings
      setState(() {
        _desc = weatherDescription;
        _temp = temperature.toString();
        _cityName = cityName;
        _feels = feels.toString();
        _sunrise = sunriseTimeset.toString();
        _sunset = sunsetTimeset.toString();
        _iconCode = iconCode;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

//Box that ask about location.
  Future<void> showLocationPermissionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content:
              const Text('Please enable location permission in app settings.'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

//List to fetch Hourly tempdata
  Future<List<dynamic>> fetchHourlyTemperatureData(
      double latitude, double longitude, DateTime targetDate) async {
    String hourUrl = 'https://api.openweathermap.org/data/2.5/forecast';
    DateTime now = DateTime.now();
    DateTime optionalEndTime = now.add(const Duration(hours: 24));

    String requestUrl =
        '$hourUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

    http.Response response = await http.get(Uri.parse(requestUrl));
    if (response.statusCode == 200) {
      // Parse the response JSON data
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> hourlyData = responseData['list'];
      List<dynamic> hourlyTemperatureData = hourlyData.where((data) {
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000);
        return dateTime.isAfter(now) &&
            dateTime.isBefore(optionalEndTime); // 24h from now
      }).toList();
      //Seting data to highest and lowest temp from the list
      double dayLow = double.infinity;
      double dayHigh = double.negativeInfinity;

      //Looping and saving the lowest/highest temp
      for (var data in hourlyTemperatureData) {
        var temperature = data['main']['temp'].toDouble();
        if (temperature < dayLow) {
          dayLow = temperature;
        }
        if (temperature > dayHigh) {
          dayHigh = temperature;
        }
      }
      //saving it to a fixed string, No decimals
      setState(() {
        _tempMin = dayLow.toStringAsFixed(0);
        _tempMax = dayHigh.toStringAsFixed(0);
      });

      return hourlyTemperatureData;
    } else {
      throw Exception('Failed to fetch hourly temperature data');
    }
  }

  //bottom nav bar with icons for each site
  final List<BottomNavigationBarItem> _navBar = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month), label: 'Forecast'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.question_mark), label: 'About'),
  ];

//Builds app
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.indigo,
            Colors.lightBlueAccent,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: isLoading //Meanwhile loading show circular progressindicatior
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              weatherImages[_iconCode] ?? '',
                              width: 200,
                              height: 200,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                ' ${_desc ?? ''}', // Show description
                                style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(1.0),
                        ),
                        _temp != null //If temp not null , execute
                            ? Column(
                                children: [
                                  //column with temp
                                  Text(
                                    '$_tempº',
                                    style: GoogleFonts.fredoka(
                                        fontSize: 100,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    'Feels like: ${_feels ?? ''}°',
                                    style: GoogleFonts.fredoka(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : const Text(
                                '',
                                style: TextStyle(fontSize: 100),
                              ),
                      ],
                    ),
                    Text(
                      _locationMessage ?? 'Fetching location...',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _cityName ?? '',
                      style: GoogleFonts.fredoka(
                          fontSize: 60,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      // Container with cards to display hourlyweather
                      width: 400,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // weather info about the day
                                const Icon(
                                  Icons.thermostat,
                                  color: Colors.blue,
                                ),
                                Text(
                                  ' ${_tempMin ?? ''}°',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.thermostat,
                                  color: Colors.red,
                                ),
                                Text(
                                  ' ${_tempMax ?? ''}°',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 30),
                                const Icon(Icons.sunny),
                                Text(
                                  ' ${_sunrise ?? ''}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 5),
                                const Icon(Icons.dark_mode),
                                Text(
                                  ' ${_sunset ?? ''}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: hourlyWeatherData != null
                                ? SizedBox(
                                    width: double.infinity,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(
                                            //List to generate info about the hourly data
                                            hourlyWeatherData!.length, (index) {
                                          var data = hourlyWeatherData![index];
                                          var time = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  data['dt'] * 1000);
                                          var temperature =
                                              data['main']['temp'].toInt();
                                          var iconCode =
                                              data['weather'][0]['icon'];
                                          return Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .access_time_outlined,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        ' ${DateFormat('HH').format(time)}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                        Image.asset(
                                                   weatherImages[iconCode] ?? '',
                                                          width: 50,
                                                          height: 50,
                                                        ),
                                                  Text(
                                                    ' $temperature°C',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator()),
                          ),
                        ],
                      ),
                    ),
                  ], 
                ),
              ),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          items: _navBar,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ForecastPage(
                    navBarItems: _navBar,
                    selectedIndex: _selectedIndex,
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                ),
              ).then((value) {
                //update the navbar color to HOME active
                setState(() {
                  _selectedIndex = 0; // Set the index of the main screen
                });
              });
            }

            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AboutPage(
                    navBarItems: _navBar,
                    selectedIndex: _selectedIndex,
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                ),
              ).then((value) {
                //update the navbar color to HOME active

                setState(() {
                  _selectedIndex = 0; // Set the index of the main screen
                });
              });
            }
          },
        ),
      ),
    );
  }
}
