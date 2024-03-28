import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smiljkovic/constant/constant.dart';
import 'package:smiljkovic/model/currency_model.dart';
import 'package:smiljkovic/model/user_model.dart';
import 'package:smiljkovic/utils/fire_store_utils.dart';
import 'package:smiljkovic/utils/notification_service.dart';

import '../constant/collection_name.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();

    super.onInit();
  }

  getCurrentCurrency() async {
    FireStoreUtils.fireStore.collection(CollectionName.currency).where("enable", isEqualTo: true).snapshots().listen((event) {
      if (event.docs.isNotEmpty) {
        Constant.currencyModel = CurrencyModel.fromJson(event.docs.first.data());
      } else {
        Constant.currencyModel = CurrencyModel(id: "", code: "USD", decimalDigits: 2, enable: true, name: "US Dollar", symbol: "\$", symbolAtRight: false);
      }
    });
    await FireStoreUtils().getSettings();
  }

  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");
      if (FirebaseAuth.instance.currentUser != null) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
          if (value != null) {
            UserModel driverUserModel = value;
            driverUserModel.fcmToken = token;
            FireStoreUtils.updateUser(driverUserModel);
          }
        });
      }
    });
  }
}
