import '../utils/app_strings.dart';
import '../utils/app_validators.dart';
import '../views/signup_view.dart';
import '../widgets/background_image_widget.dart';
import '../widgets/button_widgets.dart';
import '../widgets/text_field_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/styles.dart';
import '../utils/app_input_formatters.dart';
import '../widgets/glassmorphic_card_widget.dart';
import '../widgets/loading_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  late final LoginController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = Get.put(LoginController());
    // if(kDebugMode){
    //   controller.emailController.text = "karthikayansde@gmail.com";
    //   controller.passwordController.text = "karthik";
    // }else{
    controller.emailController.text = "";
    controller.passwordController.text = "";
    // }
    controller.isPasswordHidden.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: Obx(
        ()=> Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: controller.formKey,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Card(
                        color: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 16,),
                                Align(
                                  alignment: Alignment.center,
                                  child: Image.asset('assets/images/iMirAI-Logo1.png', height: 50, width: 180),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: .center,
                                  child: Text(
                                    "Login",
                                    style: text28Bold.copyWith(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFieldWidget(
                                  isBorderNeeded: true,
                                  hasHindOnTop: true,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(Icons.person_2_outlined, size: 18),
                                  ),
                                  maxLines: 1,
                                  // inputFormatters: AppInputFormatters.email(),
                                  validator: AppValidators.name,
                                  hint: AppStrings.userName,
                                  controller: controller.emailController,
                                ),
                                TextFieldWidget(
                                  isBorderNeeded: true,
                                  hasHindOnTop: true,
                                  isPassword: controller.isPasswordHidden.value,
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      controller.isPasswordHidden.value =
                                          !controller.isPasswordHidden.value;
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: controller.isPasswordHidden.value
                                          ? Icon(
                                              Icons.visibility_outlined,
                                              size: 18,
                                            )
                                          : Icon(Icons.visibility_off_outlined, size: 18),
                                    ),
                                  ),
                                  maxLines: 1,
                                  inputFormatters: [
                                    AppInputFormatters.limitedText(maxLength: 16),
                                    AppInputFormatters.lettersNumbersSymbolsFormat,
                                  ],
                                  validator: AppValidators.password,
                                  hint: AppStrings.password,
                                  controller: controller.passwordController,
                                ),
                                const SizedBox(height: 15),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignupView(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.dontHaveAnAccount,
                                        style: bodyText16.copyWith(
                                          height: 1.6,
                                          color: AppColors.textPrimary,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppStrings.register,
                                        style: bodyText16.copyWith(
                                          fontWeight: FontWeight.w700,
                                          height: 1.6,
                                          color: AppColors.primary,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                BasicButtonWidget(
                                  onPressed: () async {
                                    if (controller.formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      await controller.loginApi(context);
                                    }
                                  },
                                  label: AppStrings.login,
                                ),

                                SizedBox(height: 16,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (controller.isLoading.value)
              Positioned.fill(
                child: Container(
                  color: AppColors.shadowMedium,
                  child: LoadingWidget.loader()
                ),
              ),
          ],
        ),
      ),
    );
  }
}
