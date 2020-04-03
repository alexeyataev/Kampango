@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public class ZumzumCreatePostSalesInvoiceTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final String PRODUCT_NAME_MEMBERSHIP_18_MONTH = 'Membership - 18 month';
    @testSetup
    static void testSetup() {
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
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
        //TestFinanceDataFactory.updateHouseholdAccountsToCustomerType();
        TestFinanceDataFactory.createProducts();
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
    @IsTest
    static void PostSalesInvoice_SalesInvoicePosted_SalesInvoiceStatusPosted() {
        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameters = TestFinanceDataFactory.getZumzumSalesInvoiceParameters();
        ZumzumCreatePostSalesInvoice.salesInvoiceCreator = new ZumzumSalesInvoiceCreatorMock();
        Test.startTest();
        ZumzumCreatePostSalesInvoice.createSI(zumzumSalesInvoiceParameters);
        Test.stopTest();
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c FROM Zumzum__Sales_Invoice__c LIMIT 1];
        System.assertEquals([SELECT Id FROM Zumzum__Sales_Invoice_Line_Item__c WHERE Zumzum__Sales_Invoice__c =: salesInvoiceCreated.Id].size(), 2);
    }
}