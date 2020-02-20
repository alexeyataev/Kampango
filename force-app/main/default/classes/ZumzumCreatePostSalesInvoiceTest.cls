@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public class ZumzumCreatePostSalesInvoiceTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final String PRODUCT_NAME_MEMBERSHIP_18_MONTH = 'Membership - 18 month';
    private static final String DIMENSION_ZUMZUM_TYPE_1 = 'Dimension 1';
    private static final String DIMENSION_ZUMZUM_TYPE_2 = 'Dimension 2';
    @testSetup
    static void testSetup() {
        createBookingData();
        createZumzumData();
    }
    private static void createBookingData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory.buildOrganizationAccount('12345')
                    .buildBranchAccount()
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner('John')
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildConfirmedSession()
                    .buildEstimatedCosts()
                    .buildPractitionerFeeRate()
                    .setCourseToFinal()
                    .buildParentHost('Dina', 'test1@test.com')
                    .buildPartnertHost('Tim', 'test2@test.com')
                    .buildRoom()
                    .buildBooking('Reserved');
        updateHouseholdAccountsToCustomerType();
        createProducts();
    }
    private static void updateHouseholdAccountsToCustomerType() {
        List<Account> accList = [SELECT Id FROM Account WHERE Type = 'Household'];
        for(Account acc : accList) {
            acc.Type = ACCOUNT_TYPE_CUSTOMER;
            acc.AccountNumber = acc.Id;
        }
        update accList;
    }
    private static void createProducts() {
        TestProductBuilder productBuilder = new TestProductBuilder();
        Product2 productCourse = productBuilder
            .withName(PRODUCT_NAME_COURSE_PLACE)
            .insertRecord(true)
            .build();
        Product2 productMembership = productBuilder
            .withName(PRODUCT_NAME_MEMBERSHIP_18_Month)
            .insertRecord(false)
            .build();
            productMembership.ProductCode = 'E';
        insert productMembership;
    }
    private static void createZumzumData() {
        Zumzum__Invoice_Template__c invoiceTemplate = new Zumzum__Invoice_Template__c();
        invoiceTemplate.Zumzum__Is_Default__c = true;
        insert invoiceTemplate;
        Zumzum__Company_Setup__c companySetup = new Zumzum__Company_Setup__c();
        companySetup.Zumzum__Account_Lock_Date__c = Date.today();
        companySetup.Zumzum__VAT_Number__c = '1';
        insert companySetup;
        Zumzum__Currency__c transactionCurrency = new Zumzum__Currency__c();
        transactionCurrency.Zumzum__Is_Active__c = true;
        transactionCurrency.Name = 'GBP';
        transactionCurrency.Zumzum__Is_Corporate__c = true;
        transactionCurrency.Zumzum__Company_Setup__c = companySetup.Id;
        insert transactionCurrency;
        Zumzum__Nominal_Account__c nominalAccount = new Zumzum__Nominal_Account__c();
        nominalAccount.Zumzum__Account_Code__c = 10;
        insert nominalAccount;
        Zumzum__Tax_Rate__c taxRate = new Zumzum__Tax_Rate__c();
        taxRate.Zumzum__Tax_Rate__c = 0;
        insert taxRate;
        Zumzum__Dimension__c dimension1 = new Zumzum__Dimension__c();
        dimension1.Zumzum__Active__c = true;
        dimension1.Zumzum__Type__c = DIMENSION_ZUMZUM_TYPE_1;
        insert dimension1;
        Zumzum__Dimension__c dimension2 = new Zumzum__Dimension__c();
        dimension2.Zumzum__Active__c = true;
        dimension2.Zumzum__Type__c = DIMENSION_ZUMZUM_TYPE_2;
        insert dimension2;
    }
    @IsTest
    static void PostSalesInvoice_SalesInvoicePosted_SalesInvoiceStatusPosted() {
        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameters = getZumzumSalesInvoiceParameters();
        ZumzumCreatePostSalesInvoice.salesInvoiceCreator = new ZumzumSalesInvoiceCreatorMock();
        Test.startTest();
        ZumzumCreatePostSalesInvoice.createSI(zumzumSalesInvoiceParameters);
        Test.stopTest();
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c FROM Zumzum__Sales_Invoice__c LIMIT 1];
        System.assertEquals(salesInvoiceCreated.Zumzum__Status__c, 'Posted');
        System.assertEquals([SELECT Id FROM Zumzum__Sales_Invoice_Line_Item__c WHERE Zumzum__Sales_Invoice__c =: salesInvoiceCreated.Id].size(), 2);
    }
    private static List<List<ZumzumSalesInvoiceParameters>> getZumzumSalesInvoiceParameters() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Account customer = [SELECT Id FROM Account WHERE Type =: ACCOUNT_TYPE_CUSTOMER LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c LIMIT 1];
        Product2 productCourse = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_COURSE_PLACE LIMIT 1];
        Product2 productMembership = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_MEMBERSHIP_18_Month LIMIT 1];
        Zumzum__Nominal_Account__c nominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        Zumzum__Dimension__c dimension1 = [SELECT Id FROM Zumzum__Dimension__c WHERE Zumzum__Type__c =: DIMENSION_ZUMZUM_TYPE_1 LIMIT 1];
        Zumzum__Dimension__c dimension2 = [SELECT Id FROM Zumzum__Dimension__c WHERE Zumzum__Type__c =: DIMENSION_ZUMZUM_TYPE_2 LIMIT 1];
        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameterList = new List<List<ZumzumSalesInvoiceParameters>>();
        ZumzumSalesInvoiceParameters courseZumzumSalesInvoiceParameter =  new ZumzumSalesInvoiceParameters();
        coursezumzumSalesInvoiceParameter.customerId = customer.Id;
        coursezumzumSalesInvoiceParameter.transactionCurrencyId = transactionCurrency.Id;
        coursezumzumSalesInvoiceParameter.bookingId = booking.Id;
        coursezumzumSalesInvoiceParameter.productId = productCourse.Id;
        coursezumzumSalesInvoiceParameter.quantity = 1;
        coursezumzumSalesInvoiceParameter.nominalAccountId = nominalAccount.Id;
        coursezumzumSalesInvoiceParameter.taxRateId = taxRate.Id;
        coursezumzumSalesInvoiceParameter.foreignNetAmount = 1;
        coursezumzumSalesInvoiceParameter.dimension1Id = dimension1.Id;
        coursezumzumSalesInvoiceParameter.dimension2Id = dimension2.Id;
        ZumzumSalesInvoiceParameters membershipZumzumSalesInvoiceParameter =  new ZumzumSalesInvoiceParameters();
        membershipZumzumSalesInvoiceParameter.customerId = customer.Id;
        membershipZumzumSalesInvoiceParameter.transactionCurrencyId = transactionCurrency.Id;
        membershipZumzumSalesInvoiceParameter.bookingId = booking.Id;
        membershipZumzumSalesInvoiceParameter.productId = productMembership.Id;
        membershipZumzumSalesInvoiceParameter.quantity = 1;
        membershipZumzumSalesInvoiceParameter.nominalAccountId = nominalAccount.Id;
        membershipZumzumSalesInvoiceParameter.taxRateId = taxRate.Id;
        membershipZumzumSalesInvoiceParameter.foreignNetAmount = 1;
        membershipZumzumSalesInvoiceParameter.dimension1Id = dimension1.Id;
        membershipZumzumSalesInvoiceParameter.dimension2Id = dimension2.Id;
        zumzumSalesInvoiceParameterList.add(new List<ZumzumSalesInvoiceParameters> {courseZumzumSalesInvoiceParameter, membershipZumzumSalesInvoiceParameter});
        return zumzumSalesInvoiceParameterList;
    }
}