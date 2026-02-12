import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/signup_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/styles.dart';
import '../utils/app_input_formatters.dart';
import '../utils/app_strings.dart';
import '../utils/app_validators.dart';
import '../widgets/background_image_widget.dart';
import '../widgets/button_widgets.dart';
import '../widgets/glassmorphic_card_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/snack_bar_widget.dart';
import '../widgets/text_field_widgets.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final controller = Get.put(SignupController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.nameController.text = "";
    controller.userNameController.text = "";
    controller.emailController.text = "";
    controller.passwordController.text = "";
    controller.confirmPasswordController.text = "";
    controller.isPasswordHidden.value = true;
    controller.isConfirmPasswordHidden.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: Obx(
        () => Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: AppColors.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: controller.formKey,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),

                            SizedBox(height: 16,),
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/iMirAI-Logo1.png', height: 50, width: 180),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: AlignmentGeometry.center,
                              child: Text(
                                AppStrings.register,
                                style: text28Bold.copyWith(fontSize: 24),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFieldWidget(
                              isBorderNeeded: true,
                              hasHindOnTop: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                child: Icon(
                                  Icons.person_2_outlined,
                                  size: 18,
                                ),
                              ),
                              maxLines: 1,
                              maxLength: 50,
                              inputFormatters: [
                                AppInputFormatters.lettersNumbersSpaceSymbolsFormat,
                              ],
                              validator: AppValidators.name,
                              controller: controller.nameController,
                              hint: AppStrings.name,
                            ),
                  
                            TextFieldWidget(
                              isBorderNeeded: true,
                              hasHindOnTop: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Icon(Icons.person_2_outlined, size: 18),
                              ),
                              maxLines: 1,
                              maxLength: 50,
                              // inputFormatters: AppInputFormatters.email(),
                              validator: AppValidators.name,
                              hint: AppStrings.userName,
                              controller: controller.userNameController,
                            ),
                            TextFieldWidget(
                              isBorderNeeded: true,
                              hasHindOnTop: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Icon(Icons.email_outlined, size: 18),
                              ),
                              maxLines: 1,
                              validator: AppValidators.email,
                              hint: AppStrings.email,
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
                                      : Icon(
                                    Icons.visibility_off_outlined,
                                    size: 18,
                                  ),
                                ),
                              ),
                              maxLines: 1,
                              inputFormatters: [
                                AppInputFormatters.limitedText(maxLength: 100),
                                AppInputFormatters.lettersNumbersSymbolsFormat
                              ],
                              validator: AppValidators.password,
                              hint: AppStrings.password,
                              controller: controller.passwordController,
                            ),
                  
                            TextFieldWidget(
                              isBorderNeeded: true,
                              hasHindOnTop: true,
                              isPassword:
                              controller.isConfirmPasswordHidden.value,
                              suffixIcon: InkWell(
                                onTap: () {
                                  controller.isConfirmPasswordHidden.value =
                                  !controller
                                      .isConfirmPasswordHidden
                                      .value;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child:
                                  controller.isConfirmPasswordHidden.value
                                      ? Icon(
                                    Icons.visibility_outlined,
                                    size: 18,
                                  )
                                      : Icon(
                                    Icons.visibility_off_outlined,
                                    size: 18,
                                  ),
                                ),
                              ),
                              maxLines: 1,
                              inputFormatters: [
                                AppInputFormatters.limitedText(maxLength: 100),
                                AppInputFormatters.lettersNumbersSymbolsFormat
                              ],
                              validator: AppValidators.confirmPassword,
                              hint: AppStrings.confirmPassword,
                              controller:
                              controller.confirmPasswordController,
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.alreadyHaveAnAccount,
                                    style: bodyText16.copyWith(
                                      height: 1.6,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.login,
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
                                if (controller.formKey.currentState!
                                    .validate()) {
                                  if (controller.passwordController.text !=
                                      controller
                                          .confirmPasswordController
                                          .text) {
                                    SnackBarWidget.show(
                                      context,
                                      message: AppStrings.passwordMatch,
                                      contentType: ContentType.warning,
                                    );
                                  } else {
                                    FocusScope.of(context).unfocus();
                                    await controller.signupApi(context);
                                  }
                                }
                              },
                              label: AppStrings.register,
                            ),
                            const SizedBox(height: 32),
                          ],
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
                  child: LoadingWidget.loader(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
