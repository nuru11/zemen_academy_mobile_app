import 'dart:io';
import 'package:vector_academy/utils/device/device.dart';
import 'package:vector_academy/views/views.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/services.dart';
import 'package:vector_academy/services/api/exceptions.dart';
import 'package:vector_academy/utils/utils.dart';
import 'package:vector_academy/utils/storages/storages.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final ImagePicker _picker = ImagePicker();

  List<PaymentMethod> paymentMethods = <PaymentMethod>[];
  List<Payment> userPayments = <Payment>[];
  List<Package> packages = <Package>[];
  PaymentMethod? selectedPaymentMethod;
  File? selectedReceiptImage;
  String? referralCode;

  bool isLoading = false;
  bool isLoadingPayments = false;
  bool isCreatingPayment = false;
  User? _user;

  @override
  void onInit() async {
    super.onInit();
    _user = await HiveUserStorage().getUser();
    loadUserPayments();
    loadPackages();

    logger.i('User: $_user');
    HiveUserStorage().listen((event) {
      _user = event;
      loadPaymentMethods();
      loadUserPayments();
      loadPackages();
    }, 'user');
  }

  void changeSelectedPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod = method;
    update();
  }

  // Load available payment methods
  Future<void> loadPaymentMethods() async {
    try {
      isLoading = true;
      update();
      final paymentMethods_ = await _paymentService.getPaymentMethods();
      paymentMethods = paymentMethods_;
    } catch (e) {
      logger.e(e);
      Get.snackbar(
        'Error',
        e is ApiException ? e.message : 'Failed to load payment methods',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // Load user's payment history
  Future<void> loadUserPayments() async {
    try {
      isLoadingPayments = true;
      update();
      final device = await UserDevice.getDeviceInfo(_user?.phoneNumber ?? '');
      final userPayments_ = await _paymentService.getUserPayments(device.id);
      userPayments = userPayments_;
    } catch (e) {
      Get.snackbar(
        'Error',
        e is ApiException ? e.message : 'Failed to load payment history',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPayments = false;
      update();
    }
  }

  // Select payment method
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod = method;
    update();
  }

  // Pick receipt image from gallery
  Future<void> pickReceiptImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedReceiptImage = File(image.path);
        update();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Take receipt photo with camera
  Future<void> takeReceiptPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedReceiptImage = File(image.path);
        update();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load available packages
  Future<void> loadPackages() async {
    try {
      isLoading = true;
      update();
      final device = await UserDevice.getDeviceInfo(_user?.phoneNumber ?? '');
      final grade = _user?.grade;
      final packages_ = await _paymentService.getPackages(
        device.id,
        grade: grade?.id,
      );
      packages = packages_;
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is ApiException ? e.message : 'Failed to load packages',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      loadPaymentMethods();
    }
  }

  // Create payment
  Future<bool> createPayment(int packageId, int amount, {String? referralCode}) async {
    isCreatingPayment = true;
    update();

    if (selectedPaymentMethod == null) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedReceiptImage == null) {
      Get.snackbar(
        'Error',
        'Please upload a receipt image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isCreatingPayment = true;
      update();
      final device = await UserDevice.getDeviceInfo(_user?.phoneNumber ?? '');
      await _paymentService.uploadReceipt(
        file: selectedReceiptImage!,
        package: packageId,
        paymentMethod: selectedPaymentMethod!.id,
        amount: amount,
        device: device.id,
        referralCode: referralCode,
      );

      Get.snackbar(
        'Success',
        'Payment submitted successfully! It will be reviewed by admin!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Reset form
      selectedPaymentMethod = null;
      selectedReceiptImage = null;
      referralCode = null;

      // Refresh user payments
      loadUserPayments();

      Get.offAllNamed(VIEWS.home.path);
      return true;
    } catch (e) {
      logger.e(e);
      Get.snackbar(
        'Error',
        e is ApiException ? e.message : 'Failed to create payment',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreatingPayment = false;
      update();
    }
  }

  // Clear selected items
  void clearSelection() {
    selectedPaymentMethod = null;
    selectedReceiptImage = null;
    referralCode = null;
    update();
  }
  
  // Set referral code
  void setReferralCode(String? code) {
    referralCode = code?.trim().toUpperCase();
    update();
  }

  // Get payment status color
  Color getPaymentStatusColor(bool isCompleted) {
    if (isCompleted) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  // Get payment status icon
  IconData getPaymentStatusIcon(bool isCompleted) {
    if (isCompleted) {
      return Icons.check_circle;
    } else {
      return Icons.pending;
    }
  }
}
