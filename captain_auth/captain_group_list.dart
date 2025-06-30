// ignore_for_file: prefer_const_constructors, use_super_parameters, avoid_print, sort_child_properties_last, use_build_context_synchronously, await_only_futures, prefer_final_fields, unnecessary_cast
import 'package:carnival_app1/features/user_auth/presentation/pages/group_details.dart';
import 'package:carnival_app1/global/common/format_id.dart';
import 'captain_group_change.dart';
import 'captain_home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaptainGroupsList extends StatefulWidget {
  const CaptainGroupsList({Key? key}) : super(key: key);

  @override
  State<CaptainGroupsList> createState() => _CaptainGroupsListState();
}

class _CaptainGroupsListState extends State<CaptainGroupsList> {
  String _searchQuery = '';
  String _groupId = '';
  Map<String, dynamic>? _groupDetails;
  String errorMessage = '';
  bool _isAdmin = false;
  String _filter = 'Όλα τα groups';

  @override
  void initState() {
    super.initState();
    fetchGroupDetailsForCurrentUser();
  }

  Future<void> fetchGroupDetailsForCurrentUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;
          _groupId = userDoc['group'].toString();

          DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
              .collection('groups')
              .doc(formatDocumentID(_groupId))
              .get();

          if (groupSnapshot.exists) {
            setState(() {
              _groupDetails = groupSnapshot.data() as Map<String, dynamic>?;
            });
          } else {
            setState(() {
              errorMessage = 'Το συγκεκριμένο έγγραφο δεν υπάρχει.';
            });
          }
        } else {
          setState(() {
            errorMessage = 'Δεν βρέθηκαν δεδομένα για τον χρήστη';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Δεν είναι συνδεδεμένος κάποιος χρήστης';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Σφάλμα κατά την ανάκτηση των δεδομένων: $e';
      });
    }
  }

  void updateSearchQuery(String value) {
    setState(() {
      _searchQuery = reverseFormatDocumentID(value);
    });
  }

  void updateFilter(String value) {
    setState(() {
      _filter = value;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Επιλέξτε Φίλτρο'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Όλα τα groups'),
                onTap: () {
                  updateFilter('Όλα τα groups');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Groups Σαββάτου'),
                onTap: () {
                  updateFilter('saturday');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Groups Κυριακής'),
                onTap: () {
                  updateFilter('sunday');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Groups και των δύο παρελάσεων'),
                onTap: () {
                  updateFilter('both');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onGroupTapped(String groupId, DocumentSnapshot groupSnapshot) {
    if (groupSnapshot.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupDetailsPage(
            groupDetails: groupSnapshot.data()! as Map<String, dynamic>,
            documentID: reverseFormatDocumentID(groupId),
          ),
        ),
      );
    } else {
      print('Το συγκεκριμένο έγγραφο δεν υπάρχει.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const String noImageSelect =
        'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Fno_image.jpg?alt=media&token=90c83f0b-35ce-455d-aa27-15e7e3f4daf9';

    return Scaffold(
      appBar: AppBar(
        title: Text('Λίστα Γκρουπ'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => CaptainHomePage(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.lightBlue,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Αναζήτηση αριθμού ή τίτλου γκρουπ',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
                border: OutlineInputBorder(),
                fillColor: Colors.lightGreenAccent,
                filled: true,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_groupDetails != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaptainGroupChange(
                      groupDetails: _groupDetails!,
                      documentID: _groupId,
                      isAdmin: _isAdmin,
                    ),
                  ),
                );
              } else {
                print('Δεν υπάρχουν διαθέσιμες λεπτομέρειες για τo group.');
              }
            },
            child: Text("Το group μου"),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No data available'),
                  );
                }
                var groups = snapshot.data!.docs;
                List<DocumentSnapshot> filteredGroups = [];
                if (_searchQuery.isNotEmpty || _filter != 'Όλα τα groups') {
                  filteredGroups = groups.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var documentID = reverseFormatDocumentID(doc.id).toLowerCase();
                    var groupTitle = (data['title'] ?? '').toLowerCase();
                    var parade = data['parade'] ?? '';

                    bool matchesSearchQuery = documentID.contains(_searchQuery) || groupTitle.contains(_searchQuery);
                    bool matchesFilter = _filter == 'Όλα τα groups' ||
                        (_filter == 'saturday' && (parade == 'saturday' || parade == 'both')) ||
                        (_filter == 'sunday' && (parade == 'sunday'|| parade == 'both')) ||
                        (_filter == 'both' && parade == 'both');

                    return matchesSearchQuery && matchesFilter;
                  }).toList();
                } else {
                  filteredGroups = List.from(groups);
                }

                if (filteredGroups.isEmpty) {
                  return Center(
                    child: Text('Δεν βρέθηκαν αποτελέσματα'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    var documentID = reverseFormatDocumentID(filteredGroups[index].id);
                    var groupData = filteredGroups[index].data()! as Map<String, dynamic>;
                    var groupTitle = groupData['title'] ?? 'No Title';
                    var thumbnail = groupData['thumbnail']?.isNotEmpty == true
                        ? groupData['thumbnail']
                        : noImageSelect;

                    return InkWell(
                      onTap: () => _onGroupTapped(documentID, filteredGroups[index]),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(28.0),
                          color: Colors.lightGreenAccent,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Group $documentID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('"$groupTitle"'),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(38.0),
                              child: Image.network(
                                thumbnail,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
