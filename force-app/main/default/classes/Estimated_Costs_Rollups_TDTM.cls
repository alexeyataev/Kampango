@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #125 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class Estimated_Costs_Rollups_TDTM extends npsp.TDTM_Runnable {
    @SuppressWarnings('PMD.ExcessiveParameterList')
    //127 - https://confluence.nct.org.uk:8443/x/EoSO

    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        Boolean doNeedToExecuteRollupService = triggerAction == npsp.TDTM_Runnable.Action.AfterInsert ||
                                               triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate ||
                                               triggerAction == npsp.TDTM_Runnable.Action.AfterDelete ||
                                               triggerAction == npsp.TDTM_Runnable.Action.AfterUndelete;

        if ( doNeedToExecuteRollupService == true ) {
            try {
                dlrs.RollupService.triggerHandler(objResult.getSObjectType());

            } catch (Exception e) {
                return dmlWrapper;
            }
        }

        return dmlWrapper;
    }
}