public with sharing class ReconcilePaymentsBatch implements Database.Batchable<sObject>{
    public Id recordId;

    public ReconcilePaymentsBatch(Id recordId) {
        this.recordId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, Batch_Id__c, From_Date__c, To_Date__c,
                (
                    SELECT Id, Amount__c, Bank_Receipt__c, Payment_Id__c
                    FROM Batch_Receipt_Report_Items__r
                )
            FROM Batch_Receipt_Report__c
            WHERE Id =: recordId
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Batch_Receipt_Report__c> receipts) {
        for (Batch_Receipt_Report__c receipt : receipts) {
            ReconcilePaymentsBatchHelper.processBatchReceiptReport(receipt);
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<Batch_Receipt_Report__c> batchReceiptReports = [
            SELECT Id, Status__c
            FROM Batch_Receipt_Report__c
            WHERE Id =: recordId
        ];
        for (Batch_Receipt_Report__c brr : batchReceiptReports) {
            brr.Status__c = ReconcilePaymentsBatchHelper.CREATED_STATUS;
        }
        update batchReceiptReports;
    }

    @InvocableMethod(
        label='Reconcile Payments'
    )
    public static void runBatch(List<Id> batchReceiptReportId) {
        ReconcilePaymentsBatch reconcileBatch = new ReconcilePaymentsBatch(batchReceiptReportId[0]);
        Id batchId = Database.executeBatch(reconcileBatch, 1);
    }
}