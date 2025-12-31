import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import '../widgets/snack_bar_widget.dart';

class SignupController extends GetxController {
  // data members
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  final apiService = ApiService();

  // data methods
  Future<void> signupApi(BuildContext context) async {
    isLoading.value = true;
    // bool isConnected = await NetworkController.checkConnectionShowSnackBar(
    //   context,
    // );
    // if (!isConnected) {
    //   isLoading.value = false;
    //   return;
    // }
    try {
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        endpoint: Endpoints.signUp,
        body: {
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text
        },
      );

      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {
          ApiCode.requestTimeout1: true,
          ApiCode.unauthorized401: true,
          ApiCode.conflict409: true,
          ApiCode.notFound404: true,
        },
        customMessages: {
          ApiCode.unauthorized401: true,
          ApiCode.conflict409: true,
          ApiCode.notFound404: true,
        },
      );

      if (result) {
        isLoading.value = false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(),)
        );
      }
    } catch (e) {
      SnackBarWidget.showError(context);
    } finally {
      isLoading.value = false;
    }
  }
}
