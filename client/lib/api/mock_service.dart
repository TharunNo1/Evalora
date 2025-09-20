import 'dart:async';
import 'dart:math';
import '../models/startup.dart';
import '../models/user.dart';
import '../models/evaluation_request.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class UploadRequest {
  final String requestId;
  final String startupName;
  final String founderName;
  final String founderEmail;
  final File? checklist;
  final File? pitchDeck;
  final List<File> supportingDocs;

  UploadRequest({
    required this.requestId,
    required this.startupName,
    required this.founderName,
    required this.founderEmail,
    this.checklist,
    this.pitchDeck,
    this.supportingDocs = const [],
  });
}
class MockService {

  static final List<UploadRequest> _requests = [];
  static final Uuid _uuid = const Uuid();

  static String generateRequestId() => _uuid.v4();

  static Future<void> submitRequest(UploadRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    _requests.add(request);
  }

  static List<UploadRequest> getUserRequests() {
    return _requests;
  }

  static final Random _random = Random();

  // Founder evaluation progress (0–1 scale)
  static double getFounderProgress() {
    return _random.nextDouble(); // e.g., 0.45 = 45% progress
  }

  // Investor: startups per domain
  static Map<String, int> getInvestorDomains() {
    return {
      "FinTech": _random.nextInt(10) + 1,
      "HealthTech": _random.nextInt(10) + 1,
      "EdTech": _random.nextInt(10) + 1,
    };
  }

  // Evaluator: reviews completed vs pending
  static Map<String, int> getEvaluatorReviews() {
    int completed = _random.nextInt(10) + 1;
    int pending = _random.nextInt(10) + 1;
    return {
      "Completed": completed,
      "Pending": pending,
    };
  }
  
  Future<UserModel> signIn(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(id: 'u1', name: 'Asha Kumar', email: 'asha@example.com');
  }

  Future<List<Startup>> fetchStartups() async {

    await Future.delayed(const Duration(milliseconds: 600));
    return List.generate(
      6,
      (i) => Startup(
        id: 's\$i',
        idea: 'Idea #\$i — Smart Fintech Widget',
        domain: i % 2 == 0 ? 'Fintech' : 'Healthtech',
        founder: i % 2 == 0 ? 'Ramesh' : 'Sita',
        score: (60 + i * 6) / 100.0 * 100, // just sample
        fundingStatus: i % 3 == 0 ? 'Seed' : 'Pre-Seed',
      ),
    );
  }

  Future<EvaluationRequest> submitDocuments(String startupId) async {
    await Future.delayed(const Duration(seconds: 1));
    return EvaluationRequest(
      requestId: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      startupId: startupId,
      stage: RequestStage.submission,
    );
  }

  Future<Map<String, dynamic>> generateEvaluation(String requestId) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'evaluationId': 'EVAL-${DateTime.now().millisecondsSinceEpoch}',
      'score': 78,
      'analysisUrl': 'https://example.com/analysis/\$requestId.pdf',
    };
  }
}

final mockService = MockService();
