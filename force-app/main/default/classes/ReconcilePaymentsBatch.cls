public with sharing class ReconcilePaymentsBatch implements Database.Batchable<sObject> {
    private static final String CREATED_STATUS = 'Created';
    public Id recordId;

    public ReconcilePaymentsBatch(Id recordId) {
        this.recordId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT 
                Amount__c, 
                Bank_Receipt__c, 
                Bank_Payment__c, 
                Batch_Receipt_Report__c, 
                Payment_Id__c 
            FROM Batch_Receipt_Report_Item__c 
            WHERE Batch_Receipt_Report__c = :recordId
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Batch_Receipt_Report_Item__c> receiptReportItems) {
        ReconcilePaymentsBatchHelper.processBatchReceiptReportItems(receiptReportItems);
    }

    public void finish(Database.BatchableContext bc) {
        List<Batch_Receipt_Report__c> batchReceiptReports = [
            SELECT Status__c 
            FROM Batch_Receipt_Report__c 
            WHERE Id = :recordId
        ];
        for (Batch_Receipt_Report__c brr : batchReceiptReports) {
            brr.Status__c = CREATED_STATUS;
        }
        update batchReceiptReports;
    }

    @InvocableMethod(label='Reconcile Payments')
    public static void runBatch(List<Id> batchReceiptReportId) {
        ReconcilePaymentsBatch reconcileBatch = new ReconcilePaymentsBatch(batchReceiptReportId[0]);
        Id batchId = Database.executeBatch(reconcileBatch, 200);
    }
}
