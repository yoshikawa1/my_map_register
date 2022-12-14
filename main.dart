import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late LatLng _initialPosition;
  late bool _loading;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  TextEditingController name = TextEditingController(text: "");
  TextEditingController installationPlace = TextEditingController(text: "");
  TextEditingController monday = TextEditingController(text: "");
  TextEditingController tuesday = TextEditingController(text: "");
  TextEditingController wednesday = TextEditingController(text: "");
  TextEditingController thursday = TextEditingController(text: "");
  TextEditingController friday = TextEditingController(text: "");
  TextEditingController saturday = TextEditingController(text: "");
  TextEditingController sunday = TextEditingController(text: "");
  TextEditingController address = TextEditingController(text: "");
  TextEditingController tel = TextEditingController(text: "");
  TextEditingController note = TextEditingController(text: "");
  TextEditingController quote = TextEditingController(text: "");
  String documentId = "";
  String updateTime = "";
  String updateId = "";
  static const double textSmall = 8;
  static const double textMedium = 12;
  static const double textLarge = 18;
  String result = "";

  @override
  void initState() {
    super.initState();
    _loading = true;
    _getUserLocation();
    _createMarkers(markerTapped);
  }

  void _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    var position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MapContainer(),
      ],
    );
  }

  MapContainer() {
    return Expanded(
      child: SizedBox(
        width: 1000,
        height: 1500,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: MapDrawer(),
          body: _loading
              ? const CircularProgressIndicator()
              : SafeArea(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: _initialPosition, zoom: 15),
                        markers: _markers,
                        onLongPress: (LatLng latLng) {
                          setState(() {
                            createNewMarker(markerTapped, latLng);
                          });
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapToolbarEnabled: false,
                        buildingsEnabled: true,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  MapDrawer() {
    return Column(
      children: [
        Expanded(
          child: Drawer(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                        controller: name,
                        maxLines: null,
                        decoration: const InputDecoration(labelText: "??????")),
                    TextField(
                      controller: installationPlace,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "????????????"),
                    ),
                    TextFormField(
                      controller: monday,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "?????????"),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9:???,]')),
                      ],
                    ),
                    TextFormField(
                      controller: tuesday,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "?????????"),
                    ),
                    TextField(
                      controller: wednesday,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "?????????"),
                    ),
                    TextField(
                      controller: thursday,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "?????????"),
                    ),
                    TextField(
                      controller: friday,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "?????????"),
                    ),
                    TextField(
                      controller: saturday,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "?????????"),
                    ),
                    TextField(
                      controller: sunday,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "?????????"),
                    ),
                    TextField(
                      controller: address,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "??????"),
                    ),
                    TextField(
                      controller: tel,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "????????????"),
                    ),
                    TextField(
                      controller: note,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "??????"),
                    ),
                    TextField(
                      controller: quote,
                      maxLines: null,
                      decoration: const InputDecoration(labelText: "??????"),
                    ),
                    const SizedBox(height: 10),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        child: const Text("ID", textAlign: TextAlign.left)),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      child: Text(documentId, textAlign: TextAlign.left),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      child: const Text("????????????", textAlign: TextAlign.left),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      child: Text(updateTime, textAlign: TextAlign.left),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      child: const Text("?????????", textAlign: TextAlign.left),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      child: Text(updateId, textAlign: TextAlign.left),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () async {
                            var androidInfo =
                                await DeviceInfoPlugin().androidInfo;
                            FirebaseFirestore.instance
                                .collection("maps")
                                .doc(documentId)
                                .update({
                              'name': name.text,
                              'place': installationPlace.text,
                              'monday': monday.text,
                              'tuesday': tuesday.text,
                              'wednesday': wednesday.text,
                              'thursday': thursday.text,
                              'friday': friday.text,
                              'saturday': saturday.text,
                              'sunday': sunday.text,
                              'address': address.text,
                              'tel': tel.text,
                              'note': note.text,
                              'quote': quote.text,
                              'updateTime': DateTime.now(),
                              'updateId':
                                  '${androidInfo.model}\r\n${androidInfo.id}',
                            });
                            setState(() {
                              result = "??????????????????";
                            });
                          },
                          child: const Text("??????"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            _showDialog(documentId);
                          },
                          child: const Text("??????"),
                        ),
                      ],
                    ),
                    Text(result, style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }

  markerTapped(String documentIdL) async {
    if (documentIdL != "") {
      final doc = await FirebaseFirestore.instance
          .collection('maps')
          .doc(documentIdL)
          .get();

      setState(() {
        name = TextEditingController(text: doc.get('name'));
        installationPlace = TextEditingController(text: doc.get('place'));
        monday = TextEditingController(text: doc.get('monday'));
        tuesday = TextEditingController(text: doc.get('tuesday'));
        wednesday = TextEditingController(text: doc.get('wednesday'));
        thursday = TextEditingController(text: doc.get('thursday'));
        friday = TextEditingController(text: doc.get('friday'));
        saturday = TextEditingController(text: doc.get('saturday'));
        sunday = TextEditingController(text: doc.get('sunday'));
        address = TextEditingController(text: doc.get('address'));
        tel = TextEditingController(text: doc.get('tel'));
        note = TextEditingController(text: doc.get('note'));
        quote = TextEditingController(text: doc.get('quote'));
        documentId = documentIdL;
        try {
          updateTime = DateFormat('yyyy???M???d??? kk:mm:ss')
              .format(doc.get('updateTime').toDate());
        } catch (e) {
          updateTime = "";
        }
        try {
          updateId = doc.get('updateId');
        } catch (e) {
          updateId = "";
        }
        result = "";
      });
    } else {
      setState(() {
        name = TextEditingController(text: "");
        installationPlace = TextEditingController(text: "");
        monday = TextEditingController(text: "");
        tuesday = TextEditingController(text: "");
        wednesday = TextEditingController(text: "");
        thursday = TextEditingController(text: "");
        friday = TextEditingController(text: "");
        saturday = TextEditingController(text: "");
        sunday = TextEditingController(text: "");
        address = TextEditingController(text: "");
        tel = TextEditingController(text: "");
        note = TextEditingController(text: "");
        quote = TextEditingController(text: "");
        documentId = "";
        updateTime = "";
        updateId = "";
        result = "";
      });
    }
    _scaffoldKey.currentState?.openDrawer();
  }

  void _createMarkers(void Function(String) callback) async {
    final storesStream =
        await FirebaseFirestore.instance.collection('maps').get();
    Set<Marker> lMarkers = {};
    for (var document in storesStream.docs) {
      var now = DateTime.now();
      String businessHours = "";
      double markerColor;

      switch (now.weekday) {
        case 1:
          businessHours = document['monday'];
          break;
        case 2:
          businessHours = document['tuesday'];
          break;
        case 3:
          businessHours = document['wednesday'];
          break;
        case 4:
          businessHours = document['thursday'];
          break;
        case 5:
          businessHours = document['friday'];
          break;
        case 6:
          businessHours = document['saturday'];
          break;
        case 7:
          businessHours = document['sunday'];
          break;
        default:
      }

      //??????????????????
      if (businessHours == "-") {
        markerColor = BitmapDescriptor.hueAzure;
      } else if (businessHours == "") {
        markerColor = BitmapDescriptor.hueGreen;
      } else {
        var businessHourSplit = businessHours.split(",");
        markerColor = BitmapDescriptor.hueAzure;
        for (var businessHour in businessHourSplit) {
          var splitTime = businessHour.split("???");
          String openHour = splitTime[0].split(":")[0];
          String openMinute = splitTime[0].split(":")[1];
          String closeHour = splitTime[1].split(":")[0];
          String closeMinute = splitTime[1].split(":")[1];
          DateTime openTime = DateTime(now.year, now.month, now.day,
              int.parse(openHour), int.parse(openMinute));
          DateTime closeTime = DateTime(now.year, now.month, now.day,
              int.parse(closeHour), int.parse(closeMinute));

          if (openTime.isBefore(now) & now.isBefore(closeTime)) {
            markerColor = BitmapDescriptor.hueRed;
            break;
          }
        }
      }

      lMarkers.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
        markerId: MarkerId(document.id),
        position: LatLng(document['lat'], document['lng']),
        onTap: () => callback(document.id),
      ));
    }

    setState(() {
      _markers = lMarkers;
    });
  }

  void createNewMarker(void Function(String) callback, latLng) async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    await FirebaseFirestore.instance.collection('maps').add({
      'lat': latLng.latitude,
      'lng': latLng.longitude,
      'name': "",
      'place': "",
      'monday': "",
      'tuesday': "",
      'wednesday': "",
      'thursday': "",
      'friday': "",
      'saturday': "",
      'sunday': "",
      'address': "",
      'tel': "",
      'note': "",
      'quote': "",
      'updateTime': DateTime.now(),
      'updateId': '${androidInfo.model}\r\n${androidInfo.id}',
    }).then((value) {
      setState(() {
        _markers.add(Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          markerId: MarkerId(value.id),
          position: latLng,
          onTap: () => callback(value.id),
        ));
      });
      result = "??????????????????????????????????????????\r\n??????????????????????????????????????????????????????????????????";
    });
  }

  Future _showDialog(documentId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('???????????????????????????????????????'),
        content: const Text('?????????????????????????????????????????????'),
        actions: <Widget>[
          SimpleDialogOption(
            child: const Text('Yes'),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("maps")
                  .doc(documentId)
                  .delete();
              setState(() {
                result = "??????????????????";
                _markers.remove(_markers.firstWhere(
                    (Marker marker) => marker.markerId.value == documentId));
              });
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: const Text('NO'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
// ????????????????????????????????????????????????????????????validate?????????