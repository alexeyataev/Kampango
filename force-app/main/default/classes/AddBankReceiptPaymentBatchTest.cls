@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public class AddBankReceiptPaymentBatchTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final String PRODUCT_NAME_MEMBERSHIP_18_MONTH = 'Membership - 18 month';
    private static final String BANK_ACCOUNT_NAME = 'Card Receipts in Transit';
    private static final String MEMBERSHIP_NOMINAL_CODE = '1003';
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
        updateHouseholdAccountsToCustomerType();
        createProducts();

        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameters = getZumzumSalesInvoiceParameters();
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
            .withContact(primaryContact)
            .withSortCode('123456')
            .withBankAccount('1234567890')
            .withHolderName('John Smith')
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

        Zumzum__Bank_Account__c bankAccount = [SELECT Id FROM Zumzum__Bank_Account__c LIMIT 1];
        Bank_Account_Settings__c bankAccountSettings = new Bank_Account_Settings__c();
        bankAccountSettings.Bank_Account_Name__c = BANK_ACCOUNT_NAME;
        insert bankAccountSettings;
    }
    
    @IsTest
    static void CreateBankReceiptForCoursePayment() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c, Zumzum__Paid__c, Zumzum__Foreign_Total_Gross__c, Zumzum__Foreign_Unpaid_Amount__c FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c installment = [SELECT cpm__Amount__c FROM cpm__Installment__c LIMIT 1];
        installment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c;
        update installment;

        cpm__Payment__c payment = [SELECT cpm__Amount__c FROM cpm__Payment__c LIMIT 1];
        payment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c;
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
    static void CreateBankReceiptForCourseAndMembershipPayment() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c, Zumzum__Paid__c, Zumzum__Foreign_Total_Gross__c, Zumzum__Foreign_Unpaid_Amount__c FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c installment = [SELECT cpm__Amount__c  FROM cpm__Installment__c LIMIT 1];
        installment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c;
        update installment;

        cpm__Payment__c payment = [SELECT cpm__Amount__c FROM cpm__Payment__c LIMIT 1];
        payment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c;
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
    static void CreateBankReceiptForRecurringPayment() {
        Zumzum__Sales_Invoice__c salesInvoiceCreated = [SELECT Id, Zumzum__Status__c, Zumzum__Paid__c, Zumzum__Foreign_Total_Gross__c, Zumzum__Foreign_Unpaid_Amount__c FROM Zumzum__Sales_Invoice__c LIMIT 1];
        cpm__Installment__c firstInstallment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, Sales_Invoice__c FROM cpm__Installment__c LIMIT 1];
        firstInstallment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c * 0.7;
        update firstInstallment;
        cpm__Payment__c firstPayment = [SELECT cpm__Amount__c, cpm__Account__c, cpm__Contact__c, cpm__Payment_Profile__c, cpm__Installment__r.Sales_Invoice__c, cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c FROM cpm__Payment__c LIMIT 1];
        firstPayment.cpm__Amount__c = salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c * 0.7;
        update firstPayment;

        AddBankReceiptForPaymentHandler.bankReceiptCreator = new ZumzumBankReceiptCreatorMock();
        AddBankReceiptForPaymentHandler.addBankReceipts(new List<cpm__Payment__c> {firstPayment});

        TestRecurringPaymentBuilder recurringPaymentBuilder = new TestRecurringPaymentBuilder();
        cpm__Recurring_Payment__c recurringPayment = recurringPaymentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c * 0.3)
            .withPrimaryContact(firstPayment.cpm__Contact__c)
            .withSalesInvoice(firstInstallment.Sales_Invoice__c)
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c secondInstallment = installmentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c * 0.3)
            .withAccount(firstInstallment.cpm__Account__c)
            .withPrimaryContact(firstInstallment.cpm__Contact__c)
            .withBankDetailsNumber('331257')
            .withPaymentProfile(firstInstallment.cpm__Payment_Profile__c)
            .withRecurringPayment(recurringPayment.Id)
            .insertRecord(true)
            .build();
        TestPaymentBuilder paymentBuilder = new TestPaymentBuilder();
        cpm__Payment__c secondPayment = paymentBuilder
            .withAmount(salesInvoiceCreated.Zumzum__Foreign_Total_Gross__c * 0.3)
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
       
    private static List<List<ZumzumSalesInvoiceParameters>> getZumzumSalesInvoiceParameters() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Account customer = [SELECT Id FROM Account WHERE Type =: ACCOUNT_TYPE_CUSTOMER LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c LIMIT 1];
        Product2 productCourse = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_COURSE_PLACE LIMIT 1];
        Product2 productMembership = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_MEMBERSHIP_18_Month LIMIT 1];
        Zumzum__Nominal_Account__c zumzumDebtorNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 9300 LIMIT 1];
        Zumzum__Nominal_Account__c zumzumMembershipNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 1003 LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        Zumzum__Dimension__c dimension1 = [SELECT Id FROM Zumzum__Dimension__c WHERE Zumzum__Type__c = 'Dimension 1' LIMIT 1];
        Zumzum__Dimension__c dimension2 = [SELECT Id FROM Zumzum__Dimension__c WHERE Zumzum__Type__c = 'Dimension 2' LIMIT 1];
        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameterList = new List<List<ZumzumSalesInvoiceParameters>>();
        ZumzumSalesInvoiceParameters courseZumzumSalesInvoiceParameter =  new ZumzumSalesInvoiceParameters();
        coursezumzumSalesInvoiceParameter.customerId = customer.Id;
        coursezumzumSalesInvoiceParameter.transactionCurrencyId = transactionCurrency.Id;
        coursezumzumSalesInvoiceParameter.bookingId = booking.Id;
        coursezumzumSalesInvoiceParameter.productId = productCourse.Id;
        coursezumzumSalesInvoiceParameter.quantity = 1;
        coursezumzumSalesInvoiceParameter.nominalAccountId = zumzumDebtorNominalAccount.Id;
        coursezumzumSalesInvoiceParameter.taxRateId = taxRate.Id;
        coursezumzumSalesInvoiceParameter.foreignNetAmount = 100;
        coursezumzumSalesInvoiceParameter.dimension1Id = dimension1.Id;
        coursezumzumSalesInvoiceParameter.dimension2Id = dimension2.Id;
        ZumzumSalesInvoiceParameters membershipZumzumSalesInvoiceParameter =  new ZumzumSalesInvoiceParameters();
        membershipZumzumSalesInvoiceParameter.customerId = customer.Id;
        membershipZumzumSalesInvoiceParameter.transactionCurrencyId = transactionCurrency.Id;
        membershipZumzumSalesInvoiceParameter.bookingId = booking.Id;
        membershipZumzumSalesInvoiceParameter.productId = productMembership.Id;
        membershipZumzumSalesInvoiceParameter.quantity = 1;
        membershipZumzumSalesInvoiceParameter.nominalAccountId = zumzumMembershipNominalAccount.Id;
        membershipZumzumSalesInvoiceParameter.taxRateId = taxRate.Id;
        membershipZumzumSalesInvoiceParameter.foreignNetAmount = 10;
        membershipZumzumSalesInvoiceParameter.dimension1Id = dimension1.Id;
        membershipZumzumSalesInvoiceParameter.dimension2Id = dimension2.Id;
        zumzumSalesInvoiceParameterList.add(new List<ZumzumSalesInvoiceParameters> {courseZumzumSalesInvoiceParameter, membershipZumzumSalesInvoiceParameter});
        return zumzumSalesInvoiceParameterList;
    }
}
