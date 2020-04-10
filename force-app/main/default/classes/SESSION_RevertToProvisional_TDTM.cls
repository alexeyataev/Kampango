@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.ExcessiveParameterList')
//Incident #69 - https://confluence.nct.org.uk:8443/x/EoSO
//Incident #81 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class SESSION_RevertToProvisional_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Session__c> newSessionList = (List<Session__c>) triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            compareNewListOfSessionsWithOldListAndSetSessionsToProvisional(newSessionList, oldSessionList);
        }

        return dmlWrapper;
    }
    //NOPMD
    //Incident #7 - https://confluence.nct.org.uk:8443/x/EoSO

    private void compareNewListOfSessionsWithOldListAndSetSessionsToProvisional(List<Session__c> newSessionList, List<Session__c> oldSessionList) {
        for (Integer i = 0; i < newSessionList.size(); i++) {
            if (oldSessionList[i].Status__c == 'Confirmed' &&
                (newSessionList[i].Date__c != oldSessionList[i].Date__c ||
                    newSessionList[i].Start__c != oldSessionList[i].Start__c ||
                    newSessionList[i].End__c != oldSessionList[i].End__c ||
                    newSessionList[i].Lunch_Break_Minutes__c != oldSessionList[i].Lunch_Break_Minutes__c ||
                    newSessionList[i].Venue__c != oldSessionList[i].Venue__c)) {
                newSessionList[i].Status__c = 'Provisional';
            }
        }
    }
}
//NOPMD
//Incident #8 - https://confluence.nct.org.uk:8443/x/EoSO