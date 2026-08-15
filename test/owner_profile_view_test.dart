import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/owner_profile_controller.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/VIew/owner_profile_view.dart';

class MockApiService extends ApiService {
  @override
  Map<String, dynamic>? getUserData() {
    return {
      'name': 'Test Owner',
      'email': 'testowner@gmail.com',
      'phone': '9998887770',
    };
  }

  @override
  Future<Response> getGymProfile() async {
    return const Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          'owner': {
            'name': 'Test Owner',
            'email': 'testowner@gmail.com',
            'phone': '9998887770',
          },
          'gym': {
            'name': 'Test Fitness Hub',
            'phone': '1234567890',
            'address': '123 Tech Park',
            'gymToken': 'KAVACHX_TEST_123',
          },
        },
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    // Register MockApiService
    Get.put<ApiService>(MockApiService());
  });

  testWidgets('OwnerProfileView renders all profile widgets and fields cleanly', (WidgetTester tester) async {
    final controller = Get.put(OwnerProfileController());
    
    // Set controllers to non-loading state
    controller.isLoading.value = false;
    controller.ownerNameController.text = 'Test Owner';
    controller.gymNameController.text = 'Test Fitness Hub';

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: OwnerProfileView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify key widgets appear on screen
    expect(find.text('Gym Owner Profile'), findsOneWidget);
    expect(find.text('GYM DETAILS'), findsOneWidget);
    expect(find.text('OWNER ACCOUNT INFORMATION'), findsOneWidget);
    expect(find.text('GYM ACCESS & QR CODE'), findsOneWidget);
    expect(find.text('SAVE CHANGES'), findsOneWidget);
    expect(find.text('LOGOUT'), findsOneWidget);
  });
}
