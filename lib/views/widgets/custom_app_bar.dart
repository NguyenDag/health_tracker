import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTapped;
  final VoidCallback? onAvatarTapped;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onNotificationTapped,
    this.onAvatarTapped,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final displayName = (user?.fullName != null && user!.fullName.trim().isNotEmpty) ? user.fullName : 'Guest';
    final initials = (user?.firstName != null && user!.firstName!.isNotEmpty) 
        ? user.firstName![0].toUpperCase() 
        : (displayName != 'Guest' ? displayName[0].toUpperCase() : '?');

    return AppBar(
      title: Text('Hi, $displayName 👋', style: AppTextStyles.h2),
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: GestureDetector(
          onTap: onAvatarTapped,
          child: CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: onNotificationTapped,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.background,
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
