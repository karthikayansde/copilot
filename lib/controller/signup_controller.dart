import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import '../services/shared_pref_manager.dart';
import '../views/home_screen.dart';
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
          "username": emailController.text,
          "password": passwordController.text
        },
        useFormData: true
      );

      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {
          ApiCode.requestTimeout1: true,
        },
      );

      if (result) {
        isLoading.value = false;
        await SharedPrefManager.instance.setBoolAsync(SharedPrefManager.isLoggedIn, true);
        await SharedPrefManager.instance.setStringAsync(SharedPrefManager.username, emailController.text);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(),),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      SnackBarWidget.showError(context);
    } finally {
      isLoading.value = false;
    }
  }
}
