// ignore_for_file: prefer_const_constructors, use_super_parameters, avoid_print, sort_child_properties_last, unnecessary_cast

import 'package:carnival_app1/features/user_auth/presentation/pages/group_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnival_app1/global/common/format_id.dart';
import 'home_page.dart';

class GroupsList extends StatefulWidget {
  const GroupsList({Key? key}) : super(key: key);

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  String _searchQuery = '';
  String _filter = 'Όλα τα groups';

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
                  builder: (context) => HomePage(),
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
                        margin: EdgeInsets.symmetric(vertical: 8.5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(38.0),
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
