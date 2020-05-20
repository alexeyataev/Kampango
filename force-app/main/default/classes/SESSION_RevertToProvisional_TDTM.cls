@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #69 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class SESSION_RevertToProvisional_TDTM extends npsp.TDTM_Runnable {
    private static final String SESSION_TYPE_REUNION = 'Reunion';
    private static final String SESSION_STATUS_CONFIRMED = 'Confirmed';
    private static final String SESSION_STATUS_PROVISIONAL = 'Provisional';
    private static final String SESSION_DELIVERY_TYPE_PHYSICAL = 'Physical';
    @SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #80 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Session__c> newSessionList = (List<Session__c>) triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            compareNewListOfSessionsWithOldListAndSetSessionsToProvisional(newSessionList, oldSessionList);
        }

        return dmlWrapper;
    }

    private void compareNewListOfSessionsWithOldListAndSetSessionsToProvisional(List<Session__c> newSessionList, List<Session__c> oldSessionList) {
        Map<Id, Session__c> oldSessionMap = new Map<Id, Session__c>(oldSessionList);
        for (Session__c session : newSessionList) {
            if (oldSessionMap.get(session.Id).Status__c == SESSION_STATUS_CONFIRMED &&
                    (session.Date__c != oldSessionMap.get(session.Id).Date__c ||
                            session.Start__c != oldSessionMap.get(session.Id).Start__c ||
                            session.End__c != oldSessionMap.get(session.Id).End__c ||
                            session.Lunch_Break_Minutes__c != oldSessionMap.get(session.Id).Lunch_Break_Minutes__c ||
                            session.Delivery_Type__c != oldSessionMap.get(session.Id).Delivery_Type__c ||
                            (session.Venue__c != oldSessionMap.get(session.Id).Venue__c &&
                                    (session.Delivery_Type__c != SESSION_DELIVERY_TYPE_PHYSICAL ||
                                            session.Type__c == SESSION_TYPE_REUNION)))) {
                session.Status__c = SESSION_STATUS_PROVISIONAL;
            }
        }
    }
}