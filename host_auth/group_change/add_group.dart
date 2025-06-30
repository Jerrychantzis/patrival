// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields, unnecessary_nullable_for_final_variable_declarations, unused_field, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, use_build_context_synchronously, sort_child_properties_last

import 'dart:io';

import 'package:carnival_app1/global/common/format_id.dart';
import 'package:carnival_app1/global/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:carnival_app1/features/host_auth/admin_home.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({Key? key}) : super(key: key);

  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNumberController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captainController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _meetingPointController = TextEditingController();
  final TextEditingController _memberCountController = TextEditingController();
  final TextEditingController _queueController = TextEditingController();
  final TextEditingController _queue_2Controller = TextEditingController();

  List<String> _imageUrls = [];
  bool _uploadImages = false;
  bool _isAddingGroup = false;
  List<File> _selectedImages = [];
  String noImageSelect =
      'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Fno_image.jpg?alt=media&token=90c83f0b-35ce-455d-aa27-15e7e3f4daf9';
  String noThumbnail = '';
  String _selectedParade = 'sunday';
  bool _arma = false;

  @override
  void dispose() {
    _groupNumberController.dispose();
    _titleController.dispose();
    _captainController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _meetingPointController.dispose();
    _memberCountController.dispose();
    _queueController.dispose();
    _queue_2Controller.dispose();
    super.dispose();
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

  Future<void> completeRegisterNoPhoto() async {
    String formattedGroup = formatDocumentID(_groupNumberController.text);
    setState(() {
      _isAddingGroup = true;
    });

    try {
      if (_selectedParade == 'both') {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(formattedGroup)
            .set({
          'title': _titleController.text,
          'captain': _captainController.text,
          'captain_email': _emailController.text,
          'captain_tel': _phoneController.text,
          'description': _descriptionController.text,
          'meeting_point': _meetingPointController.text,
          'member_count': int.parse(_memberCountController.text),
          'queue': int.parse(_queueController.text),
          'queue_2': int.parse(_queue_2Controller.text),
          'parade': _selectedParade,
          'arma': _arma,
          'thumbnail': noThumbnail,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(formattedGroup)
            .set({
          'title': _titleController.text,
          'captain': _captainController.text,
          'captain_email': _emailController.text,
          'captain_tel': _phoneController.text,
          'description': _descriptionController.text,
          'meeting_point': _meetingPointController.text,
          'member_count': int.parse(_memberCountController.text),
          'queue': int.parse(_queueController.text),
          'parade': _selectedParade,
          'arma': _arma,
          'thumbnail': noThumbnail,
        });
      }

      if (_selectedParade == 'saturday') {
        await FirebaseFirestore.instance
            .collection('saturday_parade')
            .doc(formattedGroup)
            .set({
          'queue': int.parse(_queueController.text),
          'member_count': int.parse(_memberCountController.text),
          'started': false,
          'completed': false,
          'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
          'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
        });
      } else if (_selectedParade == 'sunday') {
        await FirebaseFirestore.instance
            .collection('sunday_parade')
            .doc(formattedGroup)
            .set({
          'queue': int.parse(_queueController.text),
          'member_count': int.parse(_memberCountController.text),
          'started': false,
          'completed': false,
          'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
          'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
          'arma': _arma,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('saturday_parade')
            .doc(formattedGroup)
            .set({
          'queue': int.parse(_queueController.text),
          'member_count': int.parse(_memberCountController.text),
          'started': false,
          'completed': false,
          'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
          'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
        });
        await FirebaseFirestore.instance
            .collection('sunday_parade')
            .doc(formattedGroup)
            .set({
          'queue_2': int.parse(_queue_2Controller.text),
          'member_count': int.parse(_memberCountController.text),
          'started': false,
          'completed': false,
          'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
          'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
          'arma': _arma,
        });
      }

      showToastGood(message: "Επιτυχής δημιουργία Γκρουπ!");
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showToast(message: "Σφάλμα κατά την προσθήκη του Group: $e");
    }
  }

  Future<void> _addGroup() async {
    if (_formKey.currentState!.validate()) {
      String formattedGroup = formatDocumentID(_groupNumberController.text);

      try {
        final groupDoc = await FirebaseFirestore.instance
            .collection('groups')
            .doc(formattedGroup)
            .get();
        if (groupDoc.exists) {
          showToast(
              message: "Το group που προσπαθείτε να προσθέσετε υπάρχει ήδη");
          return;
        }

        if (_selectedParade == 'saturday') {
          final queueQuery = await FirebaseFirestore.instance
              .collection('saturday_parade')
              .where('queue', isEqualTo: int.parse(_queueController.text))
              .get();
          if (queueQuery.docs.isNotEmpty) {
            showToast(
                message:
                    "Σε αυτή τη θέση της παρέλασης υπάρχει ήδη κάποιο group");
            return;
          }
        } else if (_selectedParade == 'sunday') {
          final queueQuery = await FirebaseFirestore.instance
              .collection('sunday_parade')
              .where('queue', isEqualTo: int.parse(_queueController.text))
              .get();
          if (queueQuery.docs.isNotEmpty) {
            showToast(
                message:
                    "Σε αυτή τη θέση της παρέλασης υπάρχει ήδη κάποιο group");
            return;
          }
        } else {
          final queueQuery = await FirebaseFirestore.instance
              .collection('saturday_parade')
              .where('queue', isEqualTo: int.parse(_queueController.text))
              .get();
          if (queueQuery.docs.isNotEmpty) {
            showToast(
                message:
                    "Σε αυτή τη θέση της παρέλασης υπάρχει ήδη κάποιο group(Παρέλαση Σαββάτου)");
            return;
          }
          final queue2Query = await FirebaseFirestore.instance
              .collection('sunday_parade')
              .where('queue', isEqualTo: int.parse(_queue_2Controller.text))
              .get();
          if (queue2Query.docs.isNotEmpty) {
            showToast(
                message:
                    "Σε αυτή τη θέση της παρέλασης υπάρχει ήδη κάποιο group(Παρέλαση Κυριακής)");
            return;
          }
        }

        if (_selectedImages.isNotEmpty) {
          setState(() {
            _isAddingGroup = true;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Δημιουργία γκρουπ..."),
                  ],
                ),
              );
            },
          );

          if (_selectedParade == 'both') {
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(formattedGroup)
                .set({
              'title': _titleController.text,
              'captain': _captainController.text,
              'captain_email': _emailController.text,
              'captain_tel': _phoneController.text,
              'description': _descriptionController.text,
              'meeting_point': _meetingPointController.text,
              'member_count': int.parse(_memberCountController.text),
              'queue': int.parse(_queueController.text),
              'queue_2': int.parse(_queue_2Controller.text),
              'parade': _selectedParade,
              'arma': _arma,
              'thumbnail': noThumbnail
            });
          } else {
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(formattedGroup)
                .set({
              'title': _titleController.text,
              'captain': _captainController.text,
              'captain_email': _emailController.text,
              'captain_tel': _phoneController.text,
              'description': _descriptionController.text,
              'meeting_point': _meetingPointController.text,
              'member_count': int.parse(_memberCountController.text),
              'queue': int.parse(_queueController.text),
              'parade': _selectedParade,
              'arma': _arma,
              'thumbnail': noThumbnail
            });
          }
          _uploadImagesToStorage();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomePage(),
            ),
                (route) => false,
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Προσθήκη Group"),
                content: Text(
                    "Δεν έχετε επιλέξει κάποια φωτογραφία.Θέλετε να συνεχίσετε;"),
                actions: <Widget>[
                  TextButton(
                    child: Text("ΟΧΙ"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("ΝΑΙ"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      completeRegisterNoPhoto();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        showToast(message: "Σφάλμα κατά την επαλήθευση του Group: $e");
      }
    }
  }

  void _uploadImagesToStorage() {
    String formattedGroup = formatDocumentID(_groupNumberController.text);
    if (_selectedImages.isNotEmpty) {
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('costumes/${formattedGroup}');

      for (var i = 0; i < _selectedImages.length; i++) {
        final File image = _selectedImages[i];
        final firebase_storage.UploadTask uploadTask = storageRef
            .child('${DateTime.now().millisecondsSinceEpoch}_$i.jpg')
            .putFile(image);

        uploadTask.then((firebase_storage.TaskSnapshot snapshot) async {
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          setState(() {
            _imageUrls.add(downloadUrl);
          });

          if (i == _selectedImages.length - 1) {
            FirebaseFirestore.instance
                .collection('groups')
                .doc(formattedGroup)
                .update({
              for (var j = 0; j < _imageUrls.length; j++)
                'photo_${j + 1}': _imageUrls[j],
            }).then((_) async {
              if (_selectedParade == 'saturday') {
                await FirebaseFirestore.instance
                    .collection('saturday_parade')
                    .doc(formattedGroup)
                    .set({
                  'queue': int.parse(_queueController.text),
                  'member_count': int.parse(_memberCountController.text),
                  'started': false,
                  'completed': false,
                  'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                  'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                });
              } else if (_selectedParade == 'sunday') {
                await FirebaseFirestore.instance
                    .collection('sunday_parade')
                    .doc(formattedGroup)
                    .set({
                  'queue': int.parse(_queueController.text),
                  'member_count': int.parse(_memberCountController.text),
                  'started': false,
                  'completed': false,
                  'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                  'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                  'arma': _arma,
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('saturday_parade')
                    .doc(formattedGroup)
                    .set({
                  'queue': int.parse(_queueController.text),
                  'member_count': int.parse(_memberCountController.text),
                  'started': false,
                  'completed': false,
                  'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                  'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                });
                await FirebaseFirestore.instance
                    .collection('sunday_parade')
                    .doc(formattedGroup)
                    .set({
                  'queue': int.parse(_queueController.text),
                  'member_count': int.parse(_memberCountController.text),
                  'started': false,
                  'completed': false,
                  'started_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                  'finished_at': Timestamp.fromDate(DateTime(2024, 1, 1, 0, 0)),
                  'arma': _arma,
                });
              }

              Navigator.of(context, rootNavigator: true).pop();
              showToastGood(message: "Το Group προστέθηκε με επιτυχία!");
              _groupNumberController.clear();
              _titleController.clear();
              _captainController.clear();
              _emailController.clear();
              _phoneController.clear();
              _descriptionController.clear();
              _meetingPointController.clear();
              _memberCountController.clear();
              _queueController.clear();
              setState(() {
                _selectedImages.clear();
                _uploadImages = true;
              });
            }).catchError((error) {
              Navigator.of(context, rootNavigator: true).pop();
              showToast(message: 'Σφάλμα κατά την αποθήκευση των URLs: $error');
            });
          }
        }).catchError((error) {
          Navigator.of(context, rootNavigator: true).pop();
          showToast(message: 'Σφάλμα κατά τη μεταφόρτωση της εικόνας: $error');
        });
      }
    } else {
      setState(() {
        _isAddingGroup = false;
      });
    }
  }

  String dayOfParade(String selectedParade) {
    if (selectedParade == "sunday") {
      return "Κυριακής";
    } else {
      return "Σαββάτου";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Προσθήκη Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _groupNumberController,
                decoration: InputDecoration(labelText: 'Αριθμός Group'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε τον αριθμό του Group';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Τίτλος Group'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε τον τίτλο του Group';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _captainController,
                decoration: InputDecoration(labelText: 'Αρχηγός'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε το όνομα του αρχηγού';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email Αρχηγού'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε το email του αρχηγού';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Τηλέφωνο Αρχηγού'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε το τηλέφωνο του αρχηγού';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Περιγραφή'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε μια περιγραφή του Group';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _meetingPointController,
                decoration: InputDecoration(labelText: 'Σημείο Συνάντησης'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε το σημείο συνάντησης';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _memberCountController,
                decoration:
                    InputDecoration(labelText: 'Αριθμός Μελών (εώς τώρα)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε τον αριθμό των μελών';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _queueController,
                decoration: InputDecoration(
                    labelText:
                        'Σειρά εμφάνισης Group ${dayOfParade(_selectedParade)}'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε τη σειρά εμφάνισης στην παρέλαση!';
                  }
                  return null;
                },
              ),
              if (_selectedParade == 'both')
                TextFormField(
                  controller: _queue_2Controller,
                  decoration: InputDecoration(
                      labelText: 'Σειρά εμφάνισης Group Κυριακής'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Παρακαλώ εισάγετε τη σειρά εμφάνισης στην 2η παρέλαση!';
                    }
                    return null;
                  },
                ),
              DropdownButtonFormField<String>(
                value: _selectedParade,
                items: [
                  DropdownMenuItem(
                    child: Text('Κυριακή'),
                    value: 'sunday',
                  ),
                  DropdownMenuItem(
                    child: Text('Σάββατο'),
                    value: 'saturday',
                  ),
                  DropdownMenuItem(
                    child: Text('Και στις δύο'),
                    value: 'both',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedParade = value!;
                    if (_selectedParade == 'saturday') {
                      _arma = false;
                    }
                  });
                },
                decoration: InputDecoration(labelText: 'Παρέλαση'),
              ),
                CheckboxListTile(
                  title: Text('Το group διαθέτει άρμα.(Παρέλαση Κυριακής)'),
                  value: _arma,
                  onChanged: (_selectedParade == 'saturday')
                      ? null
                      : (bool? value) {
                          setState(() {
                            _arma = value!;
                          });
                        },
                ),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Επιλέξτε Φωτογραφίες'),
              ),
              if (_selectedImages.isNotEmpty)
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
                            child: Image.file(_selectedImages[index]),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
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
              ElevatedButton(
                onPressed: _addGroup,
                child: Text('Προσθήκη του Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
