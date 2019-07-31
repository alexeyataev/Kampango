global class SESSION_RevertCourseToDraft_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> newSessionList = (List<Session__c>)triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;
        List<Course__c> courseToUpdate = new List<Course__c>();

        Set<Id> courseIds = new Set<Id>();

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            for(Session__c aSession : newSessionList) {
                courseIds.add(aSession.Course__c);
            }
        } else if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            for(Integer i = 0; i<newSessionList.size(); i++) {
                if (newSessionList[i].Date__c != oldSessionList[i].Date__c ||
                    newSessionList[i].Start__c != oldSessionList[i].Start__c ||
                    newSessionList[i].End__c != oldSessionList[i].End__c ||
                    newSessionList[i].Lunch_Break_Minutes__c != oldSessionList[i].Lunch_Break_Minutes__c ||
                    newSessionList[i].Practitioner_Licence__c != oldSessionList[i].Practitioner_Licence__c ||
                    newSessionList[i].Venue__c != oldSessionList[i].Venue__c) {
                    courseIds.add(newSessionList[i].Course__c);
                }
            }
        } else if (triggerAction == npsp.TDTM_Runnable.Action.afterDelete) {
            for(Session__c aSession : oldSessionList){
                courseIds.add(aSession.Course__c);
            }
        }

        for(Course__c aCourse : [SELECT Id, Status__c FROM Course__c WHERE Id IN :courseIds]){
            aCourse.Status__c = 'Draft';
            courseToUpdate.add(aCourse);
        }
        dmlWrapper.objectsToUpdate.addAll((List<Course__c>)courseToUpdate);
        return dmlWrapper;
    }
}