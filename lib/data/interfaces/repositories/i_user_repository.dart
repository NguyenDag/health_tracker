import '../../../domain/entities/user_profile.dart';

abstract class IUserRepository {
  Future<List<UserProfile>> getAllUsers();
  Future<void> updateUserStatus(String userId, String status);
  Future<void> deleteUser(String userId);
}
