import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

void showSendAnnouncementBottomSheet(BuildContext context) {
  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final RxString selectedType = 'announcement'.obs;
  final RxBool isSubmitting = false.obs;

  Get.bottomSheet(
    Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Broadcast Notification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification Type Chips
            Obx(
              () => Wrap(
                spacing: 8,
                children: [
                  _buildTypeChip(
                    'announcement',
                    '📢 Announcement',
                    selectedType,
                  ),
                  _buildTypeChip('payment', '💳 Payment Alert', selectedType),
                  _buildTypeChip('general', '🔔 General Notice', selectedType),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Notification Title (e.g. Gym Holiday Notice)',
                hintStyle: const TextStyle(color: Color(0xFF71717A)),
                filled: true,
                fillColor: const Color(0xFF2C2C35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Message Field
            TextField(
              controller: messageCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your message for members here...',
                hintStyle: const TextStyle(color: Color(0xFF71717A)),
                filled: true,
                fillColor: const Color(0xFF2C2C35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Action
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting.value
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();
                          final message = messageCtrl.text.trim();
                          if (title.isEmpty || message.isEmpty) return;

                          isSubmitting.value = true;
                          final response = await Get.find<ApiService>()
                              .sendAnnouncement(
                                title: title,
                                message: message,
                                type: selectedType.value,
                              );
                          isSubmitting.value = false;

                          // Safe check if response.body is Map to avoid String crash
                          final isMap = response.body is Map;
                          final isSuccess =
                              isMap && response.body['success'] == true;

                          if (response.isOk && isSuccess) {
                            Get.back();
                            Get.snackbar(
                              'Sent! 🚀',
                              response.body['message'] ??
                                  'Notification broadcasted to all members.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF1C1C22),
                              colorText: Colors.white,
                              borderColor: const Color(0xFF34C759),
                              borderWidth: 1,
                            );
                          } else {
                            String errMessage = 'Unable to broadcast alert.';
                            if (isMap && response.body['message'] != null) {
                              errMessage = response.body['message'];
                            } else if (response.statusCode == 404) {
                              errMessage =
                                  'Broadcast endpoint not found (404). Restart server.';
                            }

                            Get.snackbar(
                              'Failed',
                              errMessage,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF1C1C22),
                              colorText: Colors.white,
                              borderColor: const Color(0xFFFF3B30),
                              borderWidth: 1,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'BROADCAST TO MEMBERS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _buildTypeChip(String value, String label, RxString selectedType) {
  final isSelected = selectedType.value == value;
  return ChoiceChip(
    label: Text(label),
    selected: isSelected,
    selectedColor: const Color(0xFFFF3B30),
    backgroundColor: const Color(0xFF2C2C35),
    labelStyle: TextStyle(
      color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
    onSelected: (_) => selectedType.value = value,
  );
}
