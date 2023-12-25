import 'package:flutter/material.dart';
import 'forecast.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatefulWidget {
  final List<BottomNavigationBarItem> navBarItems;
  final int selectedIndex;
  final String? latitude;
  final String? longitude;

  const AboutPage({
    super.key,
    required this.navBarItems,
    required this.selectedIndex,
    this.latitude,
    this.longitude,
  });

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navBar = widget.navBarItems;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'About:',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                width: 300,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'This weather app is created for the Flutter Course 1DV535 @Linneaus University. The purpose of the app is to show the weather at your current position and give the user an option to see the weather forecast 4 days ahead. When showing the weather at your current position, you also have the opportunity to see the weather 24 hours ahead.',
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Created by:',
                style: GoogleFonts.fredoka(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              Text(
                'Mathias Elv Forsén',
                style: GoogleFonts.fredoka(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('images/me.JPG'),
                backgroundColor: Colors.yellow,
              ),
              const SizedBox(height: 20),
              Text(
                'Contact @ : me224qh@student.lnu.se',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
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
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForecastPage(
                    navBarItems: navBar,
                    selectedIndex: _selectedIndex,
                    latitude: widget.latitude,
                    longitude: widget.longitude,
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
