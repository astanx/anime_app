import 'package:flutter/material.dart';

class AnimeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnimeAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.star),
          tooltip: 'Favourite',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'History',
          onPressed: () {
            Navigator.of(context).pushNamed('/history');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
