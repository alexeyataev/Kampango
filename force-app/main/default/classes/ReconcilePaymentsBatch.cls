public class ReconcilePaymentsBatch implements Database.Batchable<sObject>{
    public Id recordId;

    public ReconcilePaymentsBatch(Id recordId) {
        this.recordId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, Batch_Id__c, From_Date__c, To_Date__c,
                (
                    SELECT Id, Amount__c, Ledger__c, Payment_Id__c
                    FROM Batch_Receipt_Report_Items__r
                )
            FROM Batch_Receipt_Report__c
            WHERE Id =: recordId
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Batch_Receipt_Report__c> receipts) {
        for (Batch_Receipt_Report__c receipt : receipts) {
            system.debug('Receipt: ' + receipt);
            ReconcilePaymentsBatchHelper.processBatchReceiptReport(receipt);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    @InvocableMethod(
        label='Reconcile Payments'
    )
    public static void runBatch(List<Id> batchReceiptReportId) {
        ReconcilePaymentsBatch reconcileBatch = new ReconcilePaymentsBatch(batchReceiptReportId[0]);
        Id batchId = Database.executeBatch(reconcileBatch, 1);
    }

}
