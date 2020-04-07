@SuppressWarnings('PMD.MethodNamingConventions')

@isTest
public with sharing class ZumzumPostSalesInvoiceHelperTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';

    @testSetup
    static void testSetup() {
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();

        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account customer = accountBuilder
                                .withRecordType('Household Account')
                                .withName('Test Customer')
                                .withType(ACCOUNT_TYPE_CUSTOMER)
                                .withAccountNumber('12345678')
                                .withBillingEmail('testbilling@nonsense.noemails')
                                .insertRecord(true)
                                .build();
        
        TestFinanceDataFactory.updateHouseholdAccountsToCustomerType();
        TestFinanceDataFactory.createProducts();

        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameters = TestFinanceDataFactory.getZumzumSalesInvoiceParameters();
        List<Zumzum__Sales_Invoice__c> salesInvoiceList = ZumzumCreatePostSalesInvoice.createSI(zumzumSalesInvoiceParameters);

    }

    @isTest
    static void PostSalesInvoice_ExecutePostSalesInvoiceApiMethod_ReturnSalesInvoicesWithStatusPosted() {
        Zumzum__Sales_Invoice__c salesInvoiceRecordBefore = [select Zumzum__Status__c from Zumzum__Sales_Invoice__c LIMIT 1];
        System.assertEquals('Draft', salesInvoiceRecordBefore.Zumzum__Status__c, 'return SI with status Draft');

        Test.startTest();
            ZumzumPostSalesInvoiceHelper.postSalesInvoice(new List<Zumzum__Sales_Invoice__c> { salesInvoiceRecordBefore });
        Test.stopTest();

        Zumzum__Sales_Invoice__c salesInvoiceRecordAfter = [select Zumzum__Status__c from Zumzum__Sales_Invoice__c LIMIT 1];
        System.assertEquals('Posted', salesInvoiceRecordAfter.Zumzum__Status__c, 'return SI with status Posted');
    }

}