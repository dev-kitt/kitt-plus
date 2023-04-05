import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

final Uri _url1 = Uri.parse('https://kitt.llc');
final Uri _url2 = Uri.parse('https://kitt.one');
final Uri _url3 = Uri.parse('https://github.com/standard-made/kitt-plus');
final Uri _url4 = Uri.parse('https://kitt.pro');

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                color: AppColors.secondary,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/drawer_bg.png'))),
            child: Text(
              '°ƀ.',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Other Projects:'),
          ),
          ListTile(
            leading: Icon(CupertinoIcons.moon),
            title: Text('Kitt.llc'),
            onTap: _launchUrl1,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.moon_fill),
            title: Text('Kitt.one'),
            onTap: _launchUrl2,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.moon_zzz_fill),
            title: Text('Kitt.plus'),
            onTap: _launchUrl3,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.moon_stars_fill),
            title: Text('Kitt.pro'),
            onTap: _launchUrl4,
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl1() async {
  if (!await launchUrl(_url1)) {
    throw Exception('Could not launch $_url1');
  }
}

Future<void> _launchUrl2() async {
  if (!await launchUrl(_url2)) {
    throw Exception('Could not launch $_url2');
  }
}

Future<void> _launchUrl3() async {
  if (!await launchUrl(_url3)) {
    throw Exception('Could not launch $_url3');
  }
}

Future<void> _launchUrl4() async {
  if (!await launchUrl(_url4)) {
    throw Exception('Could not launch $_url4');
  }
}
