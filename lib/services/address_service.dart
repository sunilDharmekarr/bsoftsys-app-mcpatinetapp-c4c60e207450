import 'package:geolocator/geolocator.dart';

class AddressService {
  AddressService._internal();
  static final AddressService _instance = AddressService._internal();

  static AddressService get instance => _instance;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  Placemark _places;

  Position get currentLatLon => _currentPosition;

  Placemark get place => _places;

  set currentPosition(Position position) => this._currentPosition = position;

  set currentLocation(Placemark placemark) => this._places = placemark;

  Future<Position> getCurrentLocation() async {
    final data = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    if (data != null)
      return data;
    else
      return Position(latitude: 0.0, longitude: 0.0);
  }

  Future<Placemark> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = p[0];
      return place;
    } catch (e) {
      print(e);
      return Placemark(
          country: '', administrativeArea: '', locality: '', postalCode: '');
    }
  }
}
