// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_print, prefer_const_constructors, sized_box_for_whitespace, prefer_const_constructors_in_immutables, use_super_parameters, use_build_context_synchronously

import 'package:carnival_app1/features/user_auth/presentation/pages/home_page.dart';
import 'package:carnival_app1/global/common/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AvatarChange extends StatefulWidget {
  final String? currentIconUrl;
  final String? username;

  AvatarChange({Key? key, this.currentIconUrl, this.username})
      : super(key: key);

  @override
  _AvatarChangeState createState() => _AvatarChangeState();
}

class _AvatarChangeState extends State<AvatarChange> {
  List<String> imageUrls = [];
  String selectedImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchAvatarIcons();
    selectedImageUrl = widget.currentIconUrl ?? '';
  }

  Future<void> fetchAvatarIcons() async {
    try {
      ListResult result = await FirebaseStorage.instance.ref('icons').listAll();

      List<Future<String>> futures = result.items.map((item) {
        return item.getDownloadURL();
      }).toList();

      List<String> urls = await Future.wait(futures);

      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      print('Σφάλμα κατά την ανάκτηση των εικόνων προφίλ: $e');
    }
  }

  Future<void> _onSelectionButtonPressed(BuildContext context) async {
    if (selectedImageUrl.isNotEmpty) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: widget.username)
            .get()
            .then((QuerySnapshot querySnapshot) {
          return querySnapshot.docs.first;
        });

        if (userData.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userData.id)
              .update({'icon': selectedImageUrl});

          // Επιστροφή στη σελίδα προφίλ με το νέο εικονίδιο
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (route) => false,
          );
          showToastGood(message: "Επιτυχής αλλαγή avatar!.");
        } else {
          print(
              'Δεν βρέθηκε έγγραφο για τον χρήστη με το όνομα: ${widget.username}');
        }
      } catch (e) {
        print('Σφάλμα κατά την ενημέρωση του εικονιδίου του χρήστη: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Επιλογή Εικόνας'),
      ),
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Stack(
            children: [
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImageUrl = imageUrls[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedImageUrl == imageUrls[index]
                              ? Colors.blue
                              : Colors.black,
                          width:
                              selectedImageUrl == imageUrls[index] ? 3.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 10.0,
                right: 10.0,
                child: ElevatedButton(
                  onPressed: selectedImageUrl.isNotEmpty
                      ? () => _onSelectionButtonPressed(context)
                      : null,
                  child: Text('Επιλογή'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
