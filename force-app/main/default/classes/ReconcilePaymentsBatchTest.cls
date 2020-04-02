@isTest
private class ReconcilePaymentsBatchTest {
    @testSetup
    static void setupData() {
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
        List<String> paymentIds = financeDataFactory.createBatchReceiptReportWithItems(3);

        TestPaymentBuilder paymentBuilder = new TestPaymentBuilder();
        List<cpm__Payment__c> payments = new List<cpm__Payment__c>();
        for (Integer i = 0; i < paymentIds.size(); i++) {
            payments.add(paymentBuilder.withPaymentReference(String.valueOf(i))
                                       .insertRecord(false)
                                       .build());
        }
        insert payments;

        Zumzum__Bank_Account__c bankAccount = [SELECT Id FROM Zumzum__Bank_Account__c WHERE Name = 'Reconcile Bank' LIMIT 1];
        Zumzum__Company_Setup__c company = [SELECT Id FROM Zumzum__Company_Setup__c WHERE Name = 'NCT' LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c WHERE Name = 'GBP' LIMIT 1];
        Zumzum__Nominal_Account__c nominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Name = 'Staff Salaries' LIMIT 1];

        Zumzum__Batch_Bank_Receipt__c batchBankReceipt = new Zumzum__Batch_Bank_Receipt__c(
            Zumzum__Bank__c = bankAccount.Id,
            Zumzum__Company_Currency__c = transactionCurrency.Id,
            Zumzum__Type__c = 'Electronic'
        );
        insert batchBankReceipt;

        List<Zumzum__Bank_Receipt__c> reciepts = new List<Zumzum__Bank_Receipt__c>();
        for (cpm__Payment__c payment : payments) {
            reciepts.add(new Zumzum__Bank_Receipt__c(
                Zumzum__Amount__c = 100.00,
                Zumzum__Bank__c = bankAccount.Id,
                Zumzum__Status__c = 'Draft',
                Zumzum__Batch_Bank_Receipt__c = batchBankReceipt.Id,
                Zumzum__Date__c = Date.today() - 10,
                Payment__c = payment.Id,
                Zumzum__Type__c = 'Electronic'
            ));
        }
        insert reciepts;


        List<Zumzum__Ledger__c> ledgers = new List<Zumzum__Ledger__c>();
        for (Integer i = 0; i < reciepts.size(); i++) {
            ledgers.add(new Zumzum__Ledger__c(
                Zumzum__Transaction_Currency__c = transactionCurrency.Id,
                Zumzum__Trans_Date__c = Date.today() - 5,
                Zumzum__Sub_Account_Nominal_Link__c = nominalAccount.Id, 
                Zumzum__Bank_Receipt__c = reciepts[i].Id
            ));
        }
        insert ledgers;
    }

    @isTest
    static void reconconcilePaymentsReconcileRecordsCreated() {
        Batch_Receipt_Report__c batchReceiptReport = [SELECT Id FROM Batch_Receipt_Report__c LIMIT 1];

        Test.startTest();
            ReconcilePaymentsBatch.runBatch(new List<Id>{batchReceiptReport.Id});
        Test.stopTest();
        List<Zumzum__BankReconcile__c> bankReconciles = [SELECT Id FROM Zumzum__BankReconcile__c];
        
        System.assertEquals(1, bankReconciles.size());
    }
}