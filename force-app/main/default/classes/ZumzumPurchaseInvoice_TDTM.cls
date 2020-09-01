global with sharing class ZumzumPurchaseInvoice_TDTM {
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        dlrs.RollupService.triggerHandler(objResult.getSObjectType());

        return null;
    }
}
