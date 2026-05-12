import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';

import '../controller/home_controller.dart';
import '../core/theme/app_colors.dart';
import '../utils/app_utils.dart';
import '../widgets/loading_widget.dart';
import '../widgets/popover_dialog.dart';
import 'data_controls_view.dart';
import 'knowledge_source_view.dart';
import '../services/shared_pref_manager.dart';
import '../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Theme helper extension — keeps callsites concise
// ---------------------------------------------------------------------------
extension _ThemeX on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme  get tt => Theme.of(this).textTheme;
  bool       get isDark => Theme.of(this).brightness == Brightness.dark;
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());

  // ── Drawer ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: cs.surface,
      onDrawerChanged: (isOpen) {
        if (isOpen) controller.getCreditsUsageApi();
      },
      drawer: SafeArea(
        child: Drawer(
          backgroundColor: cs.surface,
          width: MediaQuery.of(context).size.width * .95,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildProfileFooter(context),

                    // ── Conversations header ──
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => controller.isConversationsExpanded.toggle(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 24, 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                'Conversations',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface.withOpacity(0.4),
                                  letterSpacing: 1.2,
                                  height: 1.5,
                                ),
                              ),
                              const Spacer(),
                              Obx(() => Icon(
                                    controller.isConversationsExpanded.value
                                        ? CupertinoIcons.chevron_down
                                        : CupertinoIcons.chevron_up,
                                    size: 16,
                                    color: cs.onSurface.withOpacity(0.3),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Session list ──
                    Obx(() => controller.isConversationsExpanded.value
                        ? Expanded(
                            child: RefreshIndicator(
                              color: cs.primary,
                              onRefresh: () => controller.getSessionsApi(),
                              child: Obx(() {
                                final sessions = controller.filteredSessions;
                                if (sessions.isEmpty) {
                                  return ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 40,
                                            color:
                                                cs.onSurface.withOpacity(0.2),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No chat found',
                                            style: TextStyle(
                                              color:
                                                  cs.onSurface.withOpacity(0.4),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: sessions.length,
                                  itemBuilder: (context, index) {
                                    final session = sessions[index];
                                    return _buildSessionItem(
                                      context: context,
                                      title:
                                          session.title ?? 'Untitled Chat',
                                      date: _formatDate(session.updatedAt),
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (session.sessionId != null) {
                                          controller.getSessionChatsApi(
                                              session.sessionId!);
                                        }
                                      },
                                      onMenuPressed: () =>
                                          _showSessionOptions(
                                              context, session, controller),
                                    );
                                  },
                                );
                              }),
                            ),
                          )
                        : const SizedBox.shrink()),

                    Obx(() => controller.isConversationsExpanded.value
                        ? const SizedBox.shrink()
                        : const Spacer()),

                    // ── Search + new-chat row ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.historySearchController,
                              style: TextStyle(
                                  fontSize: 14, color: cs.onSurface),
                              onTap: () => controller
                                  .isConversationsExpanded.value = true,
                              decoration: InputDecoration(
                                hintText: 'Search conversation...',
                                hintStyle: TextStyle(
                                  color: cs.onSurface.withOpacity(0.3),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 20,
                                  color: cs.onSurface.withOpacity(0.3),
                                ),
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.05),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cs.onSurface.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: IconButton(
                                icon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2.0, bottom: 4),
                                  child: Icon(
                                    CupertinoIcons.square_pencil_fill,
                                    size: 20,
                                    color: cs.onSurface.withOpacity(0.85),
                                  ),
                                ),
                                tooltip: 'New Conversation',
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller.startNewChat();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Loading overlay
                Obx(
                  () => controller.isSessionsLoading.value
                      ? Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.surface.withOpacity(0.6),
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
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.surface,
              cs.surfaceContainerLowest,
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Message list ──
                  Expanded(
                    child: Obx(() {
                      if (controller.messages.isEmpty) {
                        return Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 12),
                                Image.asset(
                                  context.isDark
                                      ? 'assets/images/logoBW.png'
                                      : 'assets/images/logoBWLig.png',
                                  height: 50,
                                  width: 180,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 20, top: 60),
                        itemCount: controller.messages.length +
                            (controller.isLoading.value ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == controller.messages.length) {
                            return _buildLoadingMessage(context);
                          }
                          return _buildMessage(
                              context,
                              controller.messages[index],
                              controller,
                              index);
                        },
                      );
                    }),
                  ),

                  // ── Suggestion chips (empty state) ──
                  Obx(() => controller.messages.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 8,
                              children: [
                                _buildSuggestionChip(
                                    controller, 0, Icons.psychology, context),
                                _buildSuggestionChip(
                                    controller,
                                    1,
                                    Icons.shopping_cart_checkout,
                                    context),
                                _buildSuggestionChip(controller, 2,
                                    Icons.lightbulb_outline, context),
                                _buildSuggestionChip(controller, 3,
                                    Icons.description_outlined, context),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),

                  _buildInputArea(context, controller),
                ],
              ),

              // ── Hamburger button ──
              Positioned(
                top: 10,
                left: 0,
                child: Builder(
                  builder: (innerContext) => IconButton(
                    onPressed: () => Scaffold.of(innerContext).openDrawer(),
                    icon: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        'assets/images/logo_small.png',
                        height: 28,
                        width: 28,
                      ),
                    ),
                  ),
                ),
              ),

              // ── New Chat button ──
              Positioned(
                top: 10,
                right: 10,
                child: Obx(() => controller.messages.isNotEmpty
                    ? IconButton(
                        onPressed: () => controller.startNewChat(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.onSurface.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.square_pencil_fill,
                            size: 20,
                            color: cs.onSurface.withOpacity(0.85),
                          ),
                        ),
                        tooltip: 'New Chat',
                      )
                    : const SizedBox.shrink()),
              ),

              // Full-screen loading overlay
              Obx(
                () => controller.isLoading.value &&
                        controller.messages.isEmpty
                    ? Positioned.fill(
                        child: Container(
                          color: cs.surface.withOpacity(0.6),
                          child: LoadingWidget.loader(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Suggestion chip ─────────────────────────────────────────────────────

  Widget _buildSuggestionChip(
    dynamic controller,
    int labelIndex,
    IconData icon,
    BuildContext context,
  ) {
    final cs = context.cs;
    final String label = controller.searchOptions[labelIndex];
    final bool isDark = context.isDark;

    return Obx(() {
      final bool isSelected = controller.selectedSuggestions.contains(label);
      final Color selectedBg =
          isDark ? const Color(0xFF0A2342) : cs.primary.withOpacity(0.12);
      final Color selectedFg =
          isDark ? const Color(0xFF70B5F9) : cs.primary;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: labelIndex == 2
              ? () async {
                  controller
                      .addSuggestion(controller.searchOptions[labelIndex]);
                  await controller.pickAndProcessFile(context);
                }
              : labelIndex == 1
                  ? () async {
                      controller
                          .addSuggestion(controller.searchOptions[labelIndex]);
                      await controller.sellNowApi(context);
                    }
                  : () => controller
                      .addSuggestion(controller.searchOptions[labelIndex]),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.37 +
                (labelIndex == 3 ? 50 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : cs.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color:
                      isSelected ? selectedFg : cs.onSurface.withOpacity(0.85),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected ? selectedFg : cs.onSurface.withOpacity(0.85),
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
    });
  }

  // ── Loading bubble ──────────────────────────────────────────────────────

  Widget _buildLoadingMessage(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(cs.onSurface.withOpacity(0.4)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Thinking...',
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── Message bubble ──────────────────────────────────────────────────────

  Widget _buildMessage(
    BuildContext context,
    dynamic message,
    dynamic controller,
    int index,
  ) {
    final cs = context.cs;
    final bool isUser = message.isUser;

    if (!isUser) {
      final String answer = message.text['answer']?.toString() ?? '';
      final bool hasAnswer = answer.trim().isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAnswer || message.isLoading) ...[
            Image.asset('assets/images/logo_small.png',
                height: 37, width: 37),
            const SizedBox(height: 8),
            if (hasAnswer)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHtmlWithDownloadSupport(context, message.text),
                    if (message.suggestions != null &&
                        message.suggestions!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.suggestions!.map<Widget>((s) {
                          return InkWell(
                            onTap: () => controller.addTextToSearch(s),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: cs.onSurface.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: cs.outline.withOpacity(0.3)),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              )
            else if (message.isLoading)
              _buildLoadingMessage(context),
          ],
          if (message.isLoading != true) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionIcon(context, Icons.content_copy_rounded, () {
                    Clipboard.setData(ClipboardData(
                        text: AppUtils.stripHtml(message.text['answer'])));
                    Get.snackbar(
                      'Copied',
                      'Message copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: cs.inverseSurface,
                      colorText: cs.onInverseSurface,
                      duration: const Duration(seconds: 1),
                      margin: const EdgeInsets.all(15),
                      borderRadius: 15,
                    );
                  }),
                  SizedBox(width: !message.hasRefresh ? 0 : 4),
                  if (message.hasRefresh)
                    _buildActionIcon(
                      context,
                      Icons.refresh_outlined,
                      () => controller.reloadMessage(context, index),
                    ),
                  const SizedBox(width: 4),
                  _buildActionIcon(
                    context,
                    Icons.thumb_up_outlined,
                    message.feedbackStatus == null
                        ? () {
                            final String question = index > 0
                                ? (controller.messages[index - 1].isUser
                                    ? controller
                                        .messages[index - 1].text['answer']
                                    : '')
                                : '';
                            _showFeedbackDialog(
                                context, question, controller, index);
                          }
                        : null,
                    isSelected: message.feedbackStatus == 'liked',
                    isDisabled: message.feedbackStatus != null &&
                        message.feedbackStatus != 'liked',
                  ),
                  const SizedBox(width: 4),
                  _buildActionIcon(
                    context,
                    Icons.thumb_down_outlined,
                    message.feedbackStatus == null
                        ? () {
                            final String question = index > 0
                                ? (controller.messages[index - 1].isUser
                                    ? controller
                                        .messages[index - 1].text['answer']
                                    : '')
                                : '';
                            _showNegativeFeedbackDialog(
                                context, question, controller, index);
                          }
                        : null,
                    isSelected: message.feedbackStatus == 'disliked',
                    isDisabled: message.feedbackStatus != null &&
                        message.feedbackStatus != 'disliked',
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // ── User bubble ──
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cs.inverseSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text['answer'],
                style: TextStyle(
                  color: cs.onInverseSurface,
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
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary, width: 1.5),
            ),
            child: Center(
              child: Obx(
                () => Text(
                  controller.userName.value.isEmpty
                      ? 'U'
                      : controller.userName.value[0]
                          .toString()
                          .toUpperCase(),
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input area ──────────────────────────────────────────────────────────

  Widget _buildInputArea(BuildContext context, dynamic controller) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected suggestion chips
              if (controller.selectedSuggestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.selectedSuggestions
                        .map<Widget>((suggestion) {
                      final Color selectedBg = context.isDark ? const Color(0xFF0A2342) : cs.primary.withOpacity(0.12);
                      final Color selectedFg = context.isDark ? const Color(0xFF70B5F9) : cs.primary;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selectedFg,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  controller.removeSuggestion(suggestion),
                              child: Icon(
                                Icons.cancel,
                                size: 14,
                                color: selectedFg.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Text field
              TextField(
                readOnly: controller.isLoading.value,
                controller: controller.searchController,
                maxLines: 4,
                minLines: 1,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask anything',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.55),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: false,
                  contentPadding:
                      const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),

              // Bottom toolbar
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 8, 8),
                child: Row(
                  children: [
                    // Attach
                    Builder(
                      builder: (iconContext) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: cs.onSurface.withOpacity(0.85),
                            size: 22,
                          ),
                          onPressed: () =>
                              _showAttachPopover(context, iconContext),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // QR scan
                    if (!controller.hasText.value) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: cs.onSurface.withOpacity(0.85),
                            size: 22,
                          ),
                          onPressed: () =>
                              controller.scanQRCode(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Send / Mic
                    GestureDetector(
                      onTap: () => controller.hasText.value
                          ? handleSendMessage(controller, context)
                          : _handleMicrophoneInput(controller, context),
                      child: controller.hasText.value
                          ? Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: controller.isLoading.value
                                    ? cs.onSurface.withOpacity(0.2)
                                    : cs.inverseSurface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color: cs.onInverseSurface,
                                size: 20,
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 45,
                              decoration: BoxDecoration(
                                color: controller.isLoading.value
                                    ? cs.onSurface.withOpacity(0.2)
                                    : controller.isListening.value
                                        ? cs.error
                                        : cs.inverseSurface,
                                borderRadius: BorderRadius.all(Radius.circular(25))
                              ),
                              child: Row(
                                mainAxisAlignment: .center,
                                children: [
                                  Image.asset(
                                    'assets/images/mic_icon.png',
                                    width: 18,
                                    height: 18,
                                    color: cs.onInverseSurface,
                                  ),
                                  SizedBox(width: 6,),
                                  Text("Speak", style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface))
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Send handler ────────────────────────────────────────────────────────

  Future<void> handleSendMessage(controller, BuildContext context) async {
    debugPrint('🔘 handleSendMessage called');
    if (controller.isLoading.value) return;

    if (!controller.hasText.value &&
        controller.selectedSuggestions.isNotEmpty &&
        controller.selectedSuggestions[0] == controller.searchOptions[1]) {
      await controller.sellNowApi(context);
      return;
    }

    if (controller.hasText.value) {
      FocusScope.of(context).unfocus();
      if (controller.selectedSuggestions.isEmpty) {
        await controller.sendMessage(context);
      } else if (controller.selectedSuggestions[0] ==
          controller.searchOptions[3]) {
        await controller.askQuestionApi(context);
      } else if (controller.selectedSuggestions[0] ==
          controller.searchOptions[1]) {
        await controller.sellNowApi(context);
      } else if (controller.selectedSuggestions[0] ==
          controller.searchOptions[2]) {
        await controller.askDataInsightsQuestion(context);
      } else {
        await controller.sendMessage(context);
      }
      controller.searchController.clear();
      controller.hasText.value = false;
      return;
    }

    await _handleMicrophoneInput(controller, context);
  }

  // ── Negative feedback dialog ─────────────────────────────────────────────

  void _showNegativeFeedbackDialog(
    BuildContext context,
    String question,
    dynamic controller,
    int messageIndex,
  ) {
    final cs = context.cs;
    double rating = 30.0;
    String? selectedReason;
    final TextEditingController otherReasonController =
        TextEditingController();
    final List<String> reasons = [
      'Incorrect Information',
      'Data Inaccuracy',
      'Lack of Relevance',
      'Presentation & Formatting Deficiency',
      'Insufficient Specificity',
      'Others',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) => Dialog(
          backgroundColor: cs.surfaceContainerLow,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
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
                        icon: Icon(Icons.close_rounded,
                            color: cs.onSurface.withOpacity(0.3)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    'What went wrong?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your feedback helps improve future answers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${rating.toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: rating < 30 ? cs.error : cs.tertiary,
                      letterSpacing: -1,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(stateContext).copyWith(
                      activeTrackColor: cs.primary,
                      inactiveTrackColor: cs.outlineVariant,
                      thumbColor: cs.primary,
                      overlayColor: cs.primary.withOpacity(0.12),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8, elevation: 3),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: rating,
                      min: 0,
                      max: 49,
                      onChanged: (v) => setState(() => rating = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: cs.outlineVariant, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReason,
                        dropdownColor: cs.surfaceContainerLow,
                        hint: Text(
                          'Select a reason',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.4),
                              fontSize: 13),
                        ),
                        isExpanded: true,
                        icon: Icon(Icons.expand_more_rounded,
                            color: cs.onSurface),
                        items: reasons.map((r) {
                          return DropdownMenuItem<String>(
                            value: r,
                            child: Text(r,
                                style: TextStyle(
                                    fontSize: 13, color: cs.onSurface)),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => selectedReason = v),
                      ),
                    ),
                  ),
                  if (selectedReason == 'Other') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: cs.outlineVariant, width: 1.5),
                      ),
                      child: TextField(
                        controller: otherReasonController,
                        maxLines: 2,
                        style: TextStyle(color: cs.onSurface),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Please describe the issue',
                          hintStyle: TextStyle(
                              color: cs.onSurface.withOpacity(0.3),
                              fontSize: 13),
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
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: cs.outline),
                        ),
                        onPressed: () => Navigator.pop(stateContext),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (selectedReason == null ||
                                (selectedReason == 'Other' &&
                                    otherReasonController.text
                                        .trim()
                                        .isEmpty))
                            ? null
                            : () async {
                                Navigator.pop(stateContext);
                                bool success =
                                    await controller.saveFeedbackApi(
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
                          backgroundColor: cs.inverseSurface,
                          disabledBackgroundColor:
                              cs.onSurface.withOpacity(0.12),
                          foregroundColor: cs.onInverseSurface,
                          disabledForegroundColor:
                              cs.onSurface.withOpacity(0.38),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit feedback',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12),
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

  // ── Positive feedback dialog ─────────────────────────────────────────────

  void _showFeedbackDialog(
    BuildContext context,
    String question,
    dynamic controller,
    int messageIndex,
  ) {
    final cs = context.cs;
    double rating = 80.0;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) => Dialog(
          backgroundColor: cs.surfaceContainerLow,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
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
                      icon: Icon(Icons.close_rounded,
                          color: cs.onSurface.withOpacity(0.3)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Text(
                  'How helpful was this response?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your feedback helps improve future answers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${rating.toInt()}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: rating < 70 ? cs.tertiary : cs.primary,
                    letterSpacing: -1,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(stateContext).copyWith(
                    activeTrackColor: cs.primary,
                    inactiveTrackColor: cs.outlineVariant,
                    thumbColor: cs.primary,
                    overlayColor: cs.primary.withOpacity(0.12),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8, elevation: 3),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: rating,
                    min: 0,
                    max: 100,
                    onChanged: (v) => setState(() => rating = v),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: cs.outline),
                      ),
                      onPressed: () => Navigator.pop(stateContext),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
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
                        backgroundColor: cs.inverseSurface,
                        foregroundColor: cs.onInverseSurface,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit feedback',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12),
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

  // ── Action icon ──────────────────────────────────────────────────────────

  Widget _buildActionIcon(
    BuildContext context,
    IconData icon,
    VoidCallback? onTap, {
    bool isSelected = false,
    bool isDisabled = false,
  }) {
    final cs = context.cs;
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
                ? (icon == Icons.thumb_up_outlined
                    ? Colors.green
                    : cs.error)
                : (isDisabled
                    ? cs.onSurface.withOpacity(0.15)
                    : cs.onSurface.withOpacity(0.4)),
          ),
        ),
      ),
    );
  }

  // ── Thank-you dialog ─────────────────────────────────────────────────────

  void _showThankYouDialog(BuildContext context) {
    final cs = context.cs;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(ctx)) Navigator.pop(ctx);
        });
        return Dialog(
          backgroundColor: cs.surfaceContainerLow,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded,
                          color: cs.onSurface.withOpacity(0.3)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('🙏', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Thank you!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your feedback has been recorded',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: cs.onSurface.withOpacity(0.6),
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

  // ── Session options dialog ───────────────────────────────────────────────

  void _showSessionOptions(
    BuildContext context,
    dynamic session,
    dynamic controller,
  ) {
    final cs = context.cs;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chat Options',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: cs.outlineVariant),
              _buildDialogOption(
                context: context,
                icon: Icons.edit_outlined,
                label: 'Edit Name',
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditSessionDialog(context, session, controller);
                },
              ),
              _buildDialogOption(
                context: context,
                icon: Icons.download_rounded,
                label: 'Export Chat',
                onTap: () {
                  Navigator.pop(ctx);
                  controller.exportSessionChatApi(
                      context, session.sessionId);
                },
              ),
              _buildDialogOption(
                context: context,
                icon: Icons.delete_outline_rounded,
                label: 'Delete Chat',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmationDialog(
                      context, session, controller);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color:
                      isDestructive ? cs.error : cs.onSurface),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      isDestructive ? cs.error : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit session dialog ──────────────────────────────────────────────────

  void _showEditSessionDialog(
    BuildContext context,
    dynamic session,
    dynamic controller,
  ) {
    final cs = context.cs;
    final TextEditingController editController =
        TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        title: Text('Edit Chat Title',
            style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: editController,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter new title',
            hintStyle:
                TextStyle(color: cs.onSurface.withOpacity(0.4)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: cs.outline)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: cs.primary)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.inverseSurface,
              foregroundColor: cs.onInverseSurface,
            ),
            onPressed: () {
              final newTitle = editController.text.trim();
              if (newTitle.isNotEmpty) {
                Navigator.pop(ctx);
                controller.editSessionTitleApi(
                    context, session.sessionId, newTitle);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation dialog ───────────────────────────────────────────

  void _showDeleteConfirmationDialog(
    BuildContext context,
    dynamic session,
    dynamic controller,
  ) {
    final cs = context.cs;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        title: Text('Delete Chat?',
            style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Are you sure you want to delete this chat history? This action cannot be undone.',
          style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteSessionApi(context, session.sessionId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── HTML renderer ────────────────────────────────────────────────────────

  Widget _buildHtmlWithDownloadSupport(
    BuildContext context,
    Map<String, dynamic> htmlData,
  ) {
    final List<Widget> valuesList = [];
    bool hasAnyHtml = false;
    final RegExp htmlTagRegex = RegExp(
      r'<(div|table|span|p|br|h[1-6]|ul|ol|li|b|i|strong|em|a|img|form|html|body|thead|tbody|tr|td|th)(>|\s)',
      caseSensitive: false,
    );

    htmlData.forEach((key, value) {
      final str = value?.toString() ?? '';
      if (htmlTagRegex.hasMatch(str) ||
          str.contains(
              RegExp(r'```(?:html)?\s*<', caseSensitive: false))) {
        hasAnyHtml = true;
      }
    });

    htmlData.forEach((key, value) {
      String strValue = value?.toString() ?? '';
      if (hasAnyHtml) {
        final RegExp htmlBlockRegex =
            RegExp(r'```(?:html)?\s*([\s\S]*?)\s*```', caseSensitive: false);
        final match = htmlBlockRegex.firstMatch(strValue);
        if (match != null) {
          String inner = match.group(1) ?? '';
          if (inner.trimLeft().startsWith('<')) strValue = inner.trim();
        } else {
          int firstTagIndex =
              strValue.indexOf(RegExp(r'<[a-zA-Z/]'));
          int lastIndex = strValue.lastIndexOf('>');
          if (firstTagIndex != -1 &&
              lastIndex != -1 &&
              firstTagIndex < lastIndex) {
            strValue =
                strValue.substring(firstTagIndex, lastIndex + 1).trim();
          } else {
            strValue = '';
          }
        }
      }
      if (strValue.isNotEmpty) {
        valuesList.add(_commonHtmlWidget(context, strValue));
      }
    });

    final bool hasTable = htmlData.values.any((v) {
      final s = v?.toString() ?? '';
      return s.contains('<table') || s.contains('<TABLE');
    });

    return hasTable
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: valuesList),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: valuesList);
  }

  // ── Attach popover ────────────────────────────────────────────────────────

  void _showAttachPopover(BuildContext context, BuildContext buttonContext) {
    final controller = Get.find<HomeController>();
    PopoverDialog.show(
      context: context,
      anchorContext: buttonContext,
      items: [
        PopoverItem(
          icon: Icons.camera_alt_outlined,
          label: 'Camera',
          onTap: () => controller.openCamera(context),
        ),
        PopoverItem(
          icon: Icons.photo_library_outlined,
          label: 'Photos',
          onTap: () => controller.openPhotos(context),
        ),
      ],
      width: 200,
      borderRadius: 16,
      elevation: 2,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildSessionItem({
    required BuildContext context,
    required String title,
    required String date,
    required VoidCallback onTap,
    required VoidCallback onMenuPressed,
  }) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              InkWell(
                onTap: onMenuPressed,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.more_vert,
                      size: 20,
                      color: cs.onSurface.withOpacity(0.45)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isDestructive = false,
  }) {
    final cs = context.cs;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDestructive
                  ? cs.error.withOpacity(0.07)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 22,
                    color: isDestructive ? cs.error : cs.onSurface),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? cs.error : cs.onSurface,
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

  static Future<bool> launch(String phUrl) async {
    final Uri url = Uri.parse(phUrl);
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  // ── Themed HTML widget (instance method so we can access context) ─────────

  Widget _commonHtmlWidget(BuildContext context, String htmlContent) {
    final cs = context.cs;
    final bool isDark = context.isDark;

    return Html(
      data: htmlContent,
      shrinkWrap: true,
      extensions: [
        const TableHtmlExtension(),
        TagExtension(
          tagsToExtend: {'svg'},
          builder: (_) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: cs.primary, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Download',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(15),
          color: cs.onSurface,
          lineHeight: const LineHeight(1.7),
        ),
        'table': Style(
          backgroundColor: cs.surfaceContainerLow,
          border: Border.all(color: cs.outlineVariant, width: 1),
        ),
        'th': Style(
          padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: cs.surfaceContainerHighest,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
          border: Border.all(color: cs.outlineVariant, width: 0.5),
        ),
        'td': Style(
          padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 8),
          color: cs.onSurface,
          border: Border.all(color: cs.outlineVariant, width: 0.5),
          alignment: Alignment.centerLeft,
        ),
        'h1': Style(
          fontSize: FontSize(24),
          fontWeight: FontWeight.bold,
          color: cs.primary,
          margin: Margins.only(bottom: 12),
        ),
        'p': Style(
            margin: Margins.only(bottom: 12), color: cs.onSurface),
        'code': Style(
          backgroundColor: cs.onSurface.withOpacity(0.07),
          color: cs.onSurface,
          padding: HtmlPaddings.all(4),
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
        'pre': Style(
          backgroundColor: cs.onSurface.withOpacity(0.05),
          padding: HtmlPaddings.all(12),
          margin: Margins.symmetric(vertical: 8),
          border: Border.all(
              color: cs.outlineVariant.withOpacity(0.5), width: 1),
        ),
        'a': Style(
          color: cs.primary,
          textDecoration: TextDecoration.underline,
        ),
      },
      onLinkTap: (url, attributes, element) => launch(url ?? ''),
    );
  }

  // ── AI consent dialog ────────────────────────────────────────────────────

  Future<bool> _showAIConsentDialog(BuildContext context) async {
    final cs = context.cs;
    bool consent = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        title: Text(
          'We use AI to process your input',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface),
        ),
        content: Text(
          'When you use this feature, your voice or text input will be sent to OpenAI to generate responses. We do not store your personal data.\n\nDo you allow us to share your data for this purpose?',
          style: TextStyle(
              fontSize: 15, height: 1.4, color: cs.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () {
              consent = false;
              Navigator.of(ctx).pop();
            },
            child: Text('Not Now',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.inverseSurface,
              foregroundColor: cs.onInverseSurface,
            ),
            onPressed: () {
              consent = true;
              Navigator.of(ctx).pop();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return consent;
  }

  // ── Microphone handler ───────────────────────────────────────────────────

  Future<void> _handleMicrophoneInput(
    HomeController controller,
    BuildContext context,
  ) async {
    if (controller.isListening.value) {
      await controller.stopListening();
      return;
    }

    bool hasConsent =
        await SharedPrefManager.instance.getBoolAsync('hasAIConsent') ??
            false;
    if (!hasConsent) {
      bool consent = await _showAIConsentDialog(context);
      if (!consent) return;
      await SharedPrefManager.instance.setBoolAsync('hasAIConsent', true);
    }

    final status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'Microphone Permission Required',
        'Please enable microphone permission in Settings → Privacy & Security → Microphone to use voice input.',
      );
      return;
    }
    if (status.isGranted) {
      await controller.startListening(context);
      return;
    }

    final result = await Permission.microphone.request();
    if (!result.isGranted) return;
    await controller.startListening(context);
  }

  void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    final cs = context.cs;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerLow,
        title: Text(title, style: TextStyle(color: cs.onSurface)),
        content: Text(message,
            style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.inverseSurface,
              foregroundColor: cs.onInverseSurface,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ── Credits widget ────────────────────────────────────────────────────────

  Widget _buildCreditsUI(BuildContext context, {bool inPopup = false}) {
    final cs = context.cs;
    return Obx(() {
      if (controller.isCreditsLoading.value) {
        return Container(
          margin: inPopup
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          height: 80,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: cs.outlineVariant.withOpacity(0.5), width: 1),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ),
        );
      }

      return Container(
        margin: inPopup
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: cs.outlineVariant.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.toll_outlined,
                    size: 20,
                    color: cs.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  'Credits',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.creditsLeft.value.toStringAsFixed(2)}/${controller.totalCredits.value.toInt()}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (controller.creditsLeft.value /
                        controller.totalCredits.value)
                    .clamp(0.0, 1.0),
                backgroundColor: cs.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(cs.primary),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Profile footer ────────────────────────────────────────────────────────

  Widget _buildProfileFooter(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => _showProfileDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: Row(
            children: [
              Obx(() => _buildAvatar(
                    context,
                    controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : 'U',
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_right_2,
                    size: 14,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String name,
      {double size = 40}) {
    final cs = context.cs;
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }

  // ── Profile dialog ────────────────────────────────────────────────────────

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ValueListenableBuilder<String>(
          valueListenable: NormalThemeController().currentTheme,
          builder: (context, themeKey, child) {
            final cs = Theme
                .of(context)
                .colorScheme;
            return Dialog(
                backgroundColor: cs.surfaceContainerLow,
                surfaceTintColor: cs.surfaceTint,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Obx(() =>
                              _buildAvatar(
                                context,
                                controller.userName.value.isNotEmpty
                                    ? controller.userName.value
                                    : 'U',
                                size: 50,
                              )),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(
                                  () =>
                                  Text(
                                    controller.userName.value.isNotEmpty
                                        ? controller.userName.value
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: cs.outlineVariant, height: 1),
                      const SizedBox(height: 20),
                      _buildCreditsUI(context, inPopup: true),
                      const SizedBox(height: 16),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(dialogContext);
                          Get.snackbar(
                            'Settings',
                            'Coming soon...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: cs.inverseSurface,
                            colorText: cs.onInverseSurface,
                          );
                        },
                      ),
                      AppTheme.instance.dropdownBuilder(
                            (selectedKey, themeMap, changeTheme) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: cs.onSurface.withOpacity(0.03),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedKey,
                                  dropdownColor: cs.surfaceContainerLow,
                                  isExpanded: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                                      color: cs.onSurface.withOpacity(0.4)),
                                  items: themeMap.entries.map((e) {
                                    return DropdownMenuItem(
                                      value: e.key,
                                      child: Row(
                                        children: [
                                          Icon(
                                            e.key == 'dark'
                                                ? Icons.dark_mode_outlined
                                                : e.key == 'light'
                                                ? Icons.light_mode_outlined
                                                : Icons
                                                .brightness_auto_outlined,
                                            size: 20,
                                            color: cs.onSurface,
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            e.value.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (key) {
                                    if (key != null) {
                                      changeTheme(key);
                                      AppTheme.instance.updateTheme(key);
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.data_usage_rounded,
                        label: 'Data controls',
                        onTap: () {
                          Navigator.pop(dialogContext);
                          Get.to(() => const DataControlsView());
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        isDestructive: true,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          controller.logout(context);
                        },
                      ),
                    ],
                  ),
                ));
          },
        );
      });}
}