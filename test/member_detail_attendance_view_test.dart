import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_detail_attendance_controller.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/VIew/member_detail_attendance_view.dart';

class MockApiServiceForMemberDetail extends ApiService {
  @override
  Future<Response> getMemberAttendanceHistoryForOwner(String memberId) async {
    return const Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          'member': {
            '_id': 'mem123',
            'name': 'John Gymmer',
            'email': 'john@gym.com',
            'phone': '9876543210',
            'streakDays': 5,
          },
          'totalCheckIns': 3,
          'history': [
            {
              '_id': 'att1',
              'dateStr': '2026-08-15',
              'checkInTime': '2026-08-15T09:00:00.000Z',
              'checkOutTime': '2026-08-15T10:15:00.000Z',
              'status': 'checked_out',
              'streakDays': 5,
              'targetPart': 'Chest & Triceps',
              'exercises': [
                {
                  'name': 'Incline Bench Press',
                  'muscleGroup': 'Chest',
                  'totalSets': 3,
                  'completedSets': 3,
                  'repsPerSet': 12,
                  'weightInKg': 50,
                  'isCompleted': true,
                },
              ],
            },
          ],
        },
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.put<ApiService>(MockApiServiceForMemberDetail());
  });

  testWidgets('MemberDetailAttendanceView renders member header, attendance dates and exercise cards', (WidgetTester tester) async {
    final controller = Get.put(
      MemberDetailAttendanceController(),
      tag: 'mem123',
    );
    controller.initMemberId('mem123', {
      '_id': 'mem123',
      'name': 'John Gymmer',
      'email': 'john@gym.com',
      'phone': '9876543210',
    });

    await tester.pumpWidget(
      const GetMaterialApp(
        home: MemberDetailAttendanceView(
          memberId: 'mem123',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify key titles and widgets
    expect(find.text('Member Activity & Attendance'), findsOneWidget);
    expect(find.text('John Gymmer'), findsOneWidget);
    expect(find.text('ATTENDANCE & WORKOUT HISTORY'), findsOneWidget);
    expect(find.text('Incline Bench Press'), findsOneWidget);
  });
}
