Set<String> productNames = new Set<String>{
    'Course Place',
    'Course Cancellation Fees',
    'Course Transfer Fees'
};
List<Product2> existingProducts = [
    SELECT Id, Name
    FROM Product2
    WHERE Name IN :productNames
    LIMIT 1
];
for (Product2 existingProduct : existingProducts) {
    productNames.remove(existingProduct.Name);
}

if (productNames.isEmpty()) {
    System.debug('Products with given names are already exist');
    return;
}


try {
    List<Product2> newProducts = new List<Product2>();
    for (String productName : productNames) {
        Product2 newProduct = new Product2(
            Name = productName,
            IsActive = true,
            ProductCode = productName.replaceAll( '\\s+', '')
        );
        newProducts.add(newProduct);
    }
    insert newProducts;
    System.debug('Products were created succesfully');
} catch (Exception e) {
    System.debug('There was an exception during Products creation: ' + e.getMessage());
}

