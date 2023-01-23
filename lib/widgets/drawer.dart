import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                color: AppColors.secondary,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/drawer_bg.png'))),
            child: Text(
              'Kitt+',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Other Projects:'),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.moon_fill),
            title: const Text('Made.llc'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.moon_stars_fill),
            title: const Text('Kitt.one'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.flame_fill),
            title: const Text('Kitt.pro'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}
