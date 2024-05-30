import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';
import 'package:homp3/screen/home.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(GetMaterialApp(
    theme: ThemeData.dark(),
    initialBinding: BindingsBuilder(() {
      Get.lazyPut<MyController>(() => MyController());
    }),
    home: Obx(() {
      final MyController controller = Get.find<MyController>();
      return controller.isLoadingDone.value
          ? Home()
          : Center( child: CircularProgressIndicator(), );
    }),
  ));
}
