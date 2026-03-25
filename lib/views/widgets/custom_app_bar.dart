import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTapped;
  final VoidCallback? onAvatarTapped;
  final int unreadCount;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onNotificationTapped,
    this.onAvatarTapped,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final displayName = (user?.fullName != null && user!.fullName.trim().isNotEmpty) ? user.fullName : 'Khách';
    final initials = (user?.firstName != null && user!.firstName!.isNotEmpty) 
        ? user.firstName![0].toUpperCase() 
        : (displayName != 'Khách' ? displayName[0].toUpperCase() : '?');

    return AppBar(
      title: Text('Xin chào, $displayName', style: AppTextStyles.h2),
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: onNotificationTapped,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.background,
                shape: const CircleBorder(),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
