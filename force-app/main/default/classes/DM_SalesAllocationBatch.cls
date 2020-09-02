/**
 * Created by johnp on 24/07/2020.
 */

global class DM_SalesAllocationBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Zumzum__Sales_Invoice__r.Zumzum__Account__c, Allocate_To__c FROM Zumzum__Sales_Invoice_Line_Item__c ' +
                'WHERE Allocate_To__c != NULL AND Zumzum__Sales_Invoice__r.Zumzum__Total_Unpaid_Amount__c > 0 ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Zumzum__Sales_Invoice_Line_Item__c> siLineItems){
        DM_SIPIAllocation.allocateSI(siLineItems);
    }

    global void finish(Database.BatchableContext BC){
    }
}