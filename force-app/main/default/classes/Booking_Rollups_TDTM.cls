//@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #99 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class Booking_Rollups_TDTM extends npsp.TDTM_Runnable {
    //@SuppressWarnings('PMD.ApexCRUDViolation, PMD.ExcessiveParameterList')
    //Incident #100 - https://confluence.nct.org.uk:8443/x/EoSO
    //Incident #101 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        try {
            dlrs.RollupService.triggerHandler(Booking__c.SObjectType);
        } catch(Exception e) {
            return dmlWrapper;
        }
        return dmlWrapper;
    }
}