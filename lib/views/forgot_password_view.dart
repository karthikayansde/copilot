import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class ForgotPasswordView extends StatefulWidget {
  final String? initialUsername;

  const ForgotPasswordView({
    super.key,
    this.initialUsername,
  });

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final _isLoading = false.obs;
  final _isSuccess = false.obs;
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.initialUsername ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> forgotPasswordApi(BuildContext context) async {
    try {
      _isLoading.value = true;
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        customUrl: true,
        useFormData: true,
        endpoint: Endpoints.registerBaseUrl + Endpoints.forgotPassword,
        body: {"user_name": _usernameController.text},
      );
        if(response.code == ApiCode.notFound404.index) {
          if (response.data['detail'] == "USERNAME NOT REGISTERED") {
            SnackBarWidget.show(
              context,
              title: AppStrings.warning,
              message: "Username not registered",
              contentType: ContentType.warning,
            );
            return;
          }
        }
      _isSuccess.value = true;
    } catch (e) {
      SnackBarWidget.showError(context);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    _isSuccess.value = false;

    await forgotPasswordApi(context);
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
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
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/iMirAI-Logo1.png',
                                  height: 50,
                                  width: 180,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppStrings.forgotPasswordTitle,
                                  style: text28Bold.copyWith(fontSize: 24),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Username field
                              TextFieldWidget(
                                isBorderNeeded: true,
                                hasHindOnTop: true,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 18,
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

                              const SizedBox(height: 15),

                              // Success message banner
                              if (_isSuccess.value) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF4CAF50),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: const Color(0xFF4CAF50),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          AppStrings.resetLinkSentSuccess,
                                          style: bodyText14.copyWith(
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],

                              const SizedBox(height: 15),

                              // Send reset link button
                              BasicButtonWidget(
                                onPressed: _sendResetLink,
                                label: AppStrings.sendResetLink,
                              ),

                              const SizedBox(height: 20),

                              // Back to login link
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.rememberedPassword,
                                      style: bodyText16.copyWith(
                                        height: 1.6,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppStrings.backToLogin,
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
                              const SizedBox(height: 16),
                            ],
                          ),
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
