// ignore_for_file: use_super_parameters, library_private_types_in_public_api, sized_box_for_whitespace, prefer_const_constructors

import 'package:flutter/material.dart';

class GuestDetailsPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  final String documentID;

  const GuestDetailsPage({
    Key? key,
    required this.groupDetails,
    required this.documentID,
  }) : super(key: key);

  @override
  _GuestDetailsPageState createState() => _GuestDetailsPageState();
}

class _GuestDetailsPageState extends State<GuestDetailsPage> {
  late PageController _pageController;
  late int _currentPageIndex;
  late int _totalPages;
  final String noImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Fno_image.jpg?alt=media&token=90c83f0b-35ce-455d-aa27-15e7e3f4daf9';

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
    _updateTotalPages();
  }

  @override
  void didUpdateWidget(GuestDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTotalPages();
  }

  void _updateTotalPages() {
    if (widget.groupDetails.isNotEmpty) {
      _totalPages = widget.groupDetails.keys
          .where((key) => key.startsWith('photo_'))
          .length;
      _pageController = PageController(initialPage: _currentPageIndex);
      _pageController.addListener(() {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      });
    } else {
      _totalPages = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group ${widget.documentID}'),
        backgroundColor: Colors.lightBlue[100],
      ),
      body: Container(
        color: Colors.lightBlue[100],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: _totalPages > 0
                    ? Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _totalPages,
                      itemBuilder: (context, index) {
                        String photoKey = 'photo_${index + 1}';
                        String photoUrl =
                            widget.groupDetails[photoKey] ?? noImageUrl;
                        return Center(
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _totalPages,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageIndex == index
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Image.asset(
                  noImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100], // Χρώμα sticky note
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Σκιά
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Πληροφορίες Group',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildGroupInfoField(
                        'Αριθμός Μελών',
                        widget.groupDetails['member_count'],
                      ),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoField(
                        'Περιγραφή Group',
                        widget.groupDetails['description'],
                      ),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoFieldBlur('Σημείο Συνάντησης'),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoFieldBlur('Σειρά Στην Παρέλαση'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100], // Χρώμα sticky note
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Σκιά
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Στοιχεία Επικοινωνίας Αρχηγού',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildGroupInfoFieldBlur('Αρχηγος Group'),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoFieldBlur('Email Αρχηγού'),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoFieldBlur('Τηλέφωνο Επικοινωνίας'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfoField(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Center(
            child: Text(
              '$value',
              style: TextStyle(fontSize: 20),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfoFieldBlur(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.grey[400], // Χρώμα blur
            ),
          ),
          Center(
            child: Text(
              '********',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
