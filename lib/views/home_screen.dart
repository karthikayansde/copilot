// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'package:flutter_html/flutter_html.dart';
// import 'package:get/get.dart';
//
// import '../controller/home_controller.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(HomeController());
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Copilot'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () => controller.logout(context),
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: Obx(() {
//                   if (controller.messages.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.chat_bubble_outline,
//                             size: 80,
//                             color: Colors.grey.shade300,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Start a conversation',
//                             style: TextStyle(
//                               color: Colors.grey.shade500,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   return ListView.separated(
//                     controller: controller.scrollController,
//                     padding: const EdgeInsets.only(bottom: 20),
//                     itemCount: controller.messages.length + (controller.isLoading.value ? 1 : 0),
//                     separatorBuilder: (context, index) => const SizedBox(height: 16),
//                     itemBuilder: (context, index) {
//                       if (index == controller.messages.length) {
//                         return Align(
//                           alignment: Alignment.centerLeft,
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             margin: const EdgeInsets.only(right: 60),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade100,
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(16),
//                                 topRight: Radius.circular(16),
//                                 bottomRight: Radius.circular(16),
//                               ),
//                             ),
//                             child: const SizedBox(
//                               width: 40,
//                               height: 20,
//                               child: Center(
//                                 child: SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(strokeWidth: 2),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//
//                       final message = controller.messages[index];
//                       return Align(
//                         alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           margin: EdgeInsets.only(
//                             left: message.isUser ? 60 : 0,
//                             right: message.isUser ? 0 : 60,
//                           ),
//                           decoration: BoxDecoration(
//                             color: message.isUser
//                                 ? Theme.of(context).colorScheme.primaryContainer
//                                 : Colors.grey.shade100,
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
//                               bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
//                             ),
//                           ),
//                           child: message.isUser
//                               ? Text(
//                             message.text,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onPrimaryContainer,
//                               fontSize: 16,
//                             ),
//                           )
//                               : Html(
//                             data: message.text,
//                             style: {
//                               "body": Style(
//                                 margin: Margins.zero,
//                                 padding: HtmlPaddings.zero,
//                                 fontSize: FontSize(16),
//                                 color: Colors.black87,
//                               ),
//                               "p": Style(
//                                 margin: Margins.only(bottom: 8),
//                               ),
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.shade300,
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Obx(() => TextField(
//                   controller: controller.searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Search or speak...',
//                     prefixIcon: const Icon(Icons.add, color: Colors.grey),
//                     suffixIcon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 controller.isListening.value ? Icons.mic : Icons.mic_none,
//                                 color: controller.isListening.value ? Colors.red : Colors.deepPurple,
//                                 size: 28,
//                               ),
//                               onPressed: controller.speechEnabled.value
//                                   ? (controller.isListening.value ? controller.stopListening : controller.startListening)
//                                   : null,
//                               tooltip: controller.isListening.value ? 'Stop listening' : 'Start voice search',
//                             ),
//                             if (controller.isListening.value)
//                               Positioned(
//                                 right: 8,
//                                 top: 8,
//                                 child: Container(
//                                   width: 8,
//                                   height: 8,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.red,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//
//                           Obx(
//                               ()=> IconButton(
//                               icon: Icon(Icons.arrow_circle_up, color: controller.hasText.value? Colors.deepPurple : Colors.grey, size: 28),
//                               onPressed:controller.hasText.value? () async {
//                                 await controller.sendMessage(context);
//                               }:(){},
//                               tooltip: 'Send',
//                             ),
//                           ),
//                       ],
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                   ),
//                 )),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.08),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.black, Color(0xFF2D2D2D)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilog AI Lens',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'POWERED BY AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () => controller.logout(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.logout, color: Colors.black87, size: 18),
                ),
                tooltip: 'Logout',
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
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.messages.isEmpty) {
                    return SingleChildScrollView(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20,),
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.03),
                                    Colors.black.withOpacity(0.01),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.08),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.black, Color(0xFF2D2D2D)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.analytics_outlined,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Welcome to Pilog AI Lens',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Advanced AI insights at your fingertips',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildSuggestionChip('Analyze Data', Icons.assessment_outlined),
                                _buildSuggestionChip('Get Insights', Icons.lightbulb_outline),
                                _buildSuggestionChip('Ask Questions', Icons.help_outline),
                                _buildSuggestionChip('Generate Reports', Icons.description_outlined),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    itemCount: controller.messages.length + (controller.isLoading.value ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      if (index == controller.messages.length) {
                        return _buildLoadingMessage();
                      }

                      final message = controller.messages[index];
                      return _buildMessage(context, message, controller);
                    },
                  );
                }),
              ),
              _buildInputArea(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(24),
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
              margin: const EdgeInsets.only(right: 12, top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: Container(
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
                borderRadius: BorderRadius.circular(24),
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
          ),
          if (isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 12, top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.person_outline, color: Colors.black.withOpacity(0.7), size: 16),
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
          borderRadius: BorderRadius.circular(30),
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
        child: Obx(
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
        ),
      ),
    );
  }
}