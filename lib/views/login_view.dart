import '../utils/app_strings.dart';
import '../views/signup_view.dart';
import '../views/resend_activation_view.dart';
import '../views/forgot_password_view.dart';
import '../widgets/button_widgets.dart';
import '../widgets/text_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../core/theme/styles.dart';
import '../utils/app_input_formatters.dart';
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
    super.initState();
    controller = Get.put(LoginController());
    controller.usernameController.text = "";
    controller.emailController.text = "";
    controller.passwordController.text = "";
    controller.isPasswordHidden.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: cs.surfaceContainerLow,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface,
              cs.surfaceContainerLow,
              cs.surface,
            ],
          ),
        ),
        child: Obx(
          () => Stack(
            children: [
              Center(
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: controller.formKey,
                    child: Card(
                      color: cs.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/iMirAI-Logo1.png',
                                  height: 50,
                                  width: 180,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Login",
                                  style: text28Bold.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Username field
                              TextFieldWidget(
                                isBorderNeeded: true,
                                hasHindOnTop: true,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 8),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 18,
                                    color: cs.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                maxLines: 1,
                                inputFormatters: [
                                  AppInputFormatters.limitedText(maxLength: 50),
                                  AppInputFormatters.noSpaceFormat,
                                ],
                                validator: (value) {
                                  if (controller.emailController.text.trim().isEmpty &&
                                      (value == null || value.trim().isEmpty)) {
                                    return "Please enter username or email";
                                  }
                                  if (value != null && value.trim().isNotEmpty) {
                                    if (value.contains(' ')) {
                                      return AppStrings.userNameSpaceValidator;
                                    }
                                  }
                                  return null;
                                },
                                hint: "your.username",
                                header: AppStrings.userName.toUpperCase(),
                                controller: controller.usernameController,
                              ),

                              // OR Divider
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: cs.outlineVariant,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Text(
                                        "OR",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: cs.outlineVariant,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Email field
                              TextFieldWidget(
                                isBorderNeeded: true,
                                hasHindOnTop: true,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 8),
                                  child: Icon(
                                    Icons.mail_outline,
                                    size: 18,
                                    color: cs.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                maxLines: 1,
                                inputFormatters: [
                                  AppInputFormatters.limitedText(maxLength: 100),
                                  AppInputFormatters.noSpaceFormat,
                                ],
                                validator: (value) {
                                  if (controller.usernameController.text.trim().isEmpty &&
                                      (value == null || value.trim().isEmpty)) {
                                    return "Please enter username or email";
                                  }
                                  if (value != null && value.trim().isNotEmpty) {
                                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return AppStrings.emailValidator;
                                    }
                                  }
                                  return null;
                                },
                                hint: "you@company.com",
                                header: AppStrings.email.toUpperCase(),
                                controller: controller.emailController,
                              ),

                              // Password field
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
                                        left: 10, right: 10),
                                    child: Icon(
                                      controller.isPasswordHidden.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 18,
                                      color: cs.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                maxLines: 1,
                                inputFormatters: [
                                  AppInputFormatters.limitedText(
                                      maxLength: 100),
                                  AppInputFormatters.lettersNumbersSymbolsFormat,
                                  AppInputFormatters.noSpaceFormat,
                                ],
                                hint: AppStrings.password,
                                controller: controller.passwordController,
                              ),

                              const SizedBox(height: 15),

                              // Register link
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SignupView()),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.dontHaveAnAccount,
                                      style: bodyText16.copyWith(
                                        height: 1.6,
                                        color: cs.onSurface.withOpacity(0.7),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.register,
                                      style: bodyText16.copyWith(
                                        fontWeight: FontWeight.w700,
                                        height: 1.6,
                                        color: cs.primary,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Forgot password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPasswordView(
                                        initialUsername: controller
                                                .usernameController
                                                .text
                                                .isNotEmpty
                                            ? controller
                                                .usernameController.text
                                            : controller.emailController.text,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.forgotPassword,
                                    style: bodyText16.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Login button
                              BasicButtonWidget(
                                onPressed: () async {
                                  if (controller.formKey.currentState!
                                      .validate()) {
                                    FocusScope.of(context).unfocus();
                                    await controller.loginApi(context);
                                  }
                                },
                                label: AppStrings.login,
                              ),

                              // Account not activated banner
                              if (controller.showResendButton.value) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.errorContainer,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: cs.error,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: cs.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              AppStrings.accountNotActivated,
                                              style: bodyText14.copyWith(
                                                color: cs.onErrorContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 28),
                                        child: InkWell(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ResendActivationView(
                                                    initialUsername: controller
                                                            .usernameController
                                                            .text
                                                            .isNotEmpty
                                                        ? controller
                                                            .usernameController
                                                            .text
                                                        : controller
                                                            .emailController
                                                            .text,
                                                    initialPassword: controller
                                                        .passwordController.text,
                                                  ),
                                            ),
                                          ),
                                          child: Text(
                                            AppStrings.resendActivationLink,
                                            style: bodyText14.copyWith(
                                              color: cs.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                              TextDecoration.underline,
                                              decorationColor: cs.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),),

            // Loading overlay
            if (controller.isLoading.value)
              Positioned.fill(
                child: Container(
                  color: cs.surface.withOpacity(0.6),
                  child: LoadingWidget.loader(),
                ),
              ),
          ],
        ),
      ),
    ));
  }
}