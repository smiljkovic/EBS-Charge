import 'package:flutter/material.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:get/get.dart';
import 'package:smiljkovic/constant/collection_name.dart';
import 'package:smiljkovic/constant/constant.dart';
import 'package:smiljkovic/constant/show_toast_dialog.dart';
import 'package:smiljkovic/controller/inbox_controller.dart';
import 'package:smiljkovic/model/user_model.dart';
import 'package:smiljkovic/themes/app_them_data.dart';
import 'package:smiljkovic/themes/common_ui.dart';
import 'package:smiljkovic/themes/responsive.dart';
import 'package:smiljkovic/ui/chat/chat_screen.dart';
import 'package:smiljkovic/ui/chat/model/inbox_model.dart';
import 'package:smiljkovic/utils/dark_theme_provider.dart';
import 'package:smiljkovic/utils/fire_store_utils.dart';
import 'package:smiljkovic/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<InboxController>(
      init: InboxController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            isBack: true,
            'Inbox'.tr,
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : PaginateFirestore(
                  scrollDirection: Axis.vertical,
                  query:
                      FireStoreUtils.fireStore.collection(CollectionName.chat).doc(controller.senderUserModel.value.id).collection("inbox").orderBy("timestamp", descending: true),
                  itemBuilderType: PaginateBuilderType.listView,
                  isLive: true,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  shrinkWrap: true,
                  reverse: true,
                  onEmpty: Constant.showEmptyView(message: "No conversion found".tr),
                  onError: (error) {
                    return ErrorWidget(error);
                  },
                  itemBuilder: (context, documentSnapshots, index) {
                    InboxModel inboxModel = InboxModel.fromJson(documentSnapshots[index].data() as Map<String, dynamic>);
                    return Container(
                        padding: const EdgeInsets.only(left: 14, right: 14, top: 06, bottom: 06),
                        child: InkWell(
                          onTap: () async {
                            ShowToastDialog.showLoader("Please wait".tr);
                            await FireStoreUtils.getUserProfile(
                                    controller.senderUserModel.value.id == inboxModel.senderId.toString() ? inboxModel.receiverId.toString() : inboxModel.senderId.toString())
                                .then((value) {
                              ShowToastDialog.closeLoader();
                              UserModel userModel = value!;
                              Get.to(const ChatScreen(), arguments: {"receiverModel": userModel});
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            child: FutureBuilder<UserModel?>(
                                future: FireStoreUtils.getUserProfile(
                                    controller.senderUserModel.value.id == inboxModel.senderId.toString() ? inboxModel.receiverId.toString() : inboxModel.senderId.toString()),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Constant.loader();
                                    case ConnectionState.done:
                                      if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        UserModel? userModel = snapshot.data;
                                        return Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(60),
                                              child: NetworkImageWidget(
                                                imageUrl: userModel!.profilePic.toString(),
                                                height: Responsive.width(12, context),
                                                width: Responsive.width(12, context),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          userModel.fullName.toString(),
                                                          style: TextStyle(
                                                              color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey09,
                                                              fontFamily: AppThemData.semiBold,
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      Text(
                                                        Constant.timestampToDateChat(inboxModel.timestamp!),
                                                        style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontFamily: AppThemData.medium, fontSize: 12),
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    userModel.email.toString(),
                                                    style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontFamily: AppThemData.medium, fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    default:
                                      return Text('Error'.tr);
                                  }
                                }),
                          ),
                        ));
                  },
                ),
        );
      },
    );
  }
}
