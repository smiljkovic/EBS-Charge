import 'dart:developer';

import 'package:get/get.dart';
import 'package:smiljkovic/model/order_model.dart';
import 'package:smiljkovic/model/parking_model.dart';
import 'package:smiljkovic/utils/fire_store_utils.dart';

import '../model/charger_model.dart';

class ChargerViewController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxString selectedCharger = "".obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<ChargerModel> chargerModel = ChargerModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      getChargerDetails();
      getBookedCharger();
    }
    update();
  }

  getChargerDetails() async {
    await FireStoreUtils.getChargerDetails(orderModel.value.chargerDetails!.id.toString()).then((value) {
      if (value != null) {
        chargerModel.value = value;
      }
    });
    isLoading.value = false;
  }

  RxList<OrderModel> selectedOrderModel = <OrderModel>[].obs;

  getBookedCharger() async {
    log("myTime ===>${orderModel.value.bookingDate!.toDate()} \n==>StartTime ${orderModel.value.bookingStartTime!.toDate()} \n==>endTime ${orderModel.value.bookingEndTime!.toDate()}");

    await FireStoreUtils.getOrder(orderModel.value.bookingDate!, orderModel.value.bookingStartTime!, orderModel.value.bookingEndTime!, orderModel.value.chargerId.toString())
        .then((value) {
      if (value != null) {
        for (var element in value) {
          OrderModel orderModel1 = element;
          if (orderModel1.bookingStartTime!.toDate().isBefore(orderModel.value.bookingStartTime!.toDate()) &&
              orderModel1.bookingEndTime!.toDate().isAfter(orderModel.value.bookingStartTime!.toDate())) {
            log("charger ===>${orderModel1.chargerSlotId}");
            selectedOrderModel.add(orderModel1);
          } else if (orderModel.value.bookingStartTime!.toDate().isAtSameMomentAs(orderModel1.bookingStartTime!.toDate())) {
            selectedOrderModel.add(orderModel1);
            log("charger ===>4 ${orderModel1.chargerSlotId}");
          } else if (orderModel.value.bookingStartTime!.toDate().isBefore(orderModel1.bookingStartTime!.toDate())) {
            if (orderModel.value.bookingEndTime!.toDate().isAfter(orderModel1.bookingEndTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("charger ===>2 ${orderModel1.chargerSlotId}");
            } else if (orderModel.value.bookingEndTime!.toDate().isAtSameMomentAs(orderModel1.bookingEndTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("charger ===>2 ${orderModel1.chargerSlotId}");
            } else if (orderModel.value.bookingEndTime!.toDate().isBefore(orderModel1.bookingEndTime!.toDate()) &&
                orderModel.value.bookingEndTime!.toDate().isAfter(orderModel1.bookingStartTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("charger ===>3 ${orderModel1.chargerSlotId}");
            } else {
              log("charger ===>2 else");
            }
          } else {
            log("charger ===>1 else");
          }
        }
      }
    });
  }
}
