
/*
Store the listing Details in a separate class in order to access the value for the document ID and the listing Details and the DetailedListing. dart
 */
class DetailedListingsStore {

  final String docID;
  final Map<String, dynamic> listingInfo;

  DetailedListingsStore(this.docID, this.listingInfo);
}