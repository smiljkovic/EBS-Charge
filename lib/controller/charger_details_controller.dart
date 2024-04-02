import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smiljkovic/constant/constant.dart';
import 'package:smiljkovic/utils/fire_store_utils.dart';

import '../model/charger_model.dart';

class ChargerDetailsController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  Rx<ChargerModel> chargerModel = ChargerModel().obs;

  RxString duration = "".obs;
  RxString distance = "".obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      chargerModel.value = argumentData['chargerModel'];
      calculate();
    }
    isLoading.value = false;
    update();
  }

  getData() async {
    await FireStoreUtils.getChargerDetails(chargerModel.value.id.toString()).then((value) {
      if (value != null) {
        chargerModel.value = value;
      }
    });
  }

  calculate() async {
    log("------->");

    await Constant.getDurationDistance(LatLng(Constant.currentLocation!.latitude!, Constant.currentLocation!.longitude!),
            LatLng(chargerModel.value.location!.latitude!, chargerModel.value.location!.longitude!))
        .then((value) {
      if (value != null) {
        log(value.toJson().toString());
        duration.value = value.rows!.first.elements!.first.duration!.text.toString();

        if (Constant.distanceType == "Km") {
          distance.value = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toStringAsFixed(1)} Km";
        } else {
          distance.value = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toStringAsFixed(1)} Miles";
        }
      }
    });
  }
}
