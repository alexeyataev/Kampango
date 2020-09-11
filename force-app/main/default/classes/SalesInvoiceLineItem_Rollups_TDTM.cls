global with sharing class SalesInvoiceLineItem_Rollups_TDTM extends npsp.TDTM_Runnable {
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        try {
            dlrs.RollupService.triggerHandler(Zumzum__Sales_Invoice_Line_Item__c.SObjectType);
        } catch(Exception e) {
            return dmlWrapper;
        }
        return dmlWrapper;
    }
}
