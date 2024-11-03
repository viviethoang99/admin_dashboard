import 'package:flutter/material.dart';

import 'reponsiveness.dart';

class IrhDrawer extends StatelessWidget {
  const IrhDrawer({
    super.key,
    required this.content,
  });

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ResponsiveWidget(
          largeScreen: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const _CustomDrawerHeader(),
                ListTile(
                  leading: const Icon(Icons.create),
                  title: const Text('Tạo bài viết'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('Danh sách bài viết'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Media Library'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          smallScreen: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const _CustomDrawerHeader(),
                ListTile(
                  leading: const Icon(Icons.create),
                  title: const Text('Tạo bài viết'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('Danh sách bài viết'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Media Library'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: content,
        ),
      ],
    );
  }
}

class _CustomDrawerHeader extends StatelessWidget {
  const _CustomDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(0),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            // backgroundImage: AssetImage('assets/images/irohasu.png'),
          ),
          SizedBox(width: 10),
          Text(
            'Irohasu Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
