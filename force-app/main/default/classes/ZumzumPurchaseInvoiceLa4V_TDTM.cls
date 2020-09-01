@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #124 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class ZumzumPurchaseInvoiceLa4V_TDTM extends npsp.TDTM_Runnable {
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        @SuppressWarnings('PMD.ExcessiveParameterList')
        //Incident #130 - https://confluence.nct.org.uk:8443/x/EoSO

        Boolean doNeedToExecuteRollupService = triggerAction == npsp.TDTM_Runnable.Action.AfterInsert ||
                                               triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate ||
                                               triggerAction == npsp.TDTM_Runnable.Action.AfterDelete;

        if ( doNeedToExecuteRollupService == true) {
            dlrs.RollupService.triggerHandler(objResult.getSObjectType());
        }

        return null;
    }
}
