// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, deprecated_member_use, use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../global/common/toast.dart';
import 'add_member.dart';
import 'delete_member.dart';
import '../group_edit.dart';
import 'package:carnival_app1/global/common/format_id.dart';
import 'package:carnival_app1/features/captain_auth/captain_group_list.dart';

class EditGroupInfoPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  final String documentID;
  final bool isAdmin;

  const EditGroupInfoPage({
    Key? key,
    required this.groupDetails,
    required this.documentID,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _EditGroupInfoPageState createState() => _EditGroupInfoPageState();
}

class _EditGroupInfoPageState extends State<EditGroupInfoPage> {
  late Map<String, dynamic> _updatedGroupDetails;

  @override
  void initState() {
    super.initState();
    _updatedGroupDetails = Map.from(widget.groupDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Επεξεργασία Πληροφοριών Ομάδας'),
        backgroundColor: Colors.lightBlue[100],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditableField(
                  'Αριθμός Μελών',
                  'member_count',
                  TextInputType.number,
                  showAddButton: true,
                  showRemoveButton:
                      true,
                ),
                Divider(height: 1, color: Colors.grey),
                _buildEditableField(
                    'Τίτλος Group', 'title', TextInputType.text),
                Divider(height: 1, color: Colors.grey),
                _buildEditableField(
                    'Περιγραφή Group', 'description', TextInputType.multiline),
                Divider(height: 1, color: Colors.grey),
                _buildEditableField(
                    'Σημείο Συνάντησης', 'meeting_point', TextInputType.text),
                Divider(height: 1, color: Colors.grey),
                _buildEditableField('Παρέλαση', 'parade', TextInputType.text,
                    isDropdown: true,
                    dropdownItems: ['sunday', 'saturday', 'both']),
                Divider(height: 1, color: Colors.grey),
                _buildEditableField('Άρμα', 'arma', TextInputType.text,
                    isSwitch: true),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveChanges(context);
                    },
                    child: Text('Αποθήκευση Αλλαγών'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String title, String fieldKey, TextInputType inputType,
      {bool showAddButton = false,
      bool showRemoveButton = false,
      bool isDropdown = false,
      List<String>? dropdownItems,
      bool isSwitch = false}) {
    if (isDropdown && dropdownItems != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: _updatedGroupDetails[fieldKey],
              items: dropdownItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _updatedGroupDetails[fieldKey] = newValue;

                  if (fieldKey == 'parade' && newValue == 'saturday') {
                    _updatedGroupDetails['arma'] = false;
                  }
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      );
    } else if (isSwitch) {
      bool isDisabled = _updatedGroupDetails['parade'] == 'saturday';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 10),
            Switch(
              value: _updatedGroupDetails[fieldKey] ?? false,
              onChanged: isDisabled
                  ? null
                  : (newValue) {
                      setState(() {
                        _updatedGroupDetails[fieldKey] = newValue;
                      });
                    },
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              initialValue: _updatedGroupDetails[fieldKey].toString(),
              keyboardType: inputType,
              maxLines: inputType == TextInputType.multiline ? null : 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                setState(() {
                  _updatedGroupDetails[fieldKey] = inputType ==
                          TextInputType.number
                      ? int.tryParse(newValue) ?? widget.groupDetails[fieldKey]
                      : newValue;
                });
              },
            ),
            SizedBox(height: 10),
            if (showAddButton || showRemoveButton)
              Column(
                children: [
                  if (showAddButton)
                    ElevatedButton(
                      onPressed: () async {
                        bool refresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMember(
                                groupId: widget.documentID,
                                isAdmin: widget.isAdmin),
                          ),
                        );

                        if (refresh == true) {
                          setState(() {
                            _updatedGroupDetails['member_count'] =
                                (_updatedGroupDetails['member_count'] as int) +
                                    1;
                          });
                        }
                      },
                      child: Text('Προσθήκη Χρηστών'),
                    ),
                  SizedBox(height: 10),
                  if (showRemoveButton)
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeleteMember(
                                groupId: widget.documentID,
                                isAdmin: widget.isAdmin),
                          ),
                        );
                      },
                      child: Text('Αφαίρεση Χρηστών'),
                    ),
                ],
              ),
          ],
        ),
      );
    }
  }

  Future<void> _updateSundayParadeMemberCount(int memberCount) async {
    try {
      await FirebaseFirestore.instance
          .collection('sunday_parade')
          .doc(formatDocumentID(widget.documentID))
          .update({'member_count': memberCount});
      print('Το member_count ενημερώθηκε με επιτυχία στο sunday_parade.');
    } catch (error) {
      print(
          'Σφάλμα κατά την ενημέρωση του member_count στο sunday_parade: $error');
    }
  }

  Future<void> _updateSaturdayParadeMemberCount(int memberCount) async {
    try {
      await FirebaseFirestore.instance
          .collection('saturday_parade')
          .doc(formatDocumentID(widget.documentID))
          .update({'member_count': memberCount});
      print('Το member_count ενημερώθηκε με επιτυχία στο saturday_parade.');
    } catch (error) {
      print(
          'Σφάλμα κατά την ενημέρωση του member_count στο saturday_parade: $error');
    }
  }

  Future<void> _updateSundayParadeArma(bool armaNew) async {
    try {
      await FirebaseFirestore.instance
          .collection('sunday_parade')
          .doc(formatDocumentID(widget.documentID))
          .update({'arma': armaNew});
      print('Το arma ενημερώθηκε με επιτυχία στο sunday_parade.');
    } catch (error) {
      print('Σφάλμα κατά την ενημέρωση του arma στο sunday_parade: $error');
    }
  }

  Future<void> _deleteDocumentFromCollection(String collection) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(formatDocumentID(widget.documentID))
          .delete();
      print('Το έγγραφο διαγράφηκε με επιτυχία από το $collection.');
    } catch (error) {
      print('Σφάλμα κατά την διαγραφή του εγγράφου από το $collection: $error');
    }
  }

  Future<void> _createDocumentInCollection(String collection) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(collection)
          .doc(formatDocumentID(widget.documentID));
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        final groupDocRef = FirebaseFirestore.instance
            .collection('groups')
            .doc(formatDocumentID(widget.documentID));

        final groupDocSnapshot = await groupDocRef.get();

        if (groupDocSnapshot.exists) {
          final queue = groupDocSnapshot.data()?['queue'];
          Map<String, dynamic> data = {
            'member_count': _updatedGroupDetails['member_count'],
            'queue': queue,
            'started': false,
            'completed': false,
            'started_at': Timestamp.now(),
            'finished_at': Timestamp.now(),
          };

          if (_updatedGroupDetails['parade'] == 'sunday') {
            data['arma'] = _updatedGroupDetails['arma'];
          } else if (_updatedGroupDetails['parade'] == 'both' &&
              collection == 'sunday_parade') {
            data['arma'] = _updatedGroupDetails['arma'];
          }

          await docRef.set(data);
          print('Το έγγραφο δημιουργήθηκε με επιτυχία στο $collection.');
        } else {
          print('Το έγγραφο δεν βρέθηκε στη συλλογή groups.');
        }
      } else {
        print(
            'Το έγγραφο υπάρχει ήδη στο $collection και δεν θα δημιουργηθεί ξανά.');
      }
    } catch (error) {
      print('Σφάλμα κατά την δημιουργία του εγγράφου στο $collection: $error');
    }
  }

  void _saveChanges(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(formatDocumentID(widget.documentID))
          .update(_updatedGroupDetails);

      String parade = _updatedGroupDetails['parade'];

      if (parade == 'sunday') {
        await _deleteDocumentFromCollection('saturday_parade');
        await _createDocumentInCollection('sunday_parade');
        if (_updatedGroupDetails.containsKey('member_count')) {
          await _updateSundayParadeMemberCount(
              _updatedGroupDetails['member_count']);
        }
        if (_updatedGroupDetails.containsKey('arma')) {
          await _updateSundayParadeArma(_updatedGroupDetails['arma']);
        }
      } else if (parade == 'saturday') {
        await _deleteDocumentFromCollection('sunday_parade');
        await _createDocumentInCollection('saturday_parade');
        if (_updatedGroupDetails.containsKey('member_count')) {
          await _updateSaturdayParadeMemberCount(
              _updatedGroupDetails['member_count']);
        }
      } else if (parade == 'both') {
        await _createDocumentInCollection('sunday_parade');
        await _createDocumentInCollection('saturday_parade');
        await _updateSundayParadeMemberCount(
            _updatedGroupDetails['member_count']);
        if (_updatedGroupDetails.containsKey('member_count')) {
          await _updateSundayParadeMemberCount(
              _updatedGroupDetails['member_count']);
          await _updateSaturdayParadeMemberCount(
              _updatedGroupDetails['member_count']);
        }
        if (_updatedGroupDetails.containsKey('arma')) {
          await _updateSundayParadeArma(_updatedGroupDetails['arma']);
        }
      }

      showToastGood(message: "Οι αλλαγές αποθηκεύτηκαν");

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
    } catch (e) {
      print('Σφάλμα κατά την ενημέρωση της βάσης δεδομένων: $e');
      showToast(message: "Υπήρξε πρόβλημα κατά την αποθήκευση!");

      Navigator.pop(context);
    }
  }
}
