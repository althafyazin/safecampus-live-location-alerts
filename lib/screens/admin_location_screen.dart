import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/api_constants.dart';
import 'package:geocoding/geocoding.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _locationDataList = [];
  bool _isLoading = true;
  bool _showMap = false;
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isSatelliteView = false; // Toggle for satellite view
  Position? _adminPosition; // Admin's current location
  Set<Marker> _markers = {}; // Markers for admin and user locations
  Set<Polyline> _polylines = {}; // Polyline for directions
  bool _showDirections = false; // Toggle for showing directions
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _fetchLocationData();
    _getAdminLocation();
  }

  Future<void> _fetchLocationData() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/location-data"),
      );

      if (response.statusCode == 200) {
        setState(() {
          _locationDataList = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load location data');
      }
    } catch (e) {
      print('Error fetching location data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAdminLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location services are disabled.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location permissions are denied.")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Location permissions are permanently denied.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _adminPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching admin location: $e")),
      );
    }
  }

  void _showLocationOnMap(
      double latitude, double longitude, String locationName, String userName) {
    setState(() {
      _showMap = true;
      _selectedLatitude = latitude;
      _selectedLongitude = longitude;
      _updateMarkers(locationName, userName);
    });
  }

  void _goBackToList() {
    setState(() {
      _showMap = false;
      _showDirections = false;
      _polylines.clear();
    });
  }

  void _deleteLocation(int index) async {
    final locationData = _locationDataList[index];
    final String deleteEndpoint = "http://localhost:3000/api/delete-location";

    try {
      final response = await http.delete(
        Uri.parse(deleteEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"id": locationData['id']}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _locationDataList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete location")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Toggle between map types
  void _toggleMapType() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  // Update markers
  void _updateMarkers(String locationName, String userName) {
    if (_adminPosition == null ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      return;
    }

    _markers.clear();

    // Add admin's location marker (red)
    _markers.add(
      Marker(
        markerId: MarkerId("adminLocation"),
        position: LatLng(_adminPosition!.latitude, _adminPosition!.longitude),
        infoWindow: InfoWindow(
          title: "Admin Location",
          snippet: "Your current location",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add student's location marker (blue)
    _markers.add(
      Marker(
        markerId: MarkerId("locationMarker"),
        position: LatLng(_selectedLatitude!, _selectedLongitude!),
        infoWindow: InfoWindow(
          title: locationName,
          snippet:
              "Student: $userName\nLat: $_selectedLatitude, Long: $_selectedLongitude",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Adjust camera to show both markers
    if (_mapController != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          min(_adminPosition!.latitude, _selectedLatitude!),
          min(_adminPosition!.longitude, _selectedLongitude!),
        ),
        northeast: LatLng(
          max(_adminPosition!.latitude, _selectedLatitude!),
          max(_adminPosition!.longitude, _selectedLongitude!),
        ),
      );

      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  // Fetch directions using Google Directions API
  Future<void> _getDirections(double lat, double lng) async {
    if (_adminPosition == null ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      return;
    }

    final String apiKey = ApiConstants.googleMapsApiKey;
    final String origin =
        "${_adminPosition!.latitude},${_adminPosition!.longitude}";
    final String destination = "$lat,$lng";
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final List<LatLng> points =
            _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId("directions"),
              points: points,
              color: Colors.green,
              width: 5,
            ),
          );
          _showDirections = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to fetch directions: ${data['status']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching directions: $e")),
      );
    }
  }

  // Decode polyline points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Locations'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchLocationData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLocationData,
              child: _buildLocationList(),
            ),
    );
  }

  Widget _buildLocationList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_locationDataList.isEmpty) {
      return Center(child: Text('No location data available'));
    }

    return ListView.builder(
      itemCount: _locationDataList.length,
      itemBuilder: (context, index) {
        final locationData = _locationDataList[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(
              locationData['location_name'] ?? 'Unknown Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${locationData['name']}"),
                Text("Admission No: ${locationData['admission_number']}"),
                Text("Phone: ${locationData['phone_number']}"),
                Text(
                  "Coordinates: ${locationData['latitude']?.toStringAsFixed(6)}, ${locationData['longitude']?.toStringAsFixed(6)}",
                ),
                Text(
                  "Time: ${DateTime.parse(locationData['timestamp']).toLocal().toString()}",
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () {
                    _showLocationOnMap(
                      double.parse(locationData['latitude'].toString()),
                      double.parse(locationData['longitude'].toString()),
                      locationData['location_name'] ?? 'Unknown Location',
                      locationData['name'],
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.directions),
                  onPressed: () {
                    _getDirections(
                      double.parse(locationData['latitude'].toString()),
                      double.parse(locationData['longitude'].toString()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteLocation(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
