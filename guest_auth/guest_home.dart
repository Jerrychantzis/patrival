// ignore_for_file: use_super_parameters, avoid_print, unused_element, deprecated_member_use, prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../user_auth/presentation/widgets/custom_app_bar.dart';
import 'guest_group_list.dart';
import 'guest_live_parade.dart';
import 'guest_notifications.dart';
import 'profile_guest.dart';



class GuestHomePage extends StatefulWidget {
  const GuestHomePage({Key? key}) : super(key: key);

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  String? userIconUrl; // Μεταβλητή για το URL της εικόνας προφίλ
  String? homePageBackgroundUrl;
  String startingHomeString = "Καλώς ήρθατε στην εφαρμογή των καρναβαλικών παρελάσεων!";
  String welcomeMessage = "Η εφαρμογή δημιουργήθηκε με σκοπό την καλύτερη εμπειρία των καρναβαλιστών και την εξυπηρέτηση των αναγκών τους για εύρεση group στην παρέλαση αλλά και παρακολούθηση των groups τις ημέρες των δύο μεγάλων παρελάσεων.\n Περιηγηθείτε στην εφαρμογή , αναζητήστε το group που σας ταιριάζει και σας περιμένουμε όλους στην πρωτεύουσα του Καρναβαλιού και της διασκέδασης! \nΒρείτε μας";
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final PageController _pageController = PageController(initialPage: 2);
  int _page = 2; // Αρχική σελίδα είναι η τρίτη

  // Λίστα χρωμάτων για κάθε σελίδα
  final List<Color> _backgroundColors = [
    Colors.tealAccent,         // Χρώμα για GroupsList
    Colors.green,        // Χρώμα για Estimated Start Times
    Colors.yellow, // Χρώμα για Home
    Colors.purple,       // Χρώμα για Live Broadcast
    Colors.blueGrey,
    // Χρώμα για Profile
  ];

  // Λίστα χρωμάτων για το CurvedNavigationBar
  final List<Color> _navigationBarColors = [
    Colors.tealAccent,         // Χρώμα για GroupsList
    Colors.lightGreenAccent,        // Χρώμα για Estimated Start Times
    Colors.yellow, // Χρώμα για Home
    Colors.purple,       // Χρώμα για Live Broadcast
    Colors.blueGrey,          // Χρώμα για Profile
  ];

  @override
  void initState() {
    super.initState();
    fetchUserIcon();
    fetchHomePageBackground();
  }

  Future<void> fetchHomePageBackground() async {
    try {
      String imageUrl = 'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2F1100_999715f8-9173-4cd5-835a-ec3da4e679a3.jpg?alt=media&token=79c8caea-f246-44c5-9f5e-8151b9696566';

      setState(() {
        homePageBackgroundUrl = imageUrl;
      });
    } catch (e) {
      print('Σφάλμα κατά την ανάκτηση του background image: $e');
    }
  }

  Future<void> fetchUserIcon() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userData.docs.isNotEmpty) {
          setState(() {
            userIconUrl = userData.docs.first['icon'];
          });
        } else {
          print('Δεν βρέθηκε έγγραφο για τον τρέχοντα χρήστη');
        }
      } catch (e) {
        print('Σφάλμα κατά την ανάκτηση της εικόνας προφίλ: $e');
      }
    } else {
      print('Δεν είναι συνδεδεμένος κάποιος χρήστης');
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColors[_page],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _page = index;
            final CurvedNavigationBarState? navBarState = _bottomNavigationKey.currentState;
            navBarState?.setPage(index);
          });
        },
        children: [
          GuestLiveView(),
          GuestGroupsList(),
          Scaffold(
            appBar: CustomAppBar(context: context, heightPercentage: 20),
            body: Container(
              decoration: homePageBackgroundUrl != null
                  ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(homePageBackgroundUrl!),
                  fit: BoxFit.cover,
                ),
                color: Colors.orangeAccent,
              )
                  : null,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0), // Add padding to the left, right, top, and bottom
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                color: Colors.black.withOpacity(0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        startingHomeString,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      welcomeMessage,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: Image.network('https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Ffacebook.png?alt=media&token=56a97a8d-b86f-4adb-bbd5-e0200b1871cd',
                                            width: 45,
                                            height: 45,), // facebook
                                          onPressed: () {
                                            _launchURL('https://www.facebook.com/karnavalipatras/');
                                          },
                                        ),
                                        IconButton(
                                          icon: Image.network('https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Finstagram.png?alt=media&token=b055c978-b7cd-4a85-82ae-2d91534c11d4',
                                            width: 45,
                                            height: 45,), // instagram
                                          onPressed: () {
                                            _launchURL('https://www.instagram.com/carnivalpatras.gr/');
                                          },
                                        ),
                                        IconButton(
                                          icon: Image.network('https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Fyoutube.png?alt=media&token=7eaa8212-7500-4a6f-bb4e-bf056d7d9ce0',
                                            width: 45,
                                            height: 45,), // youtube
                                          onPressed: () {
                                            _launchURL('https://www.youtube.com/channel/UCgTR64A6IXR0mH6rd1Ye2Dg');
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          NotificationsGuest(),
          ProfileGuest(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.access_time, size: 30),
          Icon(Icons.group, size: 30),
          Icon(Icons.home, size: 30),
          Icon(Icons.live_tv, size: 30),
          userIconUrl != null
              ? ClipOval(
            child: Image.network(
              userIconUrl!,
              fit: BoxFit.cover,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 30,
                );
              },
            ),
          )
              : Icon(Icons.person, size: 30),
        ],
        color: Colors.lightBlue,
        buttonBackgroundColor: Colors.lightBlue,
        backgroundColor: _navigationBarColors[_page],
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _page = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
