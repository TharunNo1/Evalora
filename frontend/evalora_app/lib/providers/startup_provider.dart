import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/startup.dart';
import '../api/mock_service.dart';


final startupsProvider = FutureProvider<List<Startup>>((ref) async {
return await mockService.fetchStartups();
});