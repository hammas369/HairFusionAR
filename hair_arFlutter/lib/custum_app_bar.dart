import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? photoUrl;
  final VoidCallback onSignOut;

  const MyAppBar({
    super.key,
    required this.title,
    required this.photoUrl,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(236, 207, 251, 1),
      title: Row(
        children: [
          // Circle Image on the left
          if (photoUrl != null)
            CircleAvatar(
              radius: 20, // Adjust size as needed
              backgroundImage: NetworkImage(photoUrl!),
            ),
          const SizedBox(width: 10), // Space between image and text
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis, // Ensures long titles fit
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Sign-out button on the right
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onSignOut,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
