global with sharing class ZumzumPurchaseInvoiceLa4V_TDTM extends npsp.TDTM_Runnable {
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        dlrs.RollupService.triggerHandler(objResult.getSObjectType());

        return null;
    }
}
