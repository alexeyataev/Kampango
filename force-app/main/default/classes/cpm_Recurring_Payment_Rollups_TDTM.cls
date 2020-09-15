// @SuppressWarnings('PMD.AvoidGlobalModifier, PMD.ClassNamingConventions')
//Incident #XXX - https://confluence.nct.org.uk:8443/x/EoSO
//Incident #XXX - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class cpm_Recurring_Payment_Rollups_TDTM extends npsp.TDTM_Runnable {
    //@SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #XXX - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        if (
            triggerAction == npsp.TDTM_Runnable.Action.AfterInsert ||
            triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate ||
            triggerAction == npsp.TDTM_Runnable.Action.AfterDelete ||
            triggerAction == npsp.TDTM_Runnable.Action.AfterUndelete
        ) {
            try {
                dlrs.RollupService.triggerHandler(objResult.getSObjectType());
            } catch (Exception e) {
                return dmlWrapper;
            }
        }
        return dmlWrapper;
    }
}
