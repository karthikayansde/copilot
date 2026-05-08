import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/styles.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import '../utils/app_input_formatters.dart';
import '../utils/app_strings.dart';
import '../utils/app_validators.dart';
import '../widgets/button_widgets.dart';
import '../widgets/loading_widget.dart';
import '../widgets/snack_bar_widget.dart';
import '../widgets/text_field_widgets.dart';

class ResendActivationView extends StatefulWidget {
  final String? initialUsername;
  final String? initialPassword;

  const ResendActivationView({
    super.key,
    this.initialUsername,
    this.initialPassword,
  });

  @override
  State<ResendActivationView> createState() => _ResendActivationViewState();
}

class _ResendActivationViewState extends State<ResendActivationView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _isPasswordHidden = true.obs;
  final _isLoading = false.obs;
  final _isSuccess = false.obs;
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.initialUsername ?? '';
    _passwordController.text = widget.initialPassword ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resendActivation() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    _isLoading.value = true;
    _isSuccess.value = false;

    try {
      await resendActivationApi(context);
      _isSuccess.value = true;
    } catch (e) {
      SnackBarWidget.showError(context);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                      key: _formKey,
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
                                AppStrings.resendActivationLink,
                                style: text28Bold.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter your credentials to resend the link',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Username field
                              TextFieldWidget(
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
                                ],
                                validator: AppValidators.userName,
                                hint: AppStrings.userName,
                                controller: _usernameController,
                              ),
                              const SizedBox(height: 4),
                              // Password field
                              TextFieldWidget(
                                isBorderNeeded: true,
                                hasHindOnTop: true,
                                isPassword: _isPasswordHidden.value,
                                suffixIcon: InkWell(
                                  onTap: () => _isPasswordHidden.toggle(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(
                                      _isPasswordHidden.value
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
                                ],
                                validator: AppValidators.password,
                                hint: AppStrings.password,
                                controller: _passwordController,
                              ),

                              const SizedBox(height: 16),

                              // Success message banner
                              if (_isSuccess.value) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          AppStrings.activationLinkSentSuccess,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              const SizedBox(height: 8),

                              // Resend activation link button
                              BasicButtonWidget(
                                onPressed: _resendActivation,
                                label: AppStrings.resendActivationLink,
                              ),

                              const SizedBox(height: 24),

                              // Back to login link
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
                                          TextSpan(text: AppStrings.rememberPassword),
                                          const TextSpan(text: ' '),
                                          TextSpan(
                                            text: AppStrings.backToLogin,
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
              if (_isLoading.value)
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
    );
  }

  Future<void> resendActivationApi(BuildContext context) async {
    try {
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        customUrl: true,
        useFormData: true,
        endpoint: Endpoints.registerBaseUrl + Endpoints.resendActivation,
        body: {
          "username": _usernameController.text,
          "password": _passwordController.text,
        },
      );

      if (response.code == ApiCode.notFound404.index) {
        if (response.data['detail'] == "INCORRECT USERNAME") {
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Incorrect Username",
            contentType: ContentType.warning,
          );
          return;
        }
      }
      if (response.code == ApiCode.unauthorized401.index) {
        if (response.data['detail'] == "INCORRECT PASSWORD") {
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Incorrect Password",
            contentType: ContentType.warning,
          );
          return;
        }
      }
      if (response.code == ApiCode.error400.index) {
        if (response.data['detail'] == "ACCOUNT ALREADY ACTIVATED") {
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Account already activated",
            contentType: ContentType.warning,
          );
          return;
        }
      }
      if (response.code == ApiCode.forbidden403.index) {
        if (response.data['detail'] == "APPROVAL REJECTED") {
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Approval Rejected",
            contentType: ContentType.warning,
          );
          return;
        } else if (response.data['detail'] == "APPROVAL PENDING") {
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Approval Pending",
            contentType: ContentType.warning,
          );
          return;
        }
      }
      SnackBarWidget.show(
        context,
        title: "Success",
        message: "Activation link sent! Please check your email.",
        contentType: ContentType.success,
      );
    } catch (e) {
      SnackBarWidget.showError(context);
    }
  }
}