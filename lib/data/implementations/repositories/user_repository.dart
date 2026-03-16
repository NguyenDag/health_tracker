import '../../../core/network/supabase_config.dart';
import '../../../domain/entities/user_profile.dart';
import '../../interfaces/repositories/i_user_repository.dart';

class UserRepository implements IUserRepository {
  @override
  Future<List<UserProfile>> getAllUsers() async {
    // Calls the security-definer function that bypasses RLS
    // and joins auth.users to include email + last_sign_in_at.
    // Requires admin_rls_policies.sql to be run in Supabase first.
    final data = await supabase.rpc('get_all_users_for_admin');
    return (data as List)
        .map((row) => UserProfile.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateUserStatus(String userId, String status) async {
    await supabase.from('users').update({'status': status}).eq('id', userId);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await supabase.from('users').delete().eq('id', userId);
  }
}
