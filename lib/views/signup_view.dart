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
    super.initState();
    controller.nameController.text = "";
    controller.userNameController.text = "";
    controller.emailController.text = "";
    controller.passwordController.text = "";
    controller.confirmPasswordController.text = "";
    controller.otherOrgNameController.text = "";
    controller.selectedOrganization.value = "Select organization";
    controller.selectedAdmin.value = "Select referring admin";
    controller.isPasswordHidden.value = true;
    controller.isConfirmPasswordHidden.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.primary.withOpacity(0.05),
                colorScheme.surface,
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
                          elevation: 0,
                          color: colorScheme.surface.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                            side: BorderSide(
                              color: colorScheme.outlineVariant.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 8),
                                Center(
                                  child: Image.asset(
                                    'assets/images/iMirAI-Logo1.png',
                                    height: 50,
                                    width: 180,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  AppStrings.register,
                                  style: text28Bold.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your account to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                TextFieldWidget(
                                  key: const ValueKey('1'),
                                  isBorderNeeded: true,
                                  hasHindOnTop: true,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 20,
                                      color: colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  maxLines: 1,
                                  inputFormatters: [
                                    AppInputFormatters.limitedText(maxLength: 50)
                                  ],
                                  validator: AppValidators.name,
                                  controller: controller.nameController,
                                  hint: AppStrings.name,
                                ),
                                const SizedBox(height: 4),
                                TextFieldWidget(
                                  key: const ValueKey('2'),
                                  isBorderNeeded: true,
                                  hasHindOnTop: true,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(
                                      Icons.alternate_email_rounded,
                                      size: 20,
                                      color: colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  maxLines: 1,
                                  inputFormatters: [
                                    AppInputFormatters.limitedText(maxLength: 50),
                                    AppInputFormatters.noSpaceFormat,
                                  ],
                                  validator: AppValidators.userName,
                                  hint: AppStrings.userName,
                                  controller: controller.userNameController,
                                ),
                                const SizedBox(height: 4),
                                TextFieldWidget(
                                  isBorderNeeded: true,
                                  hasHindOnTop: true,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(
                                      Icons.email_outlined,
                                      size: 20,
                                      color: colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  maxLines: 1,
                                  validator: AppValidators.email,
                                  hint: AppStrings.email,
                                  controller: controller.emailController,
                                ),
                                const SizedBox(height: 4),
                                TextFieldWidget(
                                  isBorderNeeded: true,
                                  hasHindOnTop: true,
                                  isPassword: controller.isPasswordHidden.value,
                                  suffixIcon: InkWell(
                                    onTap: () => controller.isPasswordHidden.toggle(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(
                                        controller.isPasswordHidden.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  maxLines: 1,
                                  inputFormatters: [
                                    AppInputFormatters.limitedText(maxLength: 100),
                                    AppInputFormatters.lettersNumbersSymbolsFormat,
                                    AppInputFormatters.noSpaceFormat,
                                  ],
                                  validator: AppValidators.password,
                                  hint: AppStrings.password,
                                  controller: controller.passwordController,
                                ),
                                const SizedBox(height: 4),
                                TextFieldWidget(
                                  isBorderNeeded: true,
                                  hasHindOnTop: true,
                                  isPassword: controller.isConfirmPasswordHidden.value,
                                  suffixIcon: InkWell(
                                    onTap: () => controller.isConfirmPasswordHidden.toggle(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(
                                        controller.isConfirmPasswordHidden.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  maxLines: 1,
                                  inputFormatters: [
                                    AppInputFormatters.limitedText(maxLength: 100),
                                    AppInputFormatters.lettersNumbersSymbolsFormat,
                                    AppInputFormatters.noSpaceFormat,
                                  ],
                                  validator: AppValidators.confirmPassword,
                                  hint: AppStrings.confirmPassword,
                                  controller: controller.confirmPasswordController,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.selectOrganization,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => DropdownButtonFormField<String>(
                                    value: controller.selectedOrganization.value,
                                    elevation: 8,
                                    dropdownColor: colorScheme.surface,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                      color: colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value == controller.organizations[0]) {
                                        return AppStrings.selectOrganization;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.onSurface.withOpacity(0.03),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.outlineVariant.withOpacity(0.5),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: colorScheme.error),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
                                      ),
                                    ),
                                    items: controller.organizations.map((String org) {
                                      return DropdownMenuItem<String>(
                                        value: org,
                                        child: Text(org),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        controller.selectedOrganization.value = newValue;
                                        if (newValue == "PiLog") {
                                          controller.otherOrgNameController.clear();
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(() {
                                  if (controller.selectedOrganization.value == "Others") {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFieldWidget(
                                          isBorderNeeded: true,
                                          hasHindOnTop: true,
                                          maxLines: 1,
                                          validator: AppValidators.organizationName,
                                          controller: controller.otherOrgNameController,
                                          hint: AppStrings.organizationName,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppStrings.selectReferringAdmin,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface.withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: controller.selectedAdmin.value,
                                          elevation: 8,
                                          dropdownColor: colorScheme.surface,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 20,
                                            color: colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onSurface,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value == "Select referring admin") {
                                              return AppStrings.referringAdminValidator;
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            filled: true,
                                            fillColor: colorScheme.onSurface.withOpacity(0.03),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: colorScheme.outlineVariant.withOpacity(0.5),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: colorScheme.primary,
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(color: colorScheme.error),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
                                            ),
                                          ),
                                          items: controller.referringAdmins.map((String admin) {
                                            return DropdownMenuItem<String>(
                                              value: admin,
                                              child: Text(admin),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              controller.selectedAdmin.value = newValue;
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                                const SizedBox(height: 24),
                                BasicButtonWidget(
                                  onPressed: () async {
                                    if (controller.formKey.currentState!.validate()) {
                                      if (controller.passwordController.text !=
                                          controller.confirmPasswordController.text) {
                                        SnackBarWidget.show(
                                          context,
                                          message: AppStrings.passwordMatch,
                                          contentType: ContentType.warning,
                                        );
                                        return;
                                      }
                                      if (controller.selectedOrganization.value == "PiLog") {
                                        if (!controller.emailController.text
                                            .toLowerCase()
                                            .contains("piloggroup")) {
                                          SnackBarWidget.show(
                                            context,
                                            title: "Invalid Email",
                                            message: "Please enter a valid Pilog email.",
                                            contentType: ContentType.warning,
                                          );
                                          return;
                                        }
                                      }
                                      FocusScope.of(context).unfocus();
                                      await controller.signupApi(context);
                                    }
                                  },
                                  label: AppStrings.register,
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.onSurface.withOpacity(0.7),
                                          ),
                                          children: [
                                            TextSpan(text: AppStrings.alreadyHaveAnAccount),
                                            const TextSpan(text: ' '),
                                            TextSpan(
                                              text: AppStrings.login,
                                              style: TextStyle(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                      color: colorScheme.surface.withOpacity(0.6),
                      child: LoadingWidget.loader(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}