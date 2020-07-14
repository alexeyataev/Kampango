/* initial */
Map<String, Decimal> listPricesByProductNames = new Map<String, Decimal>{
    'Course Place' => 0,
    'Course Cancellation Fees' => 30,
    'Course Transfer Fees' => 25,
    'Membership - CARE/DD' => 0,
    'Membership' => 0
};


void filterExisting(Map<String, Decimal> input) {
    List<Product2> existingProducts = [
        SELECT Id, Name
        FROM Product2
        WHERE Name IN :input.keySet()
    ];
    for (Product2 existingProduct : existingProducts) {
        input.remove(existingProduct.Name);
    }
}


void createProducts(Map<String, Decimal> input) {
    try {
        List<Product2> newProducts = new List<Product2>();
        List<PricebookEntry> newPricebookEntries = new List<PricebookEntry>();
        for (String productName : input.keySet()) {
            newProducts.add(
                new Product2(
                Name = productName,
                IsActive = true,
                ProductCode = productName.replaceAll('\\s+', '')
                )
            );           
        }
        insert newProducts;
        
        Pricebook2 pricebook = [
            SELECT Id
            FROM Pricebook2
            WHERE isStandard = true
        ];

        for(Product2 product : newProducts) {
            newPricebookEntries.add(
            new PricebookEntry(
                isActive = true,
                UnitPrice = listPricesByProductNames.get(product.Name),
                Product2Id = product.Id,
                Pricebook2Id = pricebook.Id
                )
            );
        }
        insert newPricebookEntries;
        System.debug('Products were created succesfully');
    } catch (Exception e) {
        System.debug('There was an exception during Products creation: ' + e.getMessage());
    }
}


/* execution */
filterExisting(listPricesByProductNames);
if (listPricesByProductNames.keySet().isEmpty()) {
    System.debug('Products with given names are already exist');
    return;
}
createProducts(listPricesByProductNames);