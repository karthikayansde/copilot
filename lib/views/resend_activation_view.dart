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
                                  AppStrings.resendActivationLink,
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
                                    Icons.person_2_outlined,
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

                              // Password field
                              TextFieldWidget(
                                isBorderNeeded: true,
                                hasHindOnTop: true,
                                isPassword: _isPasswordHidden.value,
                                suffixIcon: InkWell(
                                  onTap: () {
                                    _isPasswordHidden.value =
                                        !_isPasswordHidden.value;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: _isPasswordHidden.value
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
                                  AppInputFormatters.lettersNumbersSymbolsFormat,
                                ],
                                validator: AppValidators.password,
                                hint: AppStrings.password,
                                controller: _passwordController,
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
                                          AppStrings.activationLinkSentSuccess,
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

                              // Resend activation link button
                              BasicButtonWidget(
                                onPressed: _resendActivation,
                                label: AppStrings.resendActivationLink,
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
                                      AppStrings.rememberPassword,
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
  Future<void> resendActivationApi(BuildContext context) async {
    try {
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        customUrl: true,
        useFormData: true,
        endpoint: Endpoints.registerBaseUrl + Endpoints.resendActivation,
        body: {"username": _usernameController.text, "password": _passwordController.text},
      );

      if(response.code == ApiCode.notFound404.index){
        if(response.data['detail'] == "INCORRECT USERNAME"){
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Incorrect Username",
            contentType: ContentType.warning,
          );
          return;
        }
      }
      if(response.code == ApiCode.unauthorized401.index){
        if(response.data['detail'] == "INCORRECT PASSWORD"){
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Incorrect Password",
            contentType: ContentType.warning,
          );
          return;
        }
      }
      if(response.code == ApiCode.error400.index){
        if(response.data['detail'] == "ACCOUNT ALREADY ACTIVATED"){
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Account already activated",
            contentType: ContentType.warning,
          );
          return;
        }
      }
      if(response.code == ApiCode.forbidden403.index){
        if(response.data['detail'] == "APPROVAL REJECTED"){
          SnackBarWidget.show(
            context,
            title: AppStrings.warning,
            message: "Approval Rejected",
            contentType: ContentType.warning,
          );
          return;
        }else if(response.data['detail'] == "APPROVAL PENDING"){
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
