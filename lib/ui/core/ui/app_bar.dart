import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class AnimeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnimeAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.star),
          tooltip: 'Favourite',
          onPressed: () {
            Navigator.of(context).pushNamed('/favourites');
          },
        ),
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'History',
          onPressed: () {
            Navigator.of(context).pushNamed('/history');
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.person),
          offset: const Offset(0, kToolbarHeight),
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'exit',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Exit'),
                  ),
                ),
              ],
          onSelected: (String value) {
            if (value == 'exit') {
              UserRepository().logout();
              Navigator.of(context).pushNamed('/');
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
