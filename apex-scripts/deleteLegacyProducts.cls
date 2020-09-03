List<String> productNames = new List<String>{
    'Course Place',
    'Course Cancellation Fees',
    'Course Transfer Fees',
    'Membership - CARE/DD',
    'Membership'
};

void deleteProducts(List<String> input) {
    List<Product2> productsTodelete = [
        SELECT Id, Name
        FROM Product2
        WHERE Name NOT IN :productNames
    ];

    List<PricebookEntry> priceEntriesTodelete = [
        SELECT Id
        FROM PricebookEntry
        WHERE Product2Id IN :productsTodelete
    ];

    delete priceEntriesTodelete;
    delete productsTodelete;
}
deleteProducts(productNames);