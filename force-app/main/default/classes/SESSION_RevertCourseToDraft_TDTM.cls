@SuppressWarnings({'PMD.AvoidGlobalModifier', 'PMD.ExcessiveParameterList'})
//Incident #68 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class SESSION_RevertCourseToDraft_TDTM extends npsp.TDTM_Runnable{
    private static final String SESSION_STATUS_DRAFT = 'Draft';
    private static final String SESSION_TYPE_REUNION = 'Reunion';
     @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #23 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> newSessionList = (List<Session__c>) triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;
        List<Course__c> coursesToUpdate = new List<Course__c>();

        Set<Id> courseIds = new Set<Id>();

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            for (Session__c aSession : newSessionList) {
                courseIds.add(aSession.Course__c);
            }
        } else if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            courseIds.addAll(idsOfCoursesToChange(newSessionList, oldSessionList));

        } else if (triggerAction == npsp.TDTM_Runnable.Action.afterDelete) {
            for (Session__c aSession : oldSessionList) {
                courseIds.add(aSession.Course__c);
            }
        }

        List<Course__c> courses = [
            SELECT Id,
            Status__c
            FROM Course__c
            WHERE Id IN :courseIds
                AND Status__c != :SESSION_STATUS_DRAFT
            WITH SECURITY_ENFORCED
        ];
        //NOPMD
        //Incident #1 - https://confluence.nct.org.uk:8443/x/EoSO

        if(!courses.isEmpty()) {
            for (Course__c aCourse : courses) {
                aCourse.Status__c = SESSION_STATUS_DRAFT;
                coursesToUpdate.add(aCourse);
            }
        }
        dmlWrapper.objectsToUpdate.addAll(coursesToUpdate);
        return dmlWrapper;
    }
    //NOPMD
    //Incident #2 - https://confluence.nct.org.uk:8443/x/EoSO

    private Set<Id> idsOfCoursesToChange(List<Session__c> newSessionList,List<Session__c> oldSessionList) {
        Set<Id> courseIds = new Set<Id>();
        for(Integer i = 0; i<newSessionList.size(); i++) {
            Boolean fieldChanged = newSessionList[i].Date__c != oldSessionList[i].Date__c ||
                newSessionList[i].Start__c != oldSessionList[i].Start__c ||
                newSessionList[i].End__c != oldSessionList[i].End__c ||
                newSessionList[i].Lunch_Break_Minutes__c != oldSessionList[i].Lunch_Break_Minutes__c ||
                newSessionList[i].Practitioner_Licence__c != oldSessionList[i].Practitioner_Licence__c ||
                newSessionList[i].Venue__c != oldSessionList[i].Venue__c ||
                newSessionList[i].Status__c != oldSessionList[i].Status__c ||
                newSessionList[i].Room__c != oldSessionList[i].Room__c ||
                newSessionList[i].Practitioner__c != oldSessionList[i].Practitioner__c;

            Boolean isReunionSession = newSessionList[i].Type__c == SESSION_TYPE_REUNION &&
                                       oldSessionList[i].Type__c == SESSION_TYPE_REUNION; 
            if (fieldChanged && !isReunionSession) {
                courseIds.add(newSessionList[i].Course__c);
            }
        }
        return courseIds;
    }
}
//NOPMD
//Incident #3 - https://confluence.nct.org.uk:8443/x/EoSO