import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_weather_app_v2/components/weather_item.dart';
import 'package:flutter_weather_app_v2/constants.dart';
import 'package:flutter_weather_app_v2/ui/detail_page.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();

  static String API_KEY = ''; //Paste Your API Here

  String location = 'London'; //Default location
  String weatherIcon = 'heavycloud.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  //API Call
  String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=" +
      API_KEY +
      "&days=7&q=";

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult =
          await http.get(Uri.parse(searchWeatherAPI + searchText));

      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');

      var locationData = weatherData["location"];

      var currentWeather = weatherData["current"];

      setState(() {
        location = getShortLocationName(locationData["name"]);

        var parsedDate =
            DateTime.parse(locationData["localtime"].substring(0, 10));
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        currentDate = newDate;

        //updateWeather
        currentWeatherStatus = currentWeather["condition"]["text"];
        weatherIcon =
            currentWeatherStatus.replaceAll(' ', '').toLowerCase() + ".png";
        temperature = currentWeather["temp_c"].toInt();
        windSpeed = currentWeather["wind_kph"].toInt();
        humidity = currentWeather["humidity"].toInt();
        cloud = currentWeather["cloud"].toInt();

        //Forecast data
        dailyWeatherForecast = weatherData["forecast"]["forecastday"];
        hourlyWeatherForecast = dailyWeatherForecast[0]["hour"];
        print(dailyWeatherForecast);
      });
    } catch (e) {
      //debugPrint(e);
    }
  }

  //function to return the first two names of the string location
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  void initState() {
    fetchWeatherData(location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 70, left: 10, right: 10),
        color: _constants.primaryColor.withOpacity(.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: size.height * .7,
              decoration: BoxDecoration(
                gradient: _constants.linearGradientBlue,
                boxShadow: [
                  BoxShadow(
                    color: _constants.primaryColor.withOpacity(.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/menu.png",
                        width: 40,
                        height: 40,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/pin.png",
                            width: 20,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _cityController.clear();
                              showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => SingleChildScrollView(
                                        controller:
                                            ModalScrollController.of(context),
                                        child: Container(
                                          height: size.height * .2,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: 70,
                                                child: Divider(
                                                  thickness: 3.5,
                                                  color:
                                                      _constants.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextField(
                                                onChanged: (searchText) {
                                                  fetchWeatherData(searchText);
                                                },
                                                controller: _cityController,
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.search,
                                                      color: _constants
                                                          .primaryColor,
                                                    ),
                                                    suffixIcon: GestureDetector(
                                                      onTap: () =>
                                                          _cityController
                                                              .clear(),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: _constants
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    hintText:
                                                        'Search city e.g. London',
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: _constants
                                                            .primaryColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                            },
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/profile.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: Image.asset("assets/" + weatherIcon),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          temperature.toString(),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = _constants.shader,
                          ),
                        ),
                      ),
                      Text(
                        'o',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = _constants.shader,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currentWeatherStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    currentDate,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Divider(
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WeatherItem(
                          value: windSpeed.toInt(),
                          unit: 'km/h',
                          imageUrl: 'assets/windspeed.png',
                        ),
                        WeatherItem(
                          value: humidity.toInt(),
                          unit: '%',
                          imageUrl: 'assets/humidity.png',
                        ),
                        WeatherItem(
                          value: cloud.toInt(),
                          unit: '%',
                          imageUrl: 'assets/cloud.png',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              height: size.height * .20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_)=> DetailPage(dailyForecastWeather: dailyWeatherForecast,))), //this will open forecast screen
                        child: Text(
                          'Forecasts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: _constants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      itemCount: hourlyWeatherForecast.length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        String currentTime =
                            DateFormat('HH:mm:ss').format(DateTime.now());
                        String currentHour = currentTime.substring(0, 2);

                        String forecastTime = hourlyWeatherForecast[index]
                                ["time"]
                            .substring(11, 16);
                        String forecastHour = hourlyWeatherForecast[index]
                                ["time"]
                            .substring(11, 13);

                        String forecastWeatherName =
                            hourlyWeatherForecast[index]["condition"]["text"];
                        String forecastWeatherIcon = forecastWeatherName
                                .replaceAll(' ', '')
                                .toLowerCase() +
                            ".png";

                        String forecastTemperature =
                            hourlyWeatherForecast[index]["temp_c"]
                                .round()
                                .toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin: const EdgeInsets.only(right: 20),
                          width: 65,
                          decoration: BoxDecoration(
                              color: currentHour == forecastHour
                                  ? Colors.white
                                  : _constants.primaryColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 5,
                                  color:
                                      _constants.primaryColor.withOpacity(.2),
                                ),
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                forecastTime,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: _constants.greyColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Image.asset(
                                'assets/' + forecastWeatherIcon,
                                width: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    forecastTemperature,
                                    style: TextStyle(
                                      color: _constants.greyColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'o',
                                    style: TextStyle(
                                      color: _constants.greyColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                      fontFeatures: const [
                                        FontFeature.enable('sups'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
