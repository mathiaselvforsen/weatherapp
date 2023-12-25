import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ForecastPage extends StatefulWidget {
  final List<BottomNavigationBarItem> navBarItems;
  final int selectedIndex;
  final String? latitude;
  final String? longitude;

  const ForecastPage({
    super.key,
    required this.navBarItems,
    required this.selectedIndex,
    this.latitude,
    this.longitude,
  });

  @override
  ForecastPageState createState() => ForecastPageState();
}
//list for images 
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

//fetch weather from users lat and long
Future<List<Map<String, dynamic>>> fetchWeatherForecast(
  double latitude,
  double longitude,
) async {
  const apiKey = 'b7586c9d8c62a8bc0ace1e03551a63a9'; // Apikey
  final url =
      'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final forecastList = data['list'] as List<dynamic>;
    final cityName = data['city']['name'];

    // Show the temperature for the middle of the day
    final filteredData = forecastList.where((forecastItem) {
      final forecastDateTime = DateTime.fromMillisecondsSinceEpoch(
        forecastItem['dt'] * 1000,
        isUtc: true,
      );
      final hour = forecastDateTime.hour;
      final minute = forecastDateTime.minute;

      return hour == 12 && minute == 0;
    }).toList();

    // weatherdescription and date fetcher
    final forecastData = filteredData.map((forecastItem) {
      final temperature = forecastItem['main']['temp'].toInt();
      final weatherDescription = forecastItem['weather'][0]['description'];
      var iconCode = forecastItem['weather'][0]['icon'];
      final time = DateTime.fromMillisecondsSinceEpoch(
        forecastItem['dt'] * 1000,
        isUtc: true,
      );
      final weekday = DateFormat.EEEE().format(time);
      final formattedDateTime = DateFormat('MMM dd, yyyy - HH:mm').format(time);

      return {
        'temperature': temperature,
        'description': weatherDescription,
        'dateTime': formattedDateTime,
        'iconCode': iconCode,
        'weekday': weekday,
        'forecastDateTime': time,
        'cityName': cityName,
      };
    }).toList();

    return forecastData;
  } else {
    throw Exception('Failed to fetch weather forecast');
  }
}

class ForecastPageState extends State<ForecastPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> forecastData = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    fetchForecastData();
  }

// Make sure lat and long is fetched
  void fetchForecastData() async {
    try {
      final String? latitude = widget.latitude;
      final String? longitude = widget.longitude;
      if (latitude != null) {
        final forecast = await fetchWeatherForecast(
          double.parse(latitude),
          double.parse(longitude!),
        );

        setState(() {
          forecastData = forecast;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navBar = widget.navBarItems;
    final cityName =
        forecastData.isNotEmpty ? forecastData.first['cityName'] ?? '' : '';

    return Scaffold(
      backgroundColor: Colors.red,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'The weather forecast for the next days at 12:00 in :',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$cityName',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: forecastData.length,
                itemBuilder: (context, index) {
                  final temperature = forecastData[index]['temperature'];
                  final description = forecastData[index]['description'];
                  final dateTime = forecastData[index]['dateTime'];
                  final weekday = forecastData[index]['weekday'];
                  final iconCode = forecastData[index]['iconCode'];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Image.asset(
                        weatherImages[iconCode]?? '',
                        width: 75,
                        height: 200,
                      ),
                      title: Text(' $temperature°C',style:  GoogleFonts.fredoka(fontSize: 18,  fontWeight: FontWeight.w600),),
                      subtitle: Text('$description',style:  GoogleFonts.fredoka(fontSize: 14, color: Colors.black,  fontWeight: FontWeight.w600),),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                        
                          Text('$dateTime',style:  GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600),),
                         
                          Text('$weekday',style:  GoogleFonts.fredoka(fontSize: 14,  fontWeight: FontWeight.w600),),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          items: widget.navBarItems,
          currentIndex: _selectedIndex,
          onTap: (index) {
            _updateSelectedIndex(index);

            if (index == 0) {
              // Home icon pressed, navigate back to YourWeatherPage
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AboutPage(
                    navBarItems: navBar,
                    selectedIndex: _selectedIndex,
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                  ),
                ),
              ).then((value) {
                // Update the navbar color to HOME active
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
