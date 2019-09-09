global with sharing class SESSION_InvalidateCAs_TDTM extends npsp.TDTM_Runnable{
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> newSessionList = (List<Session__c>) triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();
        Set<Id> courseAssignmentIds = new Set<Id>();

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            courseAssignmentIds.addAll(IdsOfCourseAssignmentsToChange(newSessionList, oldSessionList));
        }

        List<Course_Assignment__c> courseAssignments = [SELECT Status__c
        FROM Course_Assignment__c
        WHERE Id IN : courseAssignmentIds
        AND Status__c != 'Invalidated'
        WITH SECURITY_ENFORCED];
        //NOPMD
        if(!courseAssignments.isEmpty()) {
            for(Course_Assignment__c assignment : courseAssignments){
                assignment.Status__c = 'Invalidated';
                courseAssignmentsToUpdate.add(assignment);
            }
        }

        dmlWrapper.objectsToUpdate.addAll((List<Course_Assignment__c>) courseAssignmentsToUpdate);
        return dmlWrapper;
    }
    //NOPMD
    private Set<Id> IdsOfCourseAssignmentsToChange(List<Session__c> newSessionList, List<Session__c> oldSessionList) {
        Set<Id> courseAssignmentIds = new Set<Id>();
        for(Integer i = 0; i<newSessionList.size(); i++) {
            if(newSessionList[i].Type__c != 'Reunion' &&
                (newSessionList[i].Date__c != oldSessionList[i].Date__c ||
                    newSessionList[i].Start__c != oldSessionList[i].Start__c ||
                    newSessionList[i].End__c != oldSessionList[i].End__c ||
                    newSessionList[i].Lunch_Break_Minutes__c != oldSessionList[i].Lunch_Break_Minutes__c ||
                    newSessionList[i].Venue__c != oldSessionList[i].Venue__c ||
                    newSessionList[i].Room__c != oldSessionList[i].Room__c)){
                courseAssignmentIds.add(newSessionList[i].Course_Assignment__c);
            } else if(newSessionList[i].Type__c == 'Reunion' &&
                (newSessionList[i].Status__c == 'Confirmed' && oldSessionList[i].Status__c == 'Provisional')){
                courseAssignmentIds.add(newSessionList[i].Course_Assignment__c);
            }else if(newSessionList[i].Practitioner__c != oldSessionList[i].Practitioner__c){
                courseAssignmentIds.add(newSessionList[i].Course_Assignment__c);
            }
        }
        return courseAssignmentIds;
    }
}
//NOPMD