// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_super_parameters, avoid_print, use_build_context_synchronously, avoid_web_libraries_in_flutter
import 'package:carnival_app1/global/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_existing_member.dart';
import 'package:carnival_app1/global/common/format_id.dart';
import '../group_edit.dart';
import 'package:carnival_app1/features/captain_auth/captain_group_list.dart';

class EditCaptainInfoPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  final String documentID;
  final bool isAdmin;

  const EditCaptainInfoPage({
    Key? key,
    required this.groupDetails,
    required this.documentID,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _EditCaptainInfoPageState createState() => _EditCaptainInfoPageState();
}

class _EditCaptainInfoPageState extends State<EditCaptainInfoPage> {
  late Map<String, dynamic> _updatedGroupDetails;
  late String _previousCaptainEmail;

  @override
  void initState() {
    super.initState();
    _updatedGroupDetails = Map.from(widget.groupDetails);
    _previousCaptainEmail = widget.groupDetails['captain_email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Επεξεργασία Στοιχείων Επικοινωνίας'),
        backgroundColor: Colors.lightBlue[100],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isAdmin)
                GestureDetector(
                  onTap: () {
                    _handlePlusTapped();
                    print(widget.documentID);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Προσθήκη υπάρχων χρήστη',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
              _buildEditableField(
                'Αρχηγός Group',
                'captain',
                TextInputType.text,
                isEditable: widget.isAdmin,
              ),
              Divider(height: 1, color: Colors.grey),
              _buildEditableField(
                'Email Αρχηγού',
                'captain_email',
                TextInputType.emailAddress,
                isEditable: widget.isAdmin,
              ),
              Divider(height: 1, color: Colors.grey),
              _buildEditableField(
                'Τηλέφωνο Επικοινωνίας',
                'captain_tel',
                TextInputType.phone,
              ),
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
    );
  }

  Widget _buildEditableField(
      String title, String fieldKey, TextInputType inputType,
      {bool isEditable = true}) {
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
            initialValue: widget.groupDetails[fieldKey].toString(),
            keyboardType: inputType,
            maxLines: inputType == TextInputType.multiline ? null : 1,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: isEditable
                ? (newValue) {
              _updatedGroupDetails[fieldKey] = newValue;
            }
                : null,
            enabled: isEditable,
          ),
        ],
      ),
    );
  }

  void _handlePlusTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExistingMember(documentID: widget.documentID),
      ),
    );
  }

  void _saveChanges(BuildContext context) async {
    try {
      final newCaptainEmail = _updatedGroupDetails['captain_email'] ?? '';

      if (newCaptainEmail != _previousCaptainEmail) {
        QuerySnapshot oldCaptainSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _previousCaptainEmail)
            .limit(1)
            .get();

        if (oldCaptainSnapshot.docs.isNotEmpty) {
          DocumentSnapshot oldCaptainDoc = oldCaptainSnapshot.docs.first;
          await oldCaptainDoc.reference.update({
            'captain': false,
            'tags': FieldValue.arrayRemove(['captains'])
          });
        }
      }
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(formatDocumentID(widget.documentID))
          .update(_updatedGroupDetails);

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
      showToast(message: "Υπήρξε πρόβλημα κατα την αποθήκευση!");
    }
  }
}
