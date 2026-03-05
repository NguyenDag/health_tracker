import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

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
    return AppBar(
      title: Text(title, style: AppTextStyles.h2),
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: GestureDetector(
          onTap: onAvatarTapped,
          child: const CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            // Replace with actual user image later
            child: Icon(Icons.person, color: AppColors.primary),
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
