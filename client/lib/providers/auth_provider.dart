import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../api/mock_service.dart';


final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) => AuthNotifier(ref));


class AuthNotifier extends StateNotifier<UserModel?> {
final Ref ref;
AuthNotifier(this.ref) : super(null);


Future<void> signIn(String username, String password) async {
final user = await mockService.signIn(username, password);
state = user;
}


void signOut() {
state = null;
}
}