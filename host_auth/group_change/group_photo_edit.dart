// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, unused_element, use_build_context_synchronously, avoid_print, avoid_function_literals_in_foreach_calls, prefer_final_fields, unnecessary_nullable_for_final_variable_declarations, unused_field

import 'dart:io';
import 'dart:typed_data';
import 'package:carnival_app1/global/common/format_id.dart';
import 'package:carnival_app1/features/host_auth/group_edit.dart';
import 'package:carnival_app1/features/captain_auth/captain_group_list.dart';
import 'package:carnival_app1/global/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class EditPhotosPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  final String documentID;
  final bool isAdmin;

  const EditPhotosPage({
    Key? key,
    required this.groupDetails,
    required this.documentID,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _EditPhotosPageState createState() => _EditPhotosPageState();
}

class _EditPhotosPageState extends State<EditPhotosPage> {
  late Map<String, dynamic> _updatedPhotoDetails;
  bool _uploadImages = false;
  List<File?> _selectedImages = [];
  List<Widget> _thumbnailWidgets = [];
  List<bool> _selectedStates = [];
  String? _selectedThumbnailUrl;

  @override
  void initState() {
    super.initState();
    _updatedPhotoDetails = Map.from(widget.groupDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Επεξεργασία Φωτογραφιών'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),

              shrinkWrap: true,
              itemCount: widget.groupDetails.length,
              itemBuilder: (context, index) {
                String photoKey = widget.groupDetails.keys.elementAt(index);
                if (!photoKey.startsWith('photo_')) {
                  return SizedBox.shrink();
                }
                String photoUrl = widget.groupDetails[photoKey];
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  title: Image.network(
                    photoUrl,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      _deletePhoto(photoKey, photoUrl);
                    },
                    child: Icon(Icons.delete_forever, color: Colors.red),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: Text('Προσθήκη Φωτογραφιών'),
                  ),
                  SizedBox(height: 10),
                  if (_selectedImages
                      .isNotEmpty)
                    SizedBox(
                      height: 200,

                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(_selectedImages[index]!),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(
                                          index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _selectExternalPhoto(context);
                    },
                    child: Text('Επιλογή εξωτερικής φωτογραφίας'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _saveChanges(context);
                    },
                    child: Text('Αποθήκευση Αλλαγών'),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      String folderName = formatDocumentID(widget.documentID);
      bool folderExists = await firebase_storage.FirebaseStorage.instance
          .ref('costumes/$folderName')
          .listAll()
          .then((value) => true)
          .catchError((_) => false);

      if (!folderExists) {
        await firebase_storage.FirebaseStorage.instance
            .ref('costumes/$folderName')
            .putData(Uint8List(0));
      }

      for (int i = 0; i < _selectedImages.length; i++) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        String filePath = 'costumes/$folderName/$fileName';

        await firebase_storage.FirebaseStorage.instance
            .ref(filePath)
            .putFile(_selectedImages[i]!);

        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref(filePath)
            .getDownloadURL();

        if (widget.groupDetails['parade'] == 'both') {
          String photoKey = 'photo_${widget.groupDetails.length - 11 + i}';
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(formatDocumentID(widget.documentID))
              .update({photoKey: downloadURL});
        } else {
          String photoKey = 'photo_${widget.groupDetails.length - 10 + i}';
          await FirebaseFirestore.instance
              .collection('groups')
              .doc(formatDocumentID(widget.documentID))
              .update({photoKey: downloadURL});
        }
      }

      setState(() {
        _uploadImages = true;
      });
      Navigator.pop(context);

      showToastGood(message: "Επιτυχής αλλαγή!");
      Navigator.pop(context);
      if (widget.isAdmin == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GroupsEdit(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CaptainGroupsList(),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      Navigator.pop(context);
      print('Σφάλμα κατά την αποθήκευση αλλαγών: $error');
      showToast(message: "Υπήρξε κάποιο πρόβλημα! Δοκιμάστε ξανά!");
    }
  }

  void _deletePhoto(String photoKeyOfDel, String photoUrlDeletable) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Διαγραφή Φωτογραφίας"),
          content: Text(
              "Είστε σίγουρος ότι θέλετε να διαγράψετε την φωτογραφία;\nΠροσοχή!! Η διαγραφή είναι οριστική και δε θα μπορείτε να την ανακτήσετε μέσω της εφαρμογής."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Διατήρηση",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (widget.groupDetails['parade'] == 'both') {
                    String imageUrl = photoUrlDeletable;
                    String lastPhotoUrl = _updatedPhotoDetails[
                        'photo_${(widget.groupDetails.length) - 12}'];

                    await firebase_storage.FirebaseStorage.instance
                        .refFromURL(imageUrl)
                        .delete();

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(formatDocumentID(widget.documentID))
                        .update({photoKeyOfDel: lastPhotoUrl});

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(formatDocumentID(widget.documentID))
                        .update({
                      'photo_${(widget.groupDetails.length) - 12}':
                          FieldValue.delete()
                    });

                    if (_updatedPhotoDetails['thumbnail'] ==
                        photoUrlDeletable) {
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(formatDocumentID(widget.documentID))
                          .update({'thumbnail': ''});
                    }
                  } else {
                    String imageUrl = photoUrlDeletable;
                    String lastPhotoUrl = _updatedPhotoDetails[
                        'photo_${(widget.groupDetails.length) - 11}'];

                    // Διαγράφουμε τη φωτογραφία από το storage
                    await firebase_storage.FirebaseStorage.instance
                        .refFromURL(imageUrl)
                        .delete();

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(formatDocumentID(widget.documentID))
                        .update({photoKeyOfDel: lastPhotoUrl});

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(formatDocumentID(widget.documentID))
                        .update({
                      'photo_${(widget.groupDetails.length) - 11}':
                          FieldValue.delete()
                    });

                    // Έλεγχος αν το URL της διαγραμμένης φωτογραφίας είναι το ίδιο με το thumbnail
                    if (_updatedPhotoDetails['thumbnail'] ==
                        photoUrlDeletable) {
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(formatDocumentID(widget.documentID))
                          .update({'thumbnail': ''});
                    }
                  }
                  showToastGood(message: "Η φωτογραφία διαγράφθηκε!");
                  Navigator.pop(context);
                  if (widget.isAdmin == true) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupsEdit(),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CaptainGroupsList(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (error) {
                  showToast(
                      message:
                          'Υπήρξε κάποιο πρόβλημα κατά τη διαγραφή της φωτογραφίας!');
                  print("Σφάλμα κατά τη διαγραφή της φωτογραφίας: $error");
                }
              },
              child: Text(
                "Διαγραφή",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _pickImages() async {
    final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _uploadImages = false;
      });

      for (var image in selectedImages) {
        _selectedImages.add(File(image.path));
      }
    }
  }

  void _selectExternalPhoto(BuildContext context) {
    String? initialThumbnailUrl = _selectedThumbnailUrl;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(30),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.groupDetails.length,
                        itemBuilder: (context, index) {
                          String photoKey =
                              widget.groupDetails.keys.elementAt(index);
                          if (!photoKey.startsWith('photo_')) {
                            return SizedBox.shrink();
                          }
                          String photoUrl = widget.groupDetails[photoKey];
                          return ListTile(
                            title: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedThumbnailUrl == photoUrl
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Image.network(
                                photoUrl,
                                width: 250,
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                            ),
                            selected: _selectedThumbnailUrl == photoUrl,
                            onTap: () {
                              setState(() {
                                _selectedThumbnailUrl = photoUrl;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedThumbnailUrl = initialThumbnailUrl;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text("Ακύρωση"),
                        ),
                        TextButton(
                          onPressed: _selectedThumbnailUrl == null
                              ? null
                              : () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(
                                            formatDocumentID(widget.documentID))
                                        .update({
                                      'thumbnail': _selectedThumbnailUrl
                                    });

                                    Navigator.of(context).pop();
                                    showToastGood(
                                        message:
                                            "Η εξωτερική φωτογραφία επιλέχθηκε επιτυχώς!");
                                  } catch (error) {
                                    Navigator.of(context).pop();
                                    showToast(
                                        message:
                                            "Υπήρξε κάποιο πρόβλημα! Δοκιμάστε ξανά!");
                                  }
                                },
                          child: Text("Αποθήκευση"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
