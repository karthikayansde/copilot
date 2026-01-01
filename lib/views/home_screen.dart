import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iMirAI/utils/app_strings.dart';
import '../controller/home_controller.dart';
import '../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/iMirAI-Logo1.png', height: 65, width: 65),
                      SizedBox(width: 12,),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'New Chat',
                      onTap: () {
                        Get.back();
                        // Logic for new chat if needed
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.black.withOpacity(0.05), height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isDestructive: true,
                  onTap: () => controller.logout(context),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                Expanded(
                  child: Obx(() {
                    if (controller.messages.isEmpty) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 12,),
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/images/iMirAI-Logo1.png', height: 75, width: 75),
                                    SizedBox(width: 12,),
                                    const Text(
                                      AppStrings.appName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildSuggestionChip(controller, 'Analyze Data', Icons.assessment_outlined),
                                  _buildSuggestionChip(controller, 'Get Insights', Icons.lightbulb_outline),
                                  _buildSuggestionChip(controller, 'Ask Questions', Icons.help_outline),
                                  _buildSuggestionChip(controller, 'Generate Reports', Icons.description_outlined),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
      
                    return Padding(
                      padding: const EdgeInsets.only(top:55.0),
                      child: ListView.separated(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: controller.messages.length + (controller.isLoading.value ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == controller.messages.length) {
                            return _buildLoadingMessage();
                          }

                          final message = controller.messages[index];
                          return _buildMessage(context, message, controller);
                        },
                      ),
                    );
                  }),
                ),
                _buildInputArea(context, controller),
              ],
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/iMirAI-Logo1.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildSuggestionChip(dynamic controller, String label, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.addSuggestion(label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(right: 80),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.black.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Analyzing...',
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, dynamic message, dynamic controller) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              height: 37,
              width: 37,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: Text("AI", style: TextStyle(color: AppColors.white,fontSize: 16, fontWeight: FontWeight.bold),)),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  margin: EdgeInsets.only(
                    left: isUser ? 80 : 0,
                    right: isUser ? 0 : 80,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black, Color(0xFF2D2D2D)],
                    )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUser
                          ? Colors.black
                          : Colors.black.withOpacity(0.1),
                      width: isUser ? 0 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isUser ? 0.12 : 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.6,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      : Html(
                    data: message.text,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(15),
                        color: Colors.black87,
                        lineHeight: const LineHeight(1.7),
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 12),
                        color: Colors.black87,
                      ),
                      "code": Style(
                        backgroundColor: Colors.black.withOpacity(0.05),
                        color: Colors.black,
                        padding: HtmlPaddings.all(4),
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                      "pre": Style(
                        backgroundColor: Colors.black.withOpacity(0.04),
                        padding: HtmlPaddings.all(12),
                        margin: Margins.symmetric(vertical: 8),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    },
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionIcon(Icons.content_copy_rounded, () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          Get.snackbar(
                            'Copied',
                            'Message copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 1),
                            margin: const EdgeInsets.all(15),
                            borderRadius: 15,
                          );
                        }),
                        const SizedBox(width: 4),
                        _buildActionIcon(Icons.refresh_outlined, () {}),
                        const SizedBox(width: 4),
                        _buildActionIcon(Icons.thumb_up_outlined, () => _showFeedbackDialog(context)),
                        const SizedBox(width: 4),
                        _buildActionIcon(Icons.thumb_down_outlined, () => _showNegativeFeedbackDialog(context)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            Container(
              height: 37,
              width: 37,
              margin: const EdgeInsets.only(left: 12, top: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Center(child: Icon(Icons.person_outline, color: Colors.black.withOpacity(0.7), size: 16)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, dynamic controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white,
            Colors.white,
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withOpacity(0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 60,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => controller.selectedSuggestions.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedSuggestions.map<Widget>((suggestion) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => controller.removeSuggestion(suggestion),
                                child: Icon(
                                  Icons.cancel,
                                  size: 14,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink()),
            Obx(
              () => TextField(
            controller: controller.searchController,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              letterSpacing: 0.1,
              fontWeight: FontWeight.w500,
            ),
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Ask anything...',
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.35),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 6),
                child: IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.black.withOpacity(0.4),
                    size: 24,
                  ),
                  onPressed: () {},
                  tooltip: 'Attach',
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: controller.isListening.value
                            ? Colors.red.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          controller.isListening.value ? Icons.mic : Icons.mic_none_outlined,
                          color: controller.isListening.value
                              ? Colors.red
                              : controller.speechEnabled.value
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black.withOpacity(0.25),
                          size: 24,
                        ),
                        onPressed: controller.speechEnabled.value
                            ? (controller.isListening.value
                            ? controller.stopListening
                            : controller.startListening)
                            : null,
                        tooltip: controller.isListening.value
                            ? 'Stop listening'
                            : 'Start voice',
                      ),
                    ),
                    Obx(
                          () => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: controller.hasText.value
                              ? const LinearGradient(
                            colors: [Colors.black, Color(0xFF2D2D2D)],
                          )
                              : null,
                          color: controller.hasText.value
                              ? null
                              : Colors.black.withOpacity(0.06),
                          shape: BoxShape.circle,
                          boxShadow: controller.hasText.value
                              ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_upward_rounded,
                            color: controller.hasText.value
                                ? Colors.white
                                : Colors.black.withOpacity(0.3),
                            size: 22,
                          ),
                          onPressed: controller.hasText.value
                              ? () async {
                            await controller.sendMessage(context);
                          }
                              : null,
                          tooltip: 'Send message',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 16,
              ),
            ),
          ),
        ),]
      ),
    ));
  }

  void _showNegativeFeedbackDialog(BuildContext context) {
    double rating = 30.0;
    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();
    final List<String> reasons = [
      'Incorrect information',
      'Incomplete answer',
      'Irrelevant response',
      'Formatting issue',
      'Too generic',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: Colors.black.withOpacity(0.3)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Text(
                    'What went wrong?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your feedback helps improve future answers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${rating.toInt()}%',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: rating < 30 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF334155),
                      inactiveTrackColor: const Color(0xFFE2E8F0),
                      thumbColor: const Color(0xFF334155),
                      overlayColor: const Color(0xFF334155).withOpacity(0.12),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: rating,
                      min: 0,
                      max: 49,
                      onChanged: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReason,
                        hint: Text(
                          'Select a reason',
                          style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 15),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more_rounded),
                        items: reasons.map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason, style: const TextStyle(fontSize: 15)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                      ),
                    ),
                  ),
                  if (selectedReason == 'Other') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: TextField(
                        controller: otherReasonController,
                        maxLines: 2,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Please describe the issue',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 15),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (selectedReason == null || 
                                  (selectedReason == 'Other' && otherReasonController.text.trim().isEmpty))
                            ? null
                            : () {
                                Navigator.pop(context);
                                Get.snackbar(
                                  'Thank You!',
                                  'Feedback received. We will look into it.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.black87,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(15),
                                  borderRadius: 15,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          disabledBackgroundColor: const Color(0xFF1E293B).withOpacity(0.2),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit feedback',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    double rating = 80.0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: Colors.black.withOpacity(0.3)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Text(
                  'How helpful was this response?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your feedback helps improve future answers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '${rating.toInt()}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: rating < 70 ? const Color(0xFFF59E0B) : const Color(0xFF0D9488),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 24),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF334155),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF334155),
                    overlayColor: const Color(0xFF334155).withOpacity(0.12),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: rating,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.snackbar(
                          'Thank You!',
                          'Your feedback has been submitted.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(15),
                          borderRadius: 15,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            size: 16,
            color: Colors.black.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDestructive ? Colors.red.withOpacity(0.05) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDestructive ? Colors.red.shade700 : Colors.black87,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red.shade700 : Colors.black87,
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