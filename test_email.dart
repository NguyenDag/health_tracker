import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient('https://dnivgtxlttiwmwjznpgf.supabase.co', 'sb_publishable_cRvnFRyRQST_i8H85kUJtQ_MfrKcMQo');
  final email = 'nguyendangnguyen01010101@gmail.com'; 
  final fakeEmail = 'fake_email_xyzabc_${DateTime.now().millisecondsSinceEpoch}@gmail.com';

  print('Testing real email...');
  try {
    await client.auth.resetPasswordForEmail(email);
    print('resetPasswordForEmail (real) returned success.');
  } catch (e) {
    print('resetPasswordForEmail (real) error: $e');
  }

  print('Testing fake email...');
  try {
    await client.auth.resetPasswordForEmail(fakeEmail);
    print('resetPasswordForEmail (fake) returned success.');
  } catch (e) {
    print('resetPasswordForEmail (fake) error: $e');
  }

  print('Testing signIn for fake email...');
  try {
    await client.auth.signInWithPassword(email: fakeEmail, password: 'fake_password');
    print('signIn (fake) success!');
  } catch (e) {
    print('signIn (fake) error: $e');
  }

  print('Testing signIn for real email with fake password...');
  try {
    await client.auth.signInWithPassword(email: email, password: 'fake_password');
    print('signIn (real email fake pass) success!');
  } catch (e) {
    print('signIn (real email fake pass) error: $e');
  }
}
