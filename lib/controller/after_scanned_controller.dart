import 'package:get/get.dart';
import 'package:smiljkovic/model/order_model.dart';

class AfterScannedController extends GetxController {
  Rx<OrderModel> orderModel = OrderModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }
}
