String productName = 'Course Place';

List<Product2> coursePlaceProduct = [
    SELECT Id
    FROM Product2
    WHERE Name = :productName
    LIMIT 1
];

if (coursePlaceProduct.size() != 1) {
    System.debug('Product with name Course Place already exists');
    return;
}

Product2 newProduct = new Product2(
    Name = productName,
    IsActive = true
);
insert newProduct;
System.debug('Product with name Course Place created succesfully');
