@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #60 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public class AddBankReceiptPaymentBatchTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String BANK_ACCOUNT_NAME = 'Card Receipts in Transit';
    private static final String MEMBERSHIP_NOMINAL_CODE = '1003';
    private static final String CREDIT_CARD_NUMBER = '1111-2222-3333-4444';
    private static final String PAYMENT_PROFILE_CREDIT_CARD_RECORD_TYPE = 'Credit Card';

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
        List<Zumzum__Sales_Invoice__c> salesInvoiceToPostList = [SELECT Zumzum__Account__c, Zumzum__Status__c, Zumzum__Transaction_Currency__c, (SELECT Zumzum__Foreign_Net_Amount__c, Zumzum__Foreign_Tax_Total__c, Zumzum__Nominal_Account__c FROM Zumzum__Sales_Invoice_Line_Items__r) FROM Zumzum__Sales_Invoice__c];
        ZumzumSalesInvoiceCreatorMock.postSI(salesInvoiceToPostList);
        Account account = [SELECT Id FROM Account WHERE Type = :ACCOUNT_TYPE_CUSTOMER LIMIT 1];
        
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder
            .withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Smith')
            .withRecordType('Client')
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

        Bank_Account_Settings__c bankAccountSettings = new Bank_Account_Settings__c();
        bankAccountSettings.Card_Receipt_Bank_Account_Name__c = BANK_ACCOUNT_NAME;
        insert bankAccountSettings;
    }
    
    @IsTest
    static void AddBankReceiptForWorldpayPaymentBatch_CoursePlaceLineItemExists_ReceiptCreatedForCoursePlace() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c, (SELECT Zumzum__Amount__c FROM Zumzum__Sales_Invoice_Line_Items__r) FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c installment = [SELECT cpm__Amount__c FROM cpm__Installment__c LIMIT 1];
        installment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c;
        update installment;

        cpm__Payment__c payment = [SELECT cpm__Amount__c FROM cpm__Payment__c LIMIT 1];
        payment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c;
        update payment;
        
        Zumzum__Ledger__c membershipLedger = [SELECT Id FROM Zumzum__Ledger__c WHERE Zumzum__Sales_Invoice_Line_Item__r.Zumzum__Nominal_Account__r.Zumzum__Nominal_Code__c = :MEMBERSHIP_NOMINAL_CODE];
        delete membershipLedger;

        Test.startTest();
        AddBankReceiptForPaymentHandler.bankReceiptCreator = new ZumzumBankReceiptCreatorMock();
        Database.executeBatch(new AddBankReceiptForWorldpayPaymentBatch());
        Test.stopTest();
       
        List<Zumzum__Bank_Receipt__c> bankReceipts = [SELECT Id, Payment__c, (SELECT Id FROM Zumzum__Bank_Receipt_Line_Items__r) FROM Zumzum__Bank_Receipt__c WHERE Payment__c = :payment.Id];
        System.assertEquals(1, bankReceipts.Size());
        System.assertEquals(1, bankReceipts[0].Zumzum__Bank_Receipt_Line_Items__r.Size());
    }

    @IsTest
    static void AddBankReceiptForWorldpayPaymentBatch_CoursePlaceAndMembershipLineItemExists_ReceiptCreatedForAllLineItems() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c, (SELECT Zumzum__Amount__c FROM Zumzum__Sales_Invoice_Line_Items__r) FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c installment = [SELECT cpm__Amount__c  FROM cpm__Installment__c LIMIT 1];
        installment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c + salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[1].Zumzum__Amount__c;
        update installment;

        cpm__Payment__c payment = [SELECT cpm__Amount__c FROM cpm__Payment__c LIMIT 1];
        payment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c + salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[1].Zumzum__Amount__c;
        update payment;

        Test.startTest();
        AddBankReceiptForPaymentHandler.bankReceiptCreator = new ZumzumBankReceiptCreatorMock();
        Database.executeBatch(new AddBankReceiptForWorldpayPaymentBatch());
        Test.stopTest();

        List<Zumzum__Bank_Receipt__c> bankReceipts = [SELECT Id, Payment__c, (SELECT Id FROM Zumzum__Bank_Receipt_Line_Items__r) FROM Zumzum__Bank_Receipt__c WHERE Payment__c = :payment.Id];
        System.assertEquals(1, bankReceipts.Size());
        System.assertEquals(2, bankReceipts[0].Zumzum__Bank_Receipt_Line_Items__r.Size());
    }

    @IsTest
    static void AddBankReceiptForWorldpayPaymentBatch_ForRecurringPayment() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c, (SELECT Zumzum__Amount__c FROM Zumzum__Sales_Invoice_Line_Items__r) FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c firstInstallment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, Sales_Invoice__c FROM cpm__Installment__c LIMIT 1];
        firstInstallment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 0.7 + salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[1].Zumzum__Amount__c;
        update firstInstallment;
        cpm__Payment__c firstPayment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, cpm__Installment__r.Sales_Invoice__c, cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c FROM cpm__Payment__c LIMIT 1];
        firstPayment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 0.7 + salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[1].Zumzum__Amount__c;
        update firstPayment;

        AddBankReceiptForPaymentHandler.bankReceiptCreator = new ZumzumBankReceiptCreatorMock();
        AddBankReceiptForPaymentHandler.addBankReceipts(new List<cpm__Payment__c> {firstPayment});

        TestRecurringPaymentBuilder recurringPaymentBuilder = new TestRecurringPaymentBuilder();
        cpm__Recurring_Payment__c recurringPayment = recurringPaymentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 0.3)
            .withPrimaryContact(firstPayment.cpm__Contact__c)
            .withSalesInvoice(firstInstallment.Sales_Invoice__c)
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c secondInstallment = installmentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 0.3)
            .withAccount(firstInstallment.cpm__Account__c)
            .withPrimaryContact(firstInstallment.cpm__Contact__c)
            .withBankDetailsNumber('331257')
            .withPaymentProfile(firstInstallment.cpm__Payment_Profile__c)
            .withRecurringPayment(recurringPayment.Id)
            .insertRecord(true)
            .build();
        TestPaymentBuilder paymentBuilder = new TestPaymentBuilder();
        cpm__Payment__c secondPayment = paymentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 0.3)
            .withAccount(firstPayment.cpm__Account__c)
            .withPrimaryContact(firstPayment.cpm__Contact__c)
            .withPaymentProfile(firstPayment.cpm__Payment_Profile__c)
            .withInstallment(secondInstallment.Id)
            .insertRecord(true)
            .build();


        Test.startTest();
        Database.executeBatch(new AddBankReceiptForWorldpayPaymentBatch());
        Test.stopTest();

        List<Zumzum__Bank_Receipt__c> bankReceipts = [SELECT Id, Payment__c, (SELECT Id FROM Zumzum__Bank_Receipt_Line_Items__r) FROM Zumzum__Bank_Receipt__c WHERE Id IN (SELECT Zumzum__Bank_Receipt__c FROM Zumzum__Bank_Receipt_Line_Item__c WHERE Zumzum__Sales_Invoice__c = :firstInstallment.Sales_Invoice__c)];
        System.assertEquals(2, bankReceipts.Size());
        System.assertEquals(2, bankReceipts[0].Zumzum__Bank_Receipt_Line_Items__r.Size());
        System.assertEquals(1, bankReceipts[1].Zumzum__Bank_Receipt_Line_Items__r.Size());
    }

    @IsTest
    static void AddBankReceiptForWorldpayPaymentBatch_SalesInvoiceOverpaid_ReceiptCreatedForFirstPayment() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Name, Zumzum__Status__c, Zumzum__Total_Unpaid_Amount__c, (SELECT Zumzum__Amount__c FROM Zumzum__Sales_Invoice_Line_Items__r) FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c firstInstallment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, Sales_Invoice__c FROM cpm__Installment__c LIMIT 1];
        firstInstallment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 0.7 + salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[1].Zumzum__Amount__c;
        update firstInstallment;
        cpm__Payment__c firstPayment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, cpm__Installment__r.Sales_Invoice__c, cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c FROM cpm__Payment__c LIMIT 1];
        firstPayment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 0.7 + salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[1].Zumzum__Amount__c;
        update firstPayment;

        AddBankReceiptForPaymentHandler.bankReceiptCreator = new ZumzumBankReceiptCreatorMock();
        AddBankReceiptForPaymentHandler.addBankReceipts(new List<cpm__Payment__c> {firstPayment});

        TestRecurringPaymentBuilder recurringPaymentBuilder = new TestRecurringPaymentBuilder();
        cpm__Recurring_Payment__c recurringPayment = recurringPaymentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 2)
            .withPrimaryContact(firstPayment.cpm__Contact__c)
            .withSalesInvoice(firstInstallment.Sales_Invoice__c)
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c secondInstallment = installmentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 2)
            .withAccount(firstInstallment.cpm__Account__c)
            .withPrimaryContact(firstInstallment.cpm__Contact__c)
            .withBankDetailsNumber('331257')
            .withPaymentProfile(firstInstallment.cpm__Payment_Profile__c)
            .withRecurringPayment(recurringPayment.Id)
            .insertRecord(true)
            .build();
        TestPaymentBuilder paymentBuilder = new TestPaymentBuilder();
        cpm__Payment__c secondPayment = paymentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Sales_Invoice_Line_Items__r[0].Zumzum__Amount__c * 2)
            .withAccount(firstPayment.cpm__Account__c)
            .withPrimaryContact(firstPayment.cpm__Contact__c)
            .withPaymentProfile(firstPayment.cpm__Payment_Profile__c)
            .withInstallment(secondInstallment.Id)
            .insertRecord(true)
            .build();


        Test.startTest();
        Database.executeBatch(new AddBankReceiptForWorldpayPaymentBatch());
        Test.stopTest();

        List<Zumzum__Bank_Receipt__c> bankReceipts = [SELECT Id, Payment__c, (SELECT Id FROM Zumzum__Bank_Receipt_Line_Items__r) FROM Zumzum__Bank_Receipt__c WHERE Id IN (SELECT Zumzum__Bank_Receipt__c FROM Zumzum__Bank_Receipt_Line_Item__c WHERE Zumzum__Sales_Invoice__c = :firstInstallment.Sales_Invoice__c)];
        secondPayment = [SELECT cpm__Amount__c, Bank_Customer_Receipt_Error_Log__c FROM cpm__Payment__c WHERE Id = :secondPayment.Id LIMIT 1];
        String errorMessage = String.format(System.label.BankCustomerReceiptOverpaidErrorText, new List<String>{
            salesInvoiceCreated.Name, String.valueOf(salesInvoiceCreated.Zumzum__Total_Unpaid_Amount__c), String.valueOf(secondPayment.cpm__Amount__c)
        });
        System.assertEquals(1, bankReceipts.Size());
        System.assertEquals(2, bankReceipts[0].Zumzum__Bank_Receipt_Line_Items__r.Size());
        System.assertEquals(true, secondPayment.Bank_Customer_Receipt_Error_Log__c.contains(errorMessage));
    }
}
