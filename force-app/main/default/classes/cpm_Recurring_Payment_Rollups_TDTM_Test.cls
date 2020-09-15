@SuppressWarnings('PMD.ClassNamingConventions, PMD.MethodNamingConventions')
//Incident #147 - https://confluence.nct.org.uk:8443/x/EoSO
//Incident #148 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public class cpm_Recurring_Payment_Rollups_TDTM_Test {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String BANK_ACCOUNT_NAME = 'Card Receipts in Transit';
    private static final String MEMBERSHIP_NOMINAL_CODE = '1003';
    private static final String CREDIT_CARD_NUMBER = '1111-2222-3333-4444';
    private static final String PAYMENT_PROFILE_CREDIT_CARD_RECORD_TYPE = 'Credit Card';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'cpm_Recurring_Payment_Rollups_TDTM',
        'className' => 'cpm_Recurring_Payment_Rollups_TDTM',
        'objectAPIName' => 'cpm__Recurring_Payment__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @testSetup
    static void testSetup() {
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
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

        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameters = TestFinanceDataFactory.getZumzumSalesInvoiceParameters();
        ZumzumCreatePostSalesInvoice.salesInvoiceCreator = new ZumzumSalesInvoiceCreatorMock();
        List<Zumzum__Sales_Invoice__c> salesInvoiceList = ZumzumCreatePostSalesInvoice.createSI(zumzumSalesInvoiceParameters);
        Account account = [SELECT Id FROM Account WHERE Type = :ACCOUNT_TYPE_CUSTOMER LIMIT 1];
        
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder
            .withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Smith')
            .insertRecord(true)
            .build();
        TestPaymentProfileBuilder paymentProfileBuilder = new TestPaymentProfileBuilder();
        cpm__Payment_Profile__c paymentProfile = paymentProfileBuilder
            .withRecordType(PAYMENT_PROFILE_CREDIT_CARD_RECORD_TYPE)
            .withCreditCardNumbert(CREDIT_CARD_NUMBER)
            .withContact(primaryContact)
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c installment = installmentBuilder
            .withAccount(account.Id)
            .withPrimaryContact(primaryContact.Id)
            .withBankDetailsNumber('331257')
            .withPaymentProfile(paymentProfile.Id)
            .withSalesInvoice(salesInvoiceList[0].Id)
            .insertRecord(true)
            .build();
        TestPaymentBuilder paymentBuilder = new TestPaymentBuilder();
        cpm__Payment__c payment = paymentBuilder
            .withAccount(account.Id)
            .withPrimaryContact(primaryContact.Id)
            .withPaymentProfile(paymentProfile.Id)
            .withInstallment(installment.Id)
            .insertRecord(true)
            .build();

        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }
    
    @IsTest
    static void RecurringPaymentRollupsCalculated_RecurringPaymentInserted() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c, (SELECT Zumzum__Amount__c FROM Zumzum__Sales_Invoice_Line_Items__r) FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c installment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, Sales_Invoice__c FROM cpm__Installment__c LIMIT 1];
        cpm__Payment__c payment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, cpm__Installment__r.Sales_Invoice__c, cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c FROM cpm__Payment__c LIMIT 1];
        TestRecurringPaymentBuilder recurringPaymentBuilder = new TestRecurringPaymentBuilder();
        cpm__Recurring_Payment__c recurringPayment = recurringPaymentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c)
            .withPrimaryContact(payment.cpm__Contact__c)
            .withSalesInvoice(installment.Sales_Invoice__c)
            .insertRecord(false)
            .build();

        Test.startTest();
        dlrs.RollupService.testHandler(recurringPayment);
        Test.stopTest();

        Zumzum__Sales_Invoice__c salesInvoiceToTest = [SELECT Id, RecurringPaymentAmountNotYetCollected__c FROM Zumzum__Sales_Invoice__c LIMIT 1];
        System.assertEquals(recurringPayment.cpm__Amount__c, salesInvoiceToTest.RecurringPaymentAmountNotYetCollected__c);
    }
}
