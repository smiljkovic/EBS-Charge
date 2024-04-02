import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smiljkovic/constant/constant.dart';
import 'package:smiljkovic/constant/show_toast_dialog.dart';
import 'package:smiljkovic/themes/app_them_data.dart';
import 'package:smiljkovic/themes/common_ui.dart';
import 'package:smiljkovic/themes/round_button_fill.dart';
import 'package:smiljkovic/ui/booking_process/review_summery_screen.dart';
import 'package:smiljkovic/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../../controller/charger_view_controller.dart';

class ChargerViewScreen extends StatelessWidget {
  const ChargerViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ChargerViewController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "pick_charger_spot".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.builder(
                        itemCount: int.parse(controller.chargerModel.value.numChargers.toString()),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(4.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
                        itemBuilder: (context, int index) {
                          return Obx(
                            () {
                              var isBooked = controller.selectedOrderModel.where((element) => element.chargerSlotId.toString() == "A-${index + 1}");
                              return InkWell(
                                onTap: () {
                                  if (isBooked.isEmpty) {
                                    controller.selectedCharger.value = "A-${index + 1}";
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: index.isEven ? const BorderSide(color: AppThemData.grey04) : BorderSide.none,
                                          bottom: const BorderSide(color: AppThemData.grey04),
                                          top: const BorderSide(color: AppThemData.grey04),
                                          left: index.isOdd ? const BorderSide(color: AppThemData.grey04) : BorderSide.none)),
                                  child: isBooked.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Image.asset(
                                            "assets/images/car_image.png",
                                          ),
                                        )
                                      : controller.selectedCharger.value == "A-${index + 1}"
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey04),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset("assets/icon/ic_parking_select.svg", width: 24, height: 24),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    'A-${index + 1}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: AppThemData.medium,
                                                      color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary07,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Center(
                                                child: Text(
                                                  'A-${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: AppThemData.medium,
                                                    color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08,
                                                  ),
                                                ),
                                              ),
                                            ),
                                ),
                              );
                            },
                          );
                        }),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Next".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    if (controller.selectedCharger.value.isEmpty) {
                      ShowToastDialog.showToast("Please select your charger".tr);
                    } else {
                      controller.orderModel.value.chargerSlotId = controller.selectedCharger.value;
                      Get.to(() => const ReviewSummaryScreen(), arguments: {"orderModel": controller.orderModel.value});
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
