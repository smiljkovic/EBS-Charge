import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:smiljkovic/constant/constant.dart';
import 'package:smiljkovic/model/location_lat_lng.dart';
import 'package:smiljkovic/model/parking_model.dart';
import 'package:smiljkovic/utils/fire_store_utils.dart';
import 'package:place_picker/place_picker.dart';

class SearchScreenController extends GetxController {
  Rx<TextEditingController> searchController = TextEditingController().obs;
  Rx<LocationLatLng> latLng = LocationLatLng().obs;

  RxString selectedSortBy = 'distance'.tr.obs;

  RxString parkingType = "2".obs;
  RxDouble selectedKm = 2.0.obs;

  void handleParkingChange(String? value) {
    parkingType.value = value!;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getParking();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<ParkingModel> parkingList = <ParkingModel>[].obs;

  getParking() {
    FireStoreUtils()
        .getParkingNearest(latitude: latLng.value.latitude ?? Constant.currentLocation!.latitude, longLatitude: latLng.value.longitude ?? Constant.currentLocation!.longitude)
        .listen((event) {
      parkingList.value = event;
    });
    isLoading.value = false;
  }

  filterParking() {
    isLoading.value = true;
    parkingList.clear();
    FireStoreUtils()
        .getFilterParking(
            latitude: latLng.value.latitude ?? Constant.currentLocation!.latitude,
            longLatitude: latLng.value.longitude ?? Constant.currentLocation!.longitude,
            distance: selectedSortBy.value == "distance".tr ? selectedKm.value.toString() : Constant.radius,
            parkingType: parkingType.value)
        .listen((event) {
      parkingList.value = event;
      if (selectedSortBy.value == "higher_price".tr) {
        parkingList.sort((b, a) => int.parse(a.perHrPrice!).compareTo(int.parse(b.perHrPrice.toString())));
      } else {
        parkingList.sort((b, a) => int.parse(b.perHrPrice!).compareTo(int.parse(a.perHrPrice.toString())));
      }
    });
    isLoading.value = false;
  }

  Future<String> getDistance(LatLng source, LatLng latLng) async {
    String distance = "";
    await Constant.getDurationDistance(source, latLng).then((value) {
      if (value != null) {
        if (Constant.distanceType == "Km") {
          distance = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toStringAsFixed(1)} Km";
        } else {
          distance = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toStringAsFixed(1)} Miles";
        }
      }
    });
    return distance;
  }
}
