import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../core/theme/app_colors.dart';
import '../utils/app_utils.dart';
import '../widgets/loading_widget.dart';
import '../widgets/popover_dialog.dart';
import '../services/download_service.dart';

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
          child: Stack(
            children: [
              Column(
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
                      child: Image.asset(
                        'assets/images/iMirAI-Logo1.png',
                        height: 50,
                        width: 180,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildDrawerItem(
                      icon: Icons.add_comment_outlined,
                      label: 'New Conversation',
                      onTap: () {
                        Navigator.pop(context);
                        controller.startNewChat();
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                    child: Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: Text(
                        'Your Conversations',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withOpacity(0.4),
                          letterSpacing: 1.2,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => controller.getSessionsApi(),
                      child: Obx(() {
                        return ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            if (controller.sessionsList.value.sessions != null)
                              ...controller.sessionsList.value.sessions!.map((
                                session,
                              ) {
                                return _buildDrawerItem(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: session.title ?? 'Untitled Chat',
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (session.sessionId != null) {
                                      controller.getSessionChatsApi(
                                        session.sessionId!,
                                      );
                                    }
                                  },
                                  onLongPress: () => _showSessionOptions(
                                    context,
                                    session,
                                    controller,
                                  ),
                                );
                              }).toList(),
                          ],
                        );
                      }),
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
              Obx(
                () => controller.isSessionsLoading.value
                    ? Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.shadowMedium,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: LoadingWidget.loader(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50, Colors.white],
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
                                  SizedBox(height: 12),
                                  Center(
                                    child: Image.asset(
                                      'assets/images/iMirAI-Logo1.png',
                                      height: 50,
                                      width: 180,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _buildSuggestionChip(
                                        controller,
                                        0,
                                        Icons.psychology,
                                        context
                                      ),
                                      _buildSuggestionChip(
                                        controller,
                                        1,
                                        Icons.shopping_cart_checkout,
                                          context
                                      ),
                                      _buildSuggestionChip(
                                        controller,
                                        2,
                                        Icons.lightbulb_outline,
                                          context
                                      ),
                                      _buildSuggestionChip(
                                        controller,
                                        3,
                                        Icons.description_outlined,
                                          context
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 20,
                            top: 60,
                          ),
                          itemCount:
                              controller.messages.length +
                              (controller.isLoading.value ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == controller.messages.length) {
                              return _buildLoadingMessage();
                            }
                            return _buildMessage(
                              context,
                              controller.messages[index],
                              controller,
                              index,
                            );
                          },
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
                          'assets/images/logo_small.png',
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () =>
                      controller.isLoading.value && controller.messages.isEmpty
                      ? Positioned.fill(
                          child: Container(
                            color: AppColors.shadowMedium,
                            child: LoadingWidget.loader(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    dynamic controller,
    int labelIndex,
    IconData icon,
      BuildContext context
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: labelIndex == 2
            ? () => controller.pickAndProcessFile(context)
            : () => controller.addSuggestion(
                controller.searchOptions[labelIndex],
              ),
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
                controller.searchOptions[labelIndex],
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
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1.5),
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

  Widget _buildMessage(
    BuildContext context,
    dynamic message,
    dynamic controller,
    int index,
  ) {
    final isUser = message.isUser;

    if (!isUser) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 37,
            width: 37,
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
            child: Center(
              child: Text(
                "AI",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            child: message.isLoading == true
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Reloading...",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildHtmlWithDownloadSupport(context, message.text),
          ),
          if (message.isLoading != true) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionIcon(Icons.content_copy_rounded, () {
                    Clipboard.setData(
                      ClipboardData(text: AppUtils.stripHtml(message.text)),
                    );
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
                  SizedBox(width: !message.hasRefresh?0:4),
                  !message.hasRefresh?SizedBox():_buildActionIcon(
                    Icons.refresh_outlined,
                    () => controller.reloadMessage(context, index),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIcon(
                    Icons.thumb_up_outlined,
                    message.feedbackStatus == null
                        ? () {
                            final String question = index > 0
                                ? (controller.messages[index - 1].isUser
                                      ? controller.messages[index - 1].text
                                      : "")
                                : "";
                            _showFeedbackDialog(
                              context,
                              question,
                              controller,
                              index,
                            );
                          }
                        : null,
                    isSelected: message.feedbackStatus == 'liked',
                    isDisabled:
                        message.feedbackStatus != null &&
                        message.feedbackStatus != 'liked',
                  ),
                  const SizedBox(width: 4),
                  _buildActionIcon(
                    Icons.thumb_down_outlined,
                    message.feedbackStatus == null
                        ? () {
                            final String question = index > 0
                                ? (controller.messages[index - 1].isUser
                                      ? controller.messages[index - 1].text
                                      : "")
                                : "";
                            _showNegativeFeedbackDialog(
                              context,
                              question,
                              controller,
                              index,
                            );
                          }
                        : null,
                    isSelected: message.feedbackStatus == 'disliked',
                    isDisabled:
                        message.feedbackStatus != null &&
                        message.feedbackStatus != 'disliked',
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black, Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.6,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Container(
            height: 37,
            width: 37,
            margin: const EdgeInsets.only(left: 12, top: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryIcon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryIcon,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                'U',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, dynamic controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.0), Colors.white, Colors.white],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.15), width: 2),
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
            Obx(
              () => controller.selectedSuggestions.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedSuggestions.map<Widget>((
                          suggestion,
                        ) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
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
                                  onTap: () =>
                                      controller.removeSuggestion(suggestion),
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
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => TextField(
                readOnly: controller.isLoading.value,
                controller: controller.searchController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.35),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Builder(
                    builder: (buttonContext) => Container(
                      margin: const EdgeInsets.only(left: 6),
                      child: IconButton(
                        icon: Icon(
                          Icons.attach_file_rounded,
                          color: Colors.black.withOpacity(0.4),
                          size: 24,
                        ),
                        onPressed: () => _showAttachPopover(context, buttonContext),
                        tooltip: 'Attach',
                      ),
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!controller.isListening.value)
                        IconButton(
                          icon: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.black.withOpacity(0.4),
                            size: 24,
                          ),
                          onPressed: () => controller.scanQRCode(context),
                          tooltip: 'Scan QR Code',
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: controller.isLoading.value
                                ? Colors.grey
                                : controller.isListening.value
                                ? Colors.red
                                : Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: controller.hasText.value
                                ? Icon(
                                    Icons.arrow_upward_rounded,
                                    color: controller.hasText.value
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.3),
                                    size: 22,
                                  )
                                : Image.asset(
                                    "assets/images/mic_icon.png",
                                    width: 24,
                                    height: 24,
                                  ),
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.hasText.value
                                ? () async {
                                    FocusScope.of(context).unfocus();
                                    await controller.sendMessage(context);
                                  }
                                : controller.speechEnabled.value
                                ? (controller.isListening.value
                                      ? controller.stopListening
                                      : controller.startListening)
                                : null,
                            tooltip: controller.hasText.value
                                ? 'Send message'
                                : controller.isListening.value
                                ? 'Stop listening'
                                : 'Start voice',
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
            ),
          ],
        ),
      ),
    );
  }

  void _showNegativeFeedbackDialog(
    BuildContext context,
    String question,
    dynamic controller,
    int messageIndex,
  ) {
    double rating = 30.0;
    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();
    final List<String> reasons = [
      'Incorrect Information',
      'Incomplete Answer',
      'Irrelevant Response',
      'Formatting Issue',
      'Too Generic',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(stateContext),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Text(
                    'What went wrong?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
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
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${rating.toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: rating < 30
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
                      letterSpacing: -1,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(stateContext).copyWith(
                      activeTrackColor: const Color(0xFF334155),
                      inactiveTrackColor: const Color(0xFFE2E8F0),
                      thumbColor: const Color(0xFF334155),
                      overlayColor: const Color(0xFF334155).withOpacity(0.12),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                        elevation: 3,
                      ),
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
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReason,
                        hint: Text(
                          'Select a reason',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 13,
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more_rounded),
                        items: reasons.map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(
                              reason,
                              style: const TextStyle(fontSize: 13),
                            ),
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
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: otherReasonController,
                        maxLines: 2,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Please describe the issue',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(stateContext),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed:
                            (selectedReason == null ||
                                (selectedReason == 'Other' &&
                                    otherReasonController.text.trim().isEmpty))
                            ? null
                            : () async {
                                Navigator.pop(stateContext);
                                bool success = await controller.saveFeedbackApi(
                                  context: context,
                                  question: question,
                                  isThumbsUp: false,
                                  percentage: rating,
                                  messageIndex: messageIndex,
                                  reason: selectedReason == 'Other'
                                      ? otherReasonController.text
                                      : selectedReason,
                                );
                                if (success && context.mounted) {
                                  _showThankYouDialog(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          disabledBackgroundColor: const Color(
                            0xFF1E293B,
                          ).withOpacity(0.2),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withOpacity(
                            0.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit feedback',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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

  void _showFeedbackDialog(
    BuildContext context,
    String question,
    dynamic controller,
    int messageIndex,
  ) {
    double rating = 80.0;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(stateContext),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Text(
                  'How helpful was this response?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
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
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${rating.toInt()}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: rating < 70
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF0D9488),
                    letterSpacing: -1,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(stateContext).copyWith(
                    activeTrackColor: const Color(0xFF334155),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF334155),
                    overlayColor: const Color(0xFF334155).withOpacity(0.12),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                      elevation: 3,
                    ),
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(stateContext),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(stateContext);
                        bool success = await controller.saveFeedbackApi(
                          context: context,
                          question: question,
                          isThumbsUp: true,
                          percentage: rating,
                          messageIndex: messageIndex,
                          reason: null,
                        );
                        if (success && context.mounted) {
                          _showThankYouDialog(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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

  Widget _buildActionIcon(
    IconData icon,
    VoidCallback? onTap, {
    bool isSelected = false,
    bool isDisabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            isSelected
                ? (icon == Icons.thumb_up_outlined
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_down_rounded)
                : icon,
            size: 16,
            color: isSelected
                ? (icon == Icons.thumb_up_outlined ? Colors.green : Colors.red)
                : (isDisabled
                      ? Colors.black.withOpacity(0.1)
                      : Colors.black.withOpacity(0.4)),
          ),
        ),
      ),
    );
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF94A3B8).withOpacity(0.5),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('🙏', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text(
                  'Thank you!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your feedback has been recorded',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSessionOptions(
    BuildContext context,
    dynamic session,
    dynamic controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chat Options',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.black.withOpacity(0.05)),
              _buildDialogOption(
                icon: Icons.edit_outlined,
                label: 'Edit Name',
                onTap: () {
                  Navigator.pop(context);
                  _showEditSessionDialog(context, session, controller);
                },
              ),
              _buildDialogOption(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Chat',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, session, controller);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.red.shade600 : Colors.black87,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red.shade600 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSessionDialog(
    BuildContext context,
    dynamic session,
    dynamic controller,
  ) {
    final TextEditingController editController = TextEditingController(
      text: session.title,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Chat Title'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Enter new title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newTitle = editController.text.trim();
              if (newTitle.isNotEmpty) {
                Navigator.pop(context);
                controller.editSessionTitleApi(
                  context,
                  session.sessionId,
                  newTitle,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    dynamic session,
    dynamic controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Chat?'),
        content: const Text(
          'Are you sure you want to delete this chat history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              controller.deleteSessionApi(context, session.sessionId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlWithDownloadSupport(BuildContext context, String htmlData) {
    // Try to extract a download link and filename from the HTML
    String? downloadUrl;
    String? downloadFileName;

    final hrefMatch = RegExp(r'href="([^"]+)"').firstMatch(htmlData);
    final downloadMatch = RegExp(r'download="([^"]*)"').firstMatch(htmlData);

    if (hrefMatch != null) {
      downloadUrl = hrefMatch.group(1);
    }
    if (downloadMatch != null) {
      downloadFileName = downloadMatch.group(1);
    }

    Widget htmlWidget = Html(
      data: htmlData,
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
        "a": Style(
          color: Colors.blue,
          textDecoration: TextDecoration.underline,
        ),
      },
      onLinkTap: (url, attributes, element) {
        // Check if this is a download link
        final downloadAttr = attributes['download'];
        if (downloadAttr != null && url != null) {
          _handleDownload(context, url, downloadAttr);
        }
      },
    );

    // If we found a download link, show a dedicated download button
    if (downloadUrl != null && downloadFileName != null && downloadUrl.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          htmlWidget,
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF107C41),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                _handleDownload(context, downloadUrl!, downloadFileName!);
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                'Download ${downloadFileName!}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Default: just render the HTML
    return htmlWidget;
  }

  void _handleDownload(BuildContext context, String url, String downloadAttr) async {
    final fileName = downloadAttr.isNotEmpty 
        ? downloadAttr 
        : url.split('/').last.split('?').first;
    
    // Show loading snackbar
    Get.snackbar(
      'Downloading',
      'Downloading $fileName...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    final filePath = await DownloadService.downloadFile(
      url: url,
      fileName: fileName,
    );
    
    if (filePath != null) {
      Get.snackbar(
        'Success',
        'File downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showAttachPopover(BuildContext context, BuildContext buttonContext) {
    PopoverDialog.show(
      context: context,
      anchorContext: buttonContext,
      items: [
        PopoverItem(
          icon: Icons.camera_alt_outlined,
          label: 'Camera',
          onTap: () {
            // TODO: Implement camera functionality
          },
        ),
        PopoverItem(
          icon: Icons.photo_library_outlined,
          label: 'Photos',
          onTap: () {
            // TODO: Implement photos functionality
          },
        ),
        PopoverItem(
          icon: Icons.insert_drive_file_outlined,
          label: 'Files',
          onTap: () {
            // TODO: Implement files functionality
          },
        ),
      ],
      width: 200,
      borderRadius: 16,
      elevation: 2,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDestructive
                  ? Colors.red.withOpacity(0.05)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDestructive ? Colors.red.shade700 : Colors.black87,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red.shade700
                          : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
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
