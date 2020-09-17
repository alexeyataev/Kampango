public class DM_SalesAllocationBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Zumzum__Sales_Invoice__r.Zumzum__Account__c, Allocate_To__c FROM Zumzum__Sales_Invoice_Line_Item__c ' +
                'WHERE Allocate_To__c != NULL AND Zumzum__Sales_Invoice__r.Zumzum__Total_Unpaid_Amount__c > 0 ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Zumzum__Sales_Invoice_Line_Item__c> siLineItems){
        DM_SIPIAllocation.allocateSI(siLineItems);
    }

    public void finish(Database.BatchableContext bc){
    }
}