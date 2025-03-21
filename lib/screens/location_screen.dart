import 'package:antiragging1/screens/admin_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:antiragging1/models/student.dart';
import 'package:antiragging1/constants/api_constants.dart';
import 'package:geocoding/geocoding.dart';

extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition;
  String _locationMessage = "Fetching location...";
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStream;
  int _buttonPressCount = 0;
  final Box<Student> studentBox = Hive.box<Student>('students');
  bool _isSatelliteView = false;
  bool _isHighAccuracy = false;
  int _gpsSatellites = 0;
  String _locationSource = "Unknown";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationStream();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = "Location permissions are permanently denied.";
        });
        return;
      }

      bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isGpsEnabled) {
        setState(() {
          _locationMessage =
              "GPS is disabled. Please enable it for better accuracy.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 5),
        ),
      );

      setState(() {
        _currentPosition = position;
        _locationMessage = "Location fetched successfully!";
        _isHighAccuracy = position.accuracy <= 10;
        _locationSource = position.isMocked ? "Mock Provider" : "GPS";
        _updateMap(position);
      });
    } catch (e) {
      setState(() {
        _locationMessage = "Error fetching location: $e";
      });
    }
  }

  void _startLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
      timeLimit: Duration(seconds: 5),
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
          _locationMessage = "Real-time location updated!";
          _isHighAccuracy = position.accuracy <= 10;
          _locationSource = position.isMocked ? "Mock Provider" : "GPS";
          _updateMap(position);
        });
      },
      onError: (e) {
        setState(() {
          _locationMessage = "Error in location stream: $e";
        });
      },
    );
  }

  void _updateMap(Position position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId("currentLocation"),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: "You are here"),
          ),
        );
      });
    }
  }

  void _toggleMapType() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  Future<void> _sendLocationToAdmin() async {
    if (_currentPosition == null) {
      setState(() {
        _locationMessage = "Location not available.";
      });
      return;
    }

    setState(() {
      _buttonPressCount++;
    });

    print("Button pressed $_buttonPressCount times");

    if (_buttonPressCount == 3) {
      final String adminEndpoint = "${ApiConstants.baseUrl}/api/send-location";

      final Student? currentStudent = studentBox.values.firstWhereOrNull(
        (student) => student.admissionNumber != null,
      );

      if (currentStudent == null) {
        setState(() {
          _locationMessage = "User details not found.";
        });
        return;
      }

      // Get location name using Google Maps Geocoding API
      String locationName = "Unknown Location";
      try {
        print(
            "🌍 Starting geocoding with coordinates: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}");

        final String geocodingUrl =
            'https://maps.googleapis.com/maps/api/geocode/json?'
            'latlng=${_currentPosition!.latitude},${_currentPosition!.longitude}'
            '&key=${ApiConstants.googleMapsApiKey}'
            '&language=en';

        final response = await http.get(Uri.parse(geocodingUrl));
        print("📍 Geocoding API response status: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("📍 Geocoding API response: $data");

          if (data['status'] == 'OK' &&
              data['results'] != null &&
              data['results'].isNotEmpty) {
            final results = data['results'][0];
            final components = results['address_components'] as List;

            // Try to build a meaningful location name
            String? sublocality = components.firstWhere(
                (comp) => (comp['types'] as List).contains('sublocality'),
                orElse: () => null)?['long_name'];

            String? locality = components.firstWhere(
                (comp) => (comp['types'] as List).contains('locality'),
                orElse: () => null)?['long_name'];

            String? area = components.firstWhere(
                (comp) => (comp['types'] as List)
                    .contains('administrative_area_level_3'),
                orElse: () => null)?['long_name'];

            List<String> locationParts = [];
            if (sublocality != null) locationParts.add(sublocality);
            if (locality != null) locationParts.add(locality);
            if (area != null) locationParts.add(area);

            if (locationParts.isNotEmpty) {
              locationName = locationParts.join(', ');
            } else {
              // If no specific components found, use formatted address
              locationName = results['formatted_address'] ?? "Unknown Location";
            }

            print("📍 Final location name: $locationName");
          }
        }
      } catch (e) {
        print("❌ Error in geocoding: $e");
        locationName = "Unknown Location";
      }

      final Map<String, dynamic> locationData = {
        "name": currentStudent.name,
        "admission_number": currentStudent.admissionNumber,
        "phone_number": currentStudent.phoneNumber,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude,
        "timestamp": DateTime.now().toIso8601String(),
        "location_name": locationName,
      };

      print("📤 Sending location data: $locationData");

      try {
        final response = await http.post(
          Uri.parse(adminEndpoint),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(locationData),
        );

        if (response.statusCode == 200) {
          setState(() {
            _locationMessage = "Location sent to admin successfully!";
          });
        } else {
          setState(() {
            _locationMessage = "Failed to send location. Please try again.";
          });
        }
      } catch (e) {
        setState(() {
          _locationMessage = "Error: $e";
        });
      }

      setState(() {
        _buttonPressCount = 0;
      });
    }
  }

  String _getLocationQualityMessage() {
    if (_currentPosition == null) return "No location data";

    if (_currentPosition!.isMocked) {
      return "Warning: Location might be from a mock provider";
    }

    if (_currentPosition!.accuracy > 100) {
      return "Poor accuracy: More than 100 meters";
    } else if (_currentPosition!.accuracy > 50) {
      return "Fair accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)} meters";
    } else if (_currentPosition!.accuracy > 10) {
      return "Good accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)} meters";
    } else {
      return "High accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)} meters";
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location"),
        actions: [
          IconButton(
            icon: Icon(_isSatelliteView ? Icons.map : Icons.satellite),
            onPressed: _toggleMapType,
          ),
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition?.latitude ?? 0.0,
                  _currentPosition?.longitude ?? 0.0,
                ),
                zoom: 15.0,
              ),
              markers: _markers,
              mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _locationMessage,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                if (_currentPosition != null)
                  Column(
                    children: [
                      Text(
                        "Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getLocationQualityMessage(),
                        style: TextStyle(
                          fontSize: 16,
                          color: _isHighAccuracy ? Colors.green : Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Location Source: $_locationSource",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendLocationToAdmin,
                  child: Text("Send Location to Admin"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
