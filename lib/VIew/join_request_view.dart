import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/join_request_controller.dart';

class JoinRequestsView extends StatelessWidget {
  const JoinRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JoinRequestsController());

    return RefreshIndicator(
      onRefresh: () => controller.fetchPendingRequests(),
      color: const Color(0xFFFF3B30),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Join Requests',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF3B30)),
                      ),
                      child: Text(
                        '${controller.requests.length} Pending',
                        style: const TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review and manage pending membership applications',
              style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Requests List Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
                  );
                }

                if (controller.requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.mark_email_read_outlined,
                          size: 56,
                          color: Color(0xFFA1A1AA),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No pending join requests',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'New member requests will appear here',
                          style:
                              TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.requests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = controller.requests[index];
                    return Obx(() {
                      final isProcessing =
                          controller.processingRequestId.value == item.id;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C22).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A34)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      const Color(0xFFFF3B30).withValues(alpha: 0.15),
                                  child: Text(
                                    item.user.name.isNotEmpty
                                        ? item.user.name[0].toUpperCase()
                                        : 'M',
                                    style: const TextStyle(
                                      color: Color(0xFFFF3B30),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.user.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.user.phone.isNotEmpty
                                            ? item.user.phone
                                            : item.user.email,
                                        style: const TextStyle(
                                          color: Color(0xFFA1A1AA),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isProcessing
                                        ? null
                                        : () => controller.rejectRequest(item.id),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFFF3B30),
                                      side: const BorderSide(
                                          color: Color(0xFFFF3B30)),
                                      minimumSize: const Size(0, 42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('REJECT'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isProcessing
                                        ? null
                                        : () =>
                                            controller.approveRequest(item.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF34C759),
                                      minimumSize: const Size(0, 42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: isProcessing
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'APPROVE',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}