public class DM_PurchaseAllocationBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Zumzum__Purchase_Invoice__r.Zumzum__Account__c, Allocate_To__c FROM Zumzum__Purchase_Invoice_Line_Item__c ' +
                'WHERE Allocate_To__c != NULL AND Zumzum__Purchase_Invoice__r.Zumzum__Total_Unpaid_Amount__c > 0 ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Zumzum__Purchase_Invoice_Line_Item__c> piLineItems) {
        DM_SIPIAllocation.allocatePI(piLineItems);
    }

    public void finish(Database.BatchableContext bc) {
    }
}
