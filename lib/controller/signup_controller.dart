import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otherOrgNameController = TextEditingController();
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  final List<String> organizations = ['Select organization', 'PiLog', 'Others'];
  final List<String> referringAdmins = [
    "Select referring admin",
    "IMAD SYED",
    "ASIF AHMED",
    "SHOUKAT ALI",
    "PARDHA SARADHI",
    "SALEEM KHAN",
    "KESHAV MODUGU",
    "SASI KRISHNA",
    "KOTI AZMIRA",
    "ALLAPARTHI HARITHA",
    "SHAIK FATHIMUNNISA",
    "NAZIMA YASMEEN"
  ];

  late var selectedOrganization = organizations[0].obs;
  late var selectedAdmin = referringAdmins[0].obs;
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
        customUrl: true,
        endpoint: Endpoints.registerBaseUrl+Endpoints.signUp,
        body: {
          "name": nameController.text,
          "username": userNameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "organization": selectedOrganization.value == "Others" ? otherOrgNameController.text : "PiLog",
          "referred_admin": selectedOrganization.value == "Others" ? selectedAdmin.value : "",
          "registration_type": selectedOrganization.value == "Others" ? "ADMIN_APPROVAL" : "DIRECT",
        },
        useFormData: true
      );

      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {
          ApiCode.requestTimeout1: true,
          // ApiCode.conflict409: true
        },
      );

      if(response.code == ApiCode.conflict409.index){
        if(response.data['detail'] == "USERNAME_EXISTS"){
          SnackBarWidget.show(
            context,
            title: response.message,
            message: "Username already exists",
            contentType: ContentType.warning,
          );
        }else{
          SnackBarWidget.show(
            context,
            title: response.message,
            message: "This email is already registered. Try logging in instead.",
            contentType: ContentType.warning,
          );
        }
      }

      if (result) {
        isLoading.value = false;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: Text(response.data['message'] ?? "Request submitted. You will receive an activation link once approved."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to login screen
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      SnackBarWidget.showError(context);
    } finally {
      isLoading.value = false;
    }
  }
}
