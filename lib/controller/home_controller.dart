import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smiljkovic/constant/constant.dart';
import 'package:smiljkovic/constant/show_toast_dialog.dart';
import 'package:smiljkovic/model/location_lat_lng.dart';
import 'package:smiljkovic/model/parking_model.dart';

import 'package:smiljkovic/utils/fire_store_utils.dart';
import 'package:smiljkovic/utils/utils.dart';

import '../model/charger_model.dart';
import '../ui/charger_details_screen/charger_details_screen.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;

  GoogleMapController? mapController;
  BitmapDescriptor? chargerMarker;
  BitmapDescriptor? currentLocationMarker;

  @override
  void onInit() {
    getLocation();

    super.onInit();
  }

  getLocation() async {
    await addMarkerSetup();
    await Utils.getCurrentLocation().then((value) {
      print(value);
      if (value != null) {
        permissionDenied.value = false;
        Constant.currentLocation = LocationLatLng(latitude: value.latitude, longitude: value.longitude);
      } else {
        isLoading.value = false;
        permissionDenied.value = true;
      }
    });
    List<Placemark> placeMarks = await placemarkFromCoordinates(Constant.currentLocation!.latitude!, Constant.currentLocation!.longitude!);
    Constant.country = placeMarks.first.country;
    getTax();
    getCharger();
    isLoading.value = false;
  }

  RxBool permissionDenied = false.obs;

  getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
      }
    });
  }

  RxList<ChargerModel> chargersList = <ChargerModel>[].obs;

  getCharger() {
    FireStoreUtils().getChargerNearest(latitude: Constant.currentLocation!.latitude, longLatitude: Constant.currentLocation!.longitude).listen((event) {
      chargersList.value = event;
      for (var element in chargersList) {
        addMarker(latitude: element.location!.latitude, longitude: element.location!.longitude, id: element.id.toString(), rotation: 0, descriptor: chargerMarker!);
      }
    });
  }

  addMarkerSetup() async {
    final Uint8List charger = await Constant().getBytesFromAsset("assets/icon/ic_charger_icon.png", 100);
    chargerMarker = BitmapDescriptor.fromBytes(charger);

    final Uint8List currentLocation = await Constant().getBytesFromAsset("assets/icon/ic_current_user.png", 100);
    currentLocationMarker = BitmapDescriptor.fromBytes(currentLocation);
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: LatLng(latitude ?? 0.0, longitude ?? 0.0),
      rotation: rotation ?? 0.0,
      onTap: () {
        redirect(id);
      },
    );
    markers[markerId] = marker;
  }

  redirect(String id) async {
    ShowToastDialog.showLoader("Please wait..");
    await FireStoreUtils.getChargerDetails(id).then((value) {
      ShowToastDialog.closeLoader();
      Get.to(() => const ChargerDetailsScreen(), arguments: {"chargerModel": value!});
    });
  }

  @override
  void dispose() {
    FireStoreUtils().getNearestOrderRequestController!.close();
    super.dispose();
  }
}
