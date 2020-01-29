import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:app_settings/app_settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String,String>photoArr={
    "haze":"assets/mist.jpg",
    "clear sky":"assets/clear_sky_night.jpg",
    "few clouds":"assets/cloud_night.jpg"
  };
  Position _currentPosition;
  dynamic temp;
  dynamic description;
  dynamic icon;
  dynamic city = '...';
  dynamic countryCode = '';
  bool isCelsius = true;
  @override
  Widget build(BuildContext context) {
    
    const Shadow myShadow =
        Shadow(color: Colors.black, blurRadius: 7, offset: Offset(-3, 3));
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(photoArr[description.toString().toLowerCase()]!=null?photoArr[description.toString().toLowerCase()]:'assets/background.jpg'),
                  fit: BoxFit.cover)),
          child: AnimatedOpacity(
            opacity: temp != null ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Column(
              children: <Widget>[
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.network('http://openweathermap.org/img/wn/$icon@2x.png')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "$city",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              shadows: [myShadow]),
                        ),
                        Text(
                          " " + countryCode,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              shadows: [myShadow]),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          temp == null ? "" : "$temp",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 70,
                              shadows: [myShadow]),
                        ),
                        Text(
                          "°",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              shadows: [myShadow]),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "$description"+"  ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              shadows: [myShadow]),
                        ),
                      ],
                    ),
                  ],
                )),
                Container(
                  height: 100,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "F",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            shadows: [myShadow]),
                      ),
                      Switch(
                        value: isCelsius,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.green,
                        onChanged: toggleType,
                      ),
                      Text(
                        "C",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            shadows: [myShadow]),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      child:Text('Fetching Weather Data From Openweathermap.com',style: TextStyle(color: Colors.white,fontSize: 10,shadows: [myShadow]),)
,)
                ],)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          onPressed: () {
            _getCurrentLocation();
          },
          child: Icon(Icons.rotate_left),
          backgroundColor: Colors.white12,
        ),
      ),
    );
  }

  void toggleType(bool b) {
    setState(() {
      isCelsius = !isCelsius;
      _getCurrentLocation();
    });
  }

  void requestPersmission() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    print("peeeeeeeer : " + geolocationStatus.value.toString());
  }

  _getCurrentLocation() {
    setState(() {
      city = '...';
      countryCode = '';
      temp = null;
    });
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      print(position.latitude);
      print(position.longitude);
      _currentPosition = position;
      getWeather();
    }).catchError((e) {
      print(e);
    });
  }

  void getWeather() async {
    const String MY_KEY = "34bd0b7714c55cb9f7a0d9b52a56ffc8";
    var url = 'http://api.openweathermap.org/data/2.5/weather?' +
        (isCelsius ? 'units=metric' : '') +
        '&lat=${_currentPosition.longitude}&lon=${_currentPosition.latitude}&APPID=$MY_KEY';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var main = jsonResponse['main'];
      setState(() {
        description = ((jsonResponse['weather'])[0])['description'];
        icon = ((jsonResponse['weather'])[0])['icon'];
        countryCode = (jsonResponse['sys'])['country'];
        city = jsonResponse['name'].toString();
        temp = int.tryParse((main['temp']).toString());
        if (temp == null) {
          temp = main['temp'];
        }
        if (temp.toString().indexOf(".") > -1)
          temp = temp.toString().substring(0, temp.toString().indexOf('.'));
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  // void showPermissionDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Location Permission"),
  //           content: Text("Go To Settings to Turn On Location Service?"),
  //           actions: <Widget>[
  //             GestureDetector(
  //               child: Container(
  //                 padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
  //                 child: Text(
  //                   "Cancel",
  //                   style: TextStyle(fontSize: 16),
  //                 ),
  //               ),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             GestureDetector(
  //               child: Container(
  //                 padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
  //                 child: Text(
  //                   "Ok",
  //                   style: TextStyle(fontSize: 16, color: Colors.lightBlue),
  //                 ),
  //               ),
  //               onTap: () {
  //                 AppSettings.openLocationSettings();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }
}
