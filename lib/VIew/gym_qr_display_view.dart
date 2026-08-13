import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kavachx/Services/api_service.dart';

class GymQrDisplayView extends StatefulWidget {
  const GymQrDisplayView({super.key});

  @override
  State<GymQrDisplayView> createState() => _GymQrDisplayViewState();
}

class _GymQrDisplayViewState extends State<GymQrDisplayView> {
  final GetStorage _storage = GetStorage();
  final ApiService _apiService = Get.find<ApiService>();

  String? qrToken;
  String? qrImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGymQrToken();
  }

  Future<void> _loadGymQrToken() async {
    setState(() => isLoading = true);

    // 1. Check local storage
    String? token = _apiService.getGymQrToken();
    String? imgUrl = _apiService.getGymQrUrl();

    if (token != null && token.isNotEmpty) {
      setState(() {
        qrToken = token;
        qrImageUrl = imgUrl;
        isLoading = false;
      });
      return;
    }

    // 2. Read from ApiService user data
    final userData = _apiService.getUserData();
    debugPrint('=== DEBUG USER DATA FROM STORAGE ===: $userData');

    token = userData?['gymToken'] ??
        userData?['gym']?['gymToken'] ??
        userData?['qr']?['token'];
    imgUrl = userData?['qr']?['qrUrl'] ?? userData?['qrUrl'];

    if (token != null && token.isNotEmpty) {
      _storage.write('gym_qr_token', token);
      if (imgUrl != null) _storage.write('gym_qr_url', imgUrl);
      setState(() {
        qrToken = token;
        qrImageUrl = imgUrl;
        isLoading = false;
      });
      return;
    }

    // 3. Fetch from /auth/me backend endpoint as fallback
    try {
      final response = await _apiService.getMe();
      debugPrint('=== DEBUG GET /auth/me RESPONSE ===: ${response.body}');

      if (response.isOk && response.body != null) {
        final body = response.body;
        final data = body['data'] ?? body;

        token = data?['qr']?['token'] ??
            data?['gym']?['gymToken'] ??
            data?['user']?['gymToken'];
        imgUrl = data?['qr']?['qrUrl'] ?? data?['gym']?['qrUrl'];

        if (token != null && token.isNotEmpty) {
          _storage.write('gym_qr_token', token);
          if (imgUrl != null) _storage.write('gym_qr_url', imgUrl);
          _apiService.saveAuthPayload(data);
        }
      }
    } catch (e) {
      debugPrint('Error loading QR: $e');
    }

    setState(() {
      qrToken = token;
      qrImageUrl = imgUrl;
      isLoading = false;
    });
  }

  void _forceFallbackToken() async {
    setState(() => isLoading = true);
    try {
      final response = await _apiService.getMe();
      if (response.isOk && response.body != null) {
        final data = response.body['data'] ?? response.body;
        final token = data?['qr']?['token'] ?? data?['gym']?['gymToken'];
        final imgUrl = data?['qr']?['qrUrl'] ?? data?['gym']?['qrUrl'];
        if (token != null && token.isNotEmpty) {
          _storage.write('gym_qr_token', token);
          if (imgUrl != null) _storage.write('gym_qr_url', imgUrl);
          setState(() {
            qrToken = token;
            qrImageUrl = imgUrl;
          });
        }
      }
    } catch (e) {
      debugPrint('Error forcing fallback QR token: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String joinUrl = (qrToken != null && qrToken!.isNotEmpty)
        ? (qrToken!.startsWith('http') ? qrToken! : 'https://kavachx.com/join/$qrToken')
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Gym Join QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // 1. Background Image
            Positioned.fill(
              child: Image.asset(
                'asset/app_backgrounds/authscreen.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                color: const Color(0xFF0F0F12).withValues(alpha: 0.85),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // 2. QR Content
            SafeArea(
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFFF3B30))
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C22).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF3B30)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Scan to Join Gym',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (qrToken != null && qrToken!.isNotEmpty) ...[
                              if (qrImageUrl != null && qrImageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    qrImageUrl!,
                                    width: 220,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return QrImageView(
                                        data: joinUrl,
                                        version: QrVersions.auto,
                                        size: 220.0,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: Color(0xFFFF3B30),
                                        ),
                                        dataModuleStyle: const QrDataModuleStyle(
                                          dataModuleShape: QrDataModuleShape.square,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                QrImageView(
                                  data: joinUrl,
                                  version: QrVersions.auto,
                                  size: 220.0,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFFFF3B30),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.white,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              SelectableText(
                                'Token: $qrToken',
                                style: const TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 12,
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Color(0xFFFF3B30),
                                size: 64,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Unable to load active QR token',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _loadGymQrToken,
                                      child: const Text('RETRY'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _forceFallbackToken,
                                      child: const Text('GENERATE'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}