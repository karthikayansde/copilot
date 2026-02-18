import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iMirAI/utils/app_strings.dart';

import '../main.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import '../services/shared_pref_manager.dart';
import '../views/home_screen.dart';
import '../widgets/snack_bar_widget.dart';

class LoginController extends GetxController {
  // data members
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  final apiService = ApiService();

  // data methods
  Future<void> loginApi(BuildContext context) async {
    isLoading.value = true;
    // bool isConnected = await NetworkController.checkConnectionShowSnackBar(context);
    // if(!isConnected){
    //   isLoading.value = false;
    //   return;
    // }
    try {
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        customUrl: true,
        endpoint: Endpoints.registerBaseUrl+Endpoints.login,
        body: {
          "username": emailController.text,
          "password": passwordController.text
        },
        useFormData: true,
      );
      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {
          ApiCode.requestTimeout1: true,
          ApiCode.forbidden403: true,
          ApiCode.notFound404: false
        },
      );


      if(response.code == ApiCode.notFound404.index){
        if(response.data['detail'] == "User not found"){
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "User not found",
            contentType: ContentType.warning,
          );
        }else{
          SnackBarWidget.show(
            context,
            title: response.message,
            message: "The requested resource could not be found.",
            contentType: ContentType.failure,
          );
        }
      }

      if(result){
        await SharedPrefManager.instance.setBoolAsync(SharedPrefManager.isLoggedIn, true);
        await SharedPrefManager.instance.setStringAsync(SharedPrefManager.username, emailController.text);
        isLoading.value = false;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
