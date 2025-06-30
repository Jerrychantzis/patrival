String formatDocumentID(String documentID) {
  int id = int.tryParse(documentID) ?? 0;
  if (id < 10) {
    return '00$id';
  } else if (id < 100) {
    return '0$id';
  } else {
    return documentID;
  }
}

String reverseFormatDocumentID(String documentID) {
  if (documentID.length == 3 && documentID.startsWith('00')) {
    return documentID.substring(2);
  } else if (documentID.length == 3 && documentID.startsWith('0')) {
    return documentID.substring(1);
  } else {
    return documentID;
  }
}