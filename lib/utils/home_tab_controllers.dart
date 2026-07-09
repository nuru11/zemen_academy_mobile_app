import 'package:get/get.dart';
import 'package:vector_academy/controllers/exam/exam_controller.dart';
import 'package:vector_academy/controllers/home/home_dashboard_controller.dart';
import 'package:vector_academy/controllers/home/main_navigation_controller.dart';
import 'package:vector_academy/controllers/misc/certificate_controller.dart';
import 'package:vector_academy/controllers/misc/downloads_controller.dart';
import 'package:vector_academy/controllers/misc/news_controller.dart';
import 'package:vector_academy/controllers/misc/profile_controller.dart';

void clearHomeTabControllers() {
  if (Get.isRegistered<HomeDashboardController>()) {
    Get.delete<HomeDashboardController>(force: true);
  }
  if (Get.isRegistered<MainNavigationController>()) {
    Get.delete<MainNavigationController>(force: true);
  }
  if (Get.isRegistered<ProfileController>()) {
    Get.delete<ProfileController>(force: true);
  }
  if (Get.isRegistered<ExamController>()) {
    Get.delete<ExamController>(force: true);
  }
  if (Get.isRegistered<NewsController>()) {
    Get.delete<NewsController>(force: true);
  }
  if (Get.isRegistered<DownloadsController>()) {
    Get.delete<DownloadsController>(force: true);
  }
  if (Get.isRegistered<CertificateController>()) {
    Get.delete<CertificateController>(force: true);
  }
}
