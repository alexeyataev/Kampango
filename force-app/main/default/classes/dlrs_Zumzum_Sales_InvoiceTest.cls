/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #98 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_Zumzum_Sales_InvoiceTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String CREDIT_CARD_NUMBER = '1111-2222-3333-4444';
    private static final String PAYMENT_PROFILE_CREDIT_CARD_RECORD_TYPE = 'Credit Card';
    private static final String SALES_INVOICE_TYPE_SI = 'Sales Invoice';
    private static final String SALES_INVOICE_STATUS_POSTED = 'Posted';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String SESSION_TYPE_REUNION = 'Reunion';
    private static final String SESSION_STATUS_CONFIRMED = 'Confirmed';
    private static final Integer BANK_NOMINAL_ACCOUNT_CODE = 9401;
    private static final Integer FEE = 300;

    @testSetup
    static void testSetup() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourseWithFee(FEE)
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildSessionWithTypeAndStatus(SESSION_TYPE_REUNION, SESSION_STATUS_CONFIRMED)
                    .buildBooking('Enquiry');
        
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory .createZumzumData();
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account customer = accountBuilder
                                .withRecordType('Household Account')
                                .withName('Test Customer')
                                .withType(ACCOUNT_TYPE_CUSTOMER)
                                .withAccountNumber('123456')
                                .withBillingEmail('testbilling@nonsense.noemails')
                                .insertRecord(true)
                                .build();
        
        TestFinanceDataFactory.updateHouseholdAccountsToCustomerType();
        TestFinanceDataFactory.createProducts();

        Zumzum__Bank_Account__c bankAccount = [SELECT Id FROM Zumzum__Bank_Account__c WHERE Name = 'Reconcile Bank' LIMIT 1];
        Zumzum__Company__c company = [SELECT Id FROM Zumzum__Company__c WHERE Name = 'NCT' LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c WHERE Name = 'GBP' LIMIT 1];
        Product2 productCourse = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_COURSE_PLACE LIMIT 1];
        Zumzum__Nominal_Account__c nominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = :BANK_NOMINAL_ACCOUNT_CODE LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        Booking__c booking = [SELECT Id, Primary_Contact__c, Count_Of_Posted_Sales_Invoices__c FROM Booking__c LIMIT 1];

        Zumzum__Sales_Invoice__c salesInvoice = new Zumzum__Sales_Invoice__c(
            Booking__c = booking.Id,
            Zumzum__Account__c = customer.Id,
            Zumzum__Contact__c = booking.Primary_Contact__c,
            Zumzum__Company__c = company.Id,
            Zumzum__Invoice_Date__c = Date.today(),
            Zumzum__Transaction_Currency__c = transactionCurrency.Id,
            Zumzum__Type__c = SALES_INVOICE_TYPE_SI,
            Zumzum__Status__c = SALES_INVOICE_STATUS_POSTED
        );
        insert salesInvoice;
    }

    @IsTest
    private static void testTrigger() {
        // Force the dlrs_Zumzum_Sales_InvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        Zumzum__Sales_Invoice__c salesInvoice = [SELECT Id FROM Zumzum__Sales_Invoice__c LIMIT 1];

        Test.startTest();
        dlrs.RollupService.testHandler(salesInvoice);
        Test.stopTest();

        Booking__c bookingToTest = [SELECT Count_Of_Posted_Sales_Invoices__c FROM Booking__c LIMIT 1];
        System.assertEquals(1, bookingToTest.Count_Of_Posted_Sales_Invoices__c);
    }
}