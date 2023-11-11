import '../models/active_driver_model.dart';

class GeofireAssistant {
  static List<ActiveDriverModel> activeDriverList = [];
  static void deleteOfflineDriverFromList(String driverId) {
    int index = activeDriverList.indexWhere((element) => element.driverId == driverId);
    activeDriverList.removeAt(index);
  }

  static void updateActiveDriverLocation(ActiveDriverModel activeDriver) {
    int index = activeDriverList.indexWhere((element) => element.driverId == activeDriver.driverId);

    activeDriverList[index].locationLatitude = activeDriver.locationLatitude;
    activeDriverList[index].locationLongitude = activeDriver.locationLongitude;
  }
}
