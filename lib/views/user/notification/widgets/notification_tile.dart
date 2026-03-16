import 'package:flutter/material.dart';

class NotificationTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final String? badge;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
    this.onTap,
    this.badge,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });

        widget.onTap?.call();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TIMELINE
          SizedBox(
            width: 50,
            child: Column(
              children: [
                if (!widget.isFirst)
                  Container(
                    height: 20,
                    width: 2,
                    color: Colors.grey.shade300,
                  )
                else
                  const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 20,
                  ),
                ),

                if (!widget.isLast)
                  Container(
                    height: 40,
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
          ),

          /// CONTENT
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: widget.isRead
                    ? Colors.transparent
                    : Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE + BADGE
                  Row(
                    children: [
                      if (!widget.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),

                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontWeight: widget.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 16,
                            color: widget.isRead
                                ? Colors.grey[700]
                                : Colors.black,
                          ),
                        ),
                      ),

                      if (widget.badge != null)
                        Text(
                          widget.badge!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// SUBTITLE
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: expanded
                        ? Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.subtitle,
                        style: const TextStyle(fontSize: 14),
                      ),
                    )
                        : const SizedBox(),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}