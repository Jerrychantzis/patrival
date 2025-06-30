// ignore_for_file: use_super_parameters, library_private_types_in_public_api, sized_box_for_whitespace, prefer_const_constructors

import 'package:flutter/material.dart';

class GroupDetailsPage extends StatefulWidget {
  final Map<String, dynamic> groupDetails;
  final String documentID;

  const GroupDetailsPage({
    Key? key,
    required this.groupDetails,
    required this.documentID,
  }) : super(key: key);

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
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
  void didUpdateWidget(GroupDetailsPage oldWidget) {
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

  String greekParade(){
    if (widget.groupDetails['parade'] == "saturday"){
      return "Σάββατο";
    }else if (widget.groupDetails['parade'] == "sunday"){
      return "Κυριακή";
    }else{
      return "Σάββατο και Κυριακή";
    }
  }

  String queueDay(){
    if (widget.groupDetails['parade'] == "sunday"){
      return "Κυριακής";
    }else{
      return "Σαββατου";
    }
  }

  String showArma(){
    if(widget.groupDetails['arma'] == true){
      return "Ναι";
    }
    else{
      return "Όχι";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group ${widget.documentID} - ${widget.groupDetails['title']}'),
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
                    : Image.network(
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
                        'Ημέρα Παρέλασης',
                        greekParade(),
                      ),
                      Divider(height: 1, color: Colors.grey),
                      SizedBox(height: 10),
                      _buildGroupInfoField(
                        'Το group διαθέτει άρμα',
                        showArma(),
                      ),Divider(height: 1, color: Colors.grey),
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
                      _buildGroupInfoField(
                        'Σημείο Συνάντησης',
                        widget.groupDetails['meeting_point'],
                      ),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoField(
                        'Σειρά Στην Παρέλαση ${queueDay()}',
                        widget.groupDetails['queue'],
                      ),
                      if(widget.groupDetails['parade'] == "both")
                        Divider(height: 1, color: Colors.grey),
                      if(widget.groupDetails['parade'] == "both")
                        _buildGroupInfoField(
                          'Σειρά Στην Παρέλαση Κυριακής',
                          widget.groupDetails['queue_2'],
                        ),
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
                      _buildGroupInfoField(
                        'Αρχηγος Group',
                        widget.groupDetails['captain'],
                      ),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoField(
                        'Email Αρχηγού',
                        widget.groupDetails['captain_email'],
                      ),
                      Divider(height: 1, color: Colors.grey),
                      _buildGroupInfoField(
                        'Τηλέφωνο Επικοινωνίας',
                        widget.groupDetails['captain_tel'],
                      ),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
