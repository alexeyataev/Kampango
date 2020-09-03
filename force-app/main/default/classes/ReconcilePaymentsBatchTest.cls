@isTest
private class ReconcilePaymentsBatchTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String CREDIT_CARD_NUMBER = '1111-2222-3333-4444';
    private static final String PAYMENT_PROFILE_CREDIT_CARD_RECORD_TYPE = 'Credit Card';
    private static final String SALES_INVOICE_TYPE_SI = 'Sales Invoice';
    private static final String SALES_INVOICE_TYPE_SC = 'Sales Credit';
    private static final String SALES_INVOICE_STATUS_POSTED = 'Posted';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final Integer BANK_NOMINAL_ACCOUNT_CODE = 9401;
    private static final Integer LINE_ITEM_QUANTITY = 1;
    private static final Decimal LINE_ITEM_AMOUNT = 100.00;

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


        Zumzum__Bank_Account__c bankAccount = [SELECT Id FROM Zumzum__Bank_Account__c WHERE Name = 'Reconcile Bank' LIMIT 1];
        Zumzum__Company__c company = [SELECT Id FROM Zumzum__Company__c WHERE Name = 'NCT' LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c WHERE Name = 'GBP' LIMIT 1];
        Product2 productCourse = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_COURSE_PLACE LIMIT 1];
        Zumzum__Nominal_Account__c nominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = :BANK_NOMINAL_ACCOUNT_CODE LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        Set<String> paymentIds = financeDataFactory.createBatchReceiptReportWithItems(2, 100.00, true);
        List<Batch_Receipt_Report_Item__c> receiptReportItems = [SELECT Amount__c, Payment_Id__c FROM Batch_Receipt_Report_Item__c];
        
        Zumzum__Sales_Invoice__c salesInvoice = new Zumzum__Sales_Invoice__c(
            Zumzum__Account__c = customer.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Invoice_Date__c = Date.today(),
            Zumzum__Transaction_Currency__c = transactionCurrency.Id,
            Zumzum__Type__c = SALES_INVOICE_TYPE_SI,
            Zumzum__Status__c = SALES_INVOICE_STATUS_POSTED
        );
        insert salesInvoice;

        Zumzum__Sales_Invoice__c salesCredit = new Zumzum__Sales_Invoice__c(
            Zumzum__Account__c = customer.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Invoice_Date__c = Date.today(),
            Zumzum__Transaction_Currency__c = transactionCurrency.Id,
            Zumzum__Type__c = SALES_INVOICE_TYPE_SC,
            Zumzum__Status__c = SALES_INVOICE_STATUS_POSTED,
            Zumzum__Sales_Invoice_to_Credit__c = salesInvoice.Id
        );
        insert salesCredit;

        Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem = new Zumzum__Sales_Invoice_Line_Item__c(
            Zumzum__Product__c = productCourse.Id,
            Zumzum__Nominal_Account__c = nominalAccount.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Quantity__c = LINE_ITEM_QUANTITY,
            Zumzum__Tax_Rate__c = taxRate.Id,
            Zumzum__Foreign_Net_Amount__c = LINE_ITEM_AMOUNT,
            Zumzum__Amount__c = LINE_ITEM_AMOUNT,
            Zumzum__Foreign_Net_Total__c = LINE_ITEM_AMOUNT,
            Zumzum__Foreign_Gross__c = LINE_ITEM_AMOUNT,
            Zumzum__Total_Gross__c = LINE_ITEM_AMOUNT,
            Zumzum__Sales_Invoice__c = salesInvoice.Id
        );
        Zumzum__Sales_Invoice_Line_Item__c salesCreditLineItem = new Zumzum__Sales_Invoice_Line_Item__c(
            Zumzum__Product__c = productCourse.Id,
            Zumzum__Nominal_Account__c = nominalAccount.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Quantity__c = LINE_ITEM_QUANTITY,
            Zumzum__Tax_Rate__c = taxRate.Id,
            Zumzum__Foreign_Net_Amount__c = LINE_ITEM_AMOUNT,
            Zumzum__Amount__c = LINE_ITEM_AMOUNT,
            Zumzum__Foreign_Net_Total__c = LINE_ITEM_AMOUNT,
            Zumzum__Foreign_Gross__c = LINE_ITEM_AMOUNT,
            Zumzum__Total_Gross__c = LINE_ITEM_AMOUNT,
            Zumzum__Sales_Invoice__c = salesCredit.Id
        );
        insert new List<Zumzum__Sales_Invoice_Line_Item__c>{salesInvoiceLineItem, salesCreditLineItem};
        
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder
            .withRecordType('Client')
            .withAccount(customer)
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
        List<cpm__Installment__c> installments = new List<cpm__Installment__c>();
        for(Integer i = 0; i < paymentIds.size(); i++) {
            installments.add(installmentBuilder
                .withAccount(customer.Id)
                .withPrimaryContact(primaryContact.Id)
                .withBankDetailsNumber('331257')
                .withSalesInvoice(salesInvoice.Id)
                .insertRecord(false)
                .build()
            );
        }
        insert installments;

        TestPaymentBuilder paymentBuilder = new TestPaymentBuilder();
        List<cpm__Payment__c> payments = new List<cpm__Payment__c>();
        for (Integer i = 0; i < paymentIds.size(); i++) {
            payments.add(paymentBuilder
                .withPaymentReference(String.valueOf(i))
                .withAccount(customer.Id)
                .withAmount((Math.mod(i, 2) == 0) ? - 100.00 : 100.00)
                .withPrimaryContact(primaryContact.Id)
                .withPaymentProfile(paymentProfile.Id)
                .withInstallment(installments[i].Id)
                .insertRecord(false)
                .build()
            );
        }
        insert payments;

        Zumzum__Batch_Bank_Receipt__c batchBankReceipt = new Zumzum__Batch_Bank_Receipt__c(
            Zumzum__Bank__c = bankAccount.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Company_Currency__c = transactionCurrency.Id,
            Zumzum__Type__c = 'Electronic'
        );
        insert batchBankReceipt;
        
        List<Zumzum__Bank_Receipt__c> reciepts = new List<Zumzum__Bank_Receipt__c>();
        for (cpm__Payment__c payment : payments) {
            reciepts.add(new Zumzum__Bank_Receipt__c(
                Zumzum__Amount__c = 100.00,
                Zumzum__Bank__c = bankAccount.Id,
                Zumzum__Company__c = company.Id,
                Zumzum__Status__c = 'Draft',
                Zumzum__Batch_Bank_Receipt__c = batchBankReceipt.Id,
                Zumzum__Date__c = Date.today() - 10,
                Payment__c = payment.Id,
                Zumzum__Type__c = 'Electronic'
            ));
        }
        insert reciepts;

        TestBatchBankPaymentBuilder batchBankPaymentBuilder = new TestBatchBankPaymentBuilder();
        Zumzum__Batch_Bank_Payment__c batchBankPayment = batchBankPaymentBuilder
				.withStatus('Approved')
				.withPaymentType('Bulk list debit')
				.withType('Cash')
				.insertRecord(true)
				.build();
		TestBankPaymentBuilder bankPaymentBuilder = new TestBankPaymentBuilder();
		Zumzum__Bank_Payment__c bankPayment = bankPaymentBuilder
				.withStatus('Approved')
				.withAmount(120)
				.withSupplier(customer.Id)
				.withBatchBankPayment(batchBankPayment.id)
				.insertRecord(true)
                .build();
                
        List<Zumzum__Ledger__c> ledgers = new List<Zumzum__Ledger__c>();
        for (Integer i = 0; i < reciepts.size(); i++) {
            ledgers.add(new Zumzum__Ledger__c(
                Zumzum__Company__c = company.Id,
                Zumzum__Transaction_Currency__c = transactionCurrency.Id,
                Zumzum__Trans_Date__c = Date.today() - 5,
                Zumzum__Sub_Account_Nominal_Link__c = nominalAccount.Id,
                Zumzum__Sales_Invoice__c = salesInvoice.Id,
                Zumzum__Sales_Invoice_Line_Item__c = salesInvoiceLineItem.Id,
                Zumzum__Bank_Receipt__c = receiptReportItems.get(i).Amount__c > 0 ? reciepts[i].Id : null,
                Zumzum__Bank_Payment__c = receiptReportItems.get(i).Amount__c < 0 ? bankPayment.Id : null
            ));
        }
        insert ledgers;

        List<Zumzum__Ledger_Payment_History__c> paymentAllocationList = new List<Zumzum__Ledger_Payment_History__c>();
        for (Zumzum__Ledger__c ledger : ledgers) {
            if (ledger.Zumzum__Bank_Payment__c != null) {
                paymentAllocationList.add(new Zumzum__Ledger_Payment_History__c(
                    Zumzum__Amount__c = salesCreditLineItem.Zumzum__Amount__c,
                    Zumzum__Type__c = 'SC',
                    Zumzum__Company__c = company.Id,
                    Zumzum__Sales_Credit__c = salesCredit.Id,
                    Zumzum__Sales_Credit_Line_Item__c = salesCreditLineItem.Id,
                    Zumzum__Bank_Payment__c = bankPayment.Id,
                    Zumzum__Parent_Transaction__c = ledger.Id
                ));
            }
        }
        insert paymentAllocationList;
    }

    @isTest
    static void reconconcilePaymentsReconcileRecordsCreated() {
        Batch_Receipt_Report__c batchReceiptReport = [SELECT Id FROM Batch_Receipt_Report__c LIMIT 1];

        Test.startTest();
        ReconcilePaymentsBatch.runBatch(new List<Id>{batchReceiptReport.Id});
        Test.stopTest();

        List<Zumzum__BankReconcile__c> bankReconciles = [SELECT Id FROM Zumzum__BankReconcile__c];
        Batch_Receipt_Report__c batchReceiptReportReconciled = [SELECT Id, BankReconcile__c FROM Batch_Receipt_Report__c LIMIT 1];
        System.assertEquals(1, bankReconciles.size());
        System.assertEquals(bankReconciles[0].Id, batchReceiptReportReconciled.BankReconcile__c);
        for (Zumzum__Ledger__c ledger : [SELECT Id, Zumzum__Bank_Reconcile__c, Zumzum__BankReconcile__c FROM Zumzum__Ledger__c]) {
            System.assertEquals(bankReconciles[0].Id, ledger.Zumzum__BankReconcile__c);
            System.assertEquals('N', ledger.Zumzum__Bank_Reconcile__c);            
        }
    }
}