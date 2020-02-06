/* initial */
Set<String> productNames = new Set<String>{
    'Course Place',
    'Course Cancellation Fees',
    'Course Transfer Fees'
};


void filterExisting(Set<String> input) {
    List<Product2> existingProducts = [
        SELECT Id, Name
        FROM Product2
        WHERE Name IN :input
    ];
    for (Product2 existingProduct : existingProducts) {
        input.remove(existingProduct.Name);
    }
}


void createProducts(Set<String> input) {
    try {
        List<Product2> newProducts = new List<Product2>();
        for (String productName : input) {
            Product2 newProduct = new Product2(
                Name = productName,
                IsActive = true,
                ProductCode = productName.replaceAll('\\s+', '')
            );
            newProducts.add(newProduct);
        }
        insert newProducts;
        System.debug('Products were created succesfully');
    } catch (Exception e) {
        System.debug('There was an exception during Products creation: ' + e.getMessage());
    }
}


/* execution */
filterExisting(productNames);
if (productNames.isEmpty()) {
    System.debug('Products with given names are already exist');
    return;
}
createProducts(productNames);