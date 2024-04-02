import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smiljkovic/model/order_model.dart';
import 'package:smiljkovic/model/charger_model.dart';
import 'package:smiljkovic/model/user_model.dart';
import 'package:smiljkovic/utils/fire_store_utils.dart';

import '../model/review_model.dart';

class RatingController extends GetxController {
  RxBool isLoading = true.obs;
  RxDouble rating = 0.0.obs;
  Rx<TextEditingController> commentController = TextEditingController().obs;

  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<ChargerModel> chargerModel = ChargerModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getArgument();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    await FireStoreUtils.getChargerDetails(orderModel.value.chargerId.toString()).then((value) {
      if (value != null) {
        chargerModel.value = value;
      }
    });
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
    await FireStoreUtils.getReview(orderModel.value.id.toString()).then((value) {
      if (value != null) {
        reviewModel.value = value;
        rating.value = double.parse(reviewModel.value.rating.toString());
        commentController.value.text = reviewModel.value.comment.toString();
      }
    });
    isLoading.value = false;
    update();
  }
}
