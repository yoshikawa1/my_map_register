import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';

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
  TextEditingController documentId = TextEditingController(text: "");
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
  static const double textSmall = 8;
  static const double textMedium = 12;
  static const double textLarge = 18;

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
        child: Container(
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
                            initialCameraPosition: CameraPosition(
                              target: _initialPosition,
                              zoom: 15,
                            ),
                            markers: _markers,
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
            )));
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
                    Visibility(
                      visible: false,
                      child: TextField(
                        controller: documentId,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: "ID",
                        ),
                      ),
                    ),
                    TextField(
                      controller: name,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "名称",
                      ),
                    ),
                    TextField(
                      controller: installationPlace,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "設置場所",
                      ),
                    ),
                    TextField(
                      controller: monday,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "月曜日",
                      ),
                    ),
                    TextField(
                      controller: tuesday,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "火曜日",
                      ),
                    ),
                    TextField(
                      controller: wednesday,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "水曜日",
                      ),
                    ),
                    TextField(
                      controller: thursday,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "木曜日",
                      ),
                    ),
                    TextField(
                      controller: friday,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "金曜日",
                      ),
                    ),
                    TextField(
                      controller: saturday,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "土曜日",
                      ),
                    ),
                    TextField(
                      controller: sunday,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "日曜日",
                      ),
                    ),
                    TextField(
                      controller: address,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "住所",
                      ),
                    ),
                    TextField(
                      controller: tel,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "電話番号",
                      ),
                    ),
                    TextField(
                      controller: note,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "備考",
                      ),
                    ),
                    TextField(
                      controller: quote,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "引用",
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print(documentId.text);
                        FirebaseFirestore.instance
                            .collection("maps")
                            .doc(documentId.text)
                            .update({'name': 'aa', 'place': 'bb'});
                      },
                      child: const Text(
                        "更新",
                      ),
                    ),
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

  markerTapped(Place place) {
    setState(() {
      documentId = TextEditingController(text: place.documentId);
      name = TextEditingController(text: place.name);
      installationPlace = TextEditingController(text: place.installationPlace);
      monday = TextEditingController(text: place.monday);
      tuesday = TextEditingController(text: place.tuesday);
      wednesday = TextEditingController(text: place.wednesday);
      thursday = TextEditingController(text: place.thursday);
      friday = TextEditingController(text: place.friday);
      saturday = TextEditingController(text: place.saturday);
      sunday = TextEditingController(text: place.sunday);
      address = TextEditingController(text: place.address);
      tel = TextEditingController(text: place.tel);
      note = TextEditingController(text: place.note);
      quote = TextEditingController(text: place.quote);
    });
    _scaffoldKey.currentState?.openDrawer();
  }

  void _createMarkers(void Function(Place) callback) async {
    final storesStream =
        await FirebaseFirestore.instance.collection('maps').get();
    final storesStreamS =
        await FirebaseFirestore.instance.collection('maps').snapshots();
    Set<Marker> lMarkers = {};
    int key = 0;
    for (var document in storesStream.docs) {
      var now = DateTime.now();
      String businessHours = "";
      double makerColor;

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

      //営業中か判定
      if (businessHours == "-") {
        makerColor = BitmapDescriptor.hueAzure;
      } else if (businessHours == "") {
        makerColor = BitmapDescriptor.hueGreen;
      } else {
        var businessHourSplit = businessHours.split(",");
        makerColor = BitmapDescriptor.hueAzure;
        for (var businessHour in businessHourSplit) {
          var splitTime = businessHour.split("～");
          String openHour = splitTime[0].split(":")[0];
          String openMinute = splitTime[0].split(":")[1];
          String closeHour = splitTime[1].split(":")[0];
          String closeMinute = splitTime[1].split(":")[1];
          DateTime openTime = DateTime(now.year, now.month, now.day,
              int.parse(openHour), int.parse(openMinute));
          DateTime closeTime = DateTime(now.year, now.month, now.day,
              int.parse(closeHour), int.parse(closeMinute));

          if (openTime.isBefore(now) & now.isBefore(closeTime)) {
            makerColor = BitmapDescriptor.hueRed;
            break;
          }
        }
      }

      Place place = Place(
        documentId: document.id,
        name: document['name'],
        installationPlace: document['place'],
        monday: document['monday'],
        tuesday: document['tuesday'],
        wednesday: document['wednesday'],
        thursday: document['thursday'],
        friday: document['friday'],
        saturday: document['saturday'],
        sunday: document['sunday'],
        address: document['address'],
        tel: document['tel'],
        note: document['note'],
        quote: document['quote'],
      );

      lMarkers.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(makerColor),
        markerId: MarkerId(key.toString()),
        position: LatLng(document['lat'], document['lng']),
        onTap: () => callback(place),
      ));
      key++;
    }
    setState(() {
      _markers = lMarkers;
    });
  }
}

//ドロワーで使用
class Place {
  String documentId;
  String name;
  String installationPlace;
  String monday;
  String tuesday;
  String wednesday;
  String thursday;
  String friday;
  String saturday;
  String sunday;
  String address;
  String tel;
  String note;
  String quote;
  Place({
    this.documentId = "",
    this.name = "",
    this.installationPlace = "",
    this.monday = "",
    this.tuesday = "",
    this.wednesday = "",
    this.thursday = "",
    this.friday = "",
    this.saturday = "",
    this.sunday = "",
    this.address = "",
    this.tel = "",
    this.note = "",
    this.quote = "",
  });
}
