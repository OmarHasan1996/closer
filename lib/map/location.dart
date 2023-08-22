import 'package:location/location.dart';

LocationData? currentLocation;

void getCurrentLocation() async {
  Location location = Location();
  location.getLocation().then(
        (location) {
      currentLocation = location;
    },
  );
}
