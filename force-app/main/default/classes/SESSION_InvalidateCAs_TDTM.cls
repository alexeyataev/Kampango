global with sharing class SESSION_InvalidateCAs_TDTM extends npsp.TDTM_Runnable{
    private static final String CA_INVALIDATED_STATUS = 'Invalidated';
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> newSessionList = (List<Session__c>) triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            courseAssignmentsToUpdate.addAll(IdsOfCourseAssignmentsToChangeIfSessionsUpdated(newSessionList, oldSessionList));
        }else if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){
            courseAssignmentsToUpdate.addAll(IdsOfCourseAssignmentsToChangeIfSessionsInsertedOrDeleted(newSessionList));
        }else if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){
            courseAssignmentsToUpdate.addAll(IdsOfCourseAssignmentsToChangeIfSessionsInsertedOrDeleted(oldSessionList));
        }

        dmlWrapper.objectsToUpdate.addAll(courseAssignmentsToUpdate);
        return dmlWrapper;
    }
    //NOPMD
    //Incident #5 - https://confluence.nct.org.uk:8443/x/EoSO

    private List<Course_Assignment__c> IdsOfCourseAssignmentsToChangeIfSessionsUpdated(List<Session__c> newSessionList, List<Session__c> oldSessionList) {
        Set<Id> courseAssignmentIds = new Set<Id>();
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();
        for(Integer i = 0; i<newSessionList.size(); i++) {
            if(newSessionList[i].Course_Assignment__c != NULL) {
                if((newSessionList[i].Type__c != 'Reunion' &&
                    (newSessionList[i].Date__c != oldSessionList[i].Date__c ||
                        newSessionList[i].Start__c != oldSessionList[i].Start__c ||
                        newSessionList[i].End__c != oldSessionList[i].End__c ||
                        newSessionList[i].Lunch_Break_Minutes__c != oldSessionList[i].Lunch_Break_Minutes__c ||
                        newSessionList[i].Venue__c != oldSessionList[i].Venue__c ||
                        newSessionList[i].Room__c != oldSessionList[i].Room__c)) ||
                    (newSessionList[i].Type__c == 'Reunion' && newSessionList[i].Status__c == 'Confirmed'
                        && oldSessionList[i].Status__c == 'Provisional') ||
                    (newSessionList[i].Practitioner__c != oldSessionList[i].Practitioner__c)) {
                    courseAssignmentIds.add(newSessionList[i].Course_Assignment__c);
                }
            }
        }

        List<Course_Assignment__c> courseAssignments = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id IN : courseAssignmentIds
            AND Status__c != :CA_INVALIDATED_STATUS
            WITH SECURITY_ENFORCED
        ];
        //NOPMD
        //Incident #4 - https://confluence.nct.org.uk:8443/x/EoSO
        if(!courseAssignments.isEmpty()) {
            for(Course_Assignment__c assignment : courseAssignments){
                assignment.Status__c = CA_INVALIDATED_STATUS;
                courseAssignmentsToUpdate.add(assignment);
            }
        }
        return courseAssignmentsToUpdate;
    }

    private List<Course_Assignment__c> IdsOfCourseAssignmentsToChangeIfSessionsInsertedOrDeleted(List<Session__c> sessionsToIterate) {
        List<Course_Assignment__c> courseAssignments = new List<Course_Assignment__c>();
        Set<Id> practitionerIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();
        for(Session__c aSession : sessionsToIterate) {
            practitionerIds.add(aSession.Practitioner__c);
            courseIds.add(aSession.Course__c);
        }
        List<User> partnerCommunityUsers =[SELECT Id FROM User WHERE ContactId IN :practitionerIds];

        List<Course__c> courseWithCAs = [
            SELECT OwnerId,
                (SELECT Status__c
                FROM Course_Assignments__r
                WHERE OwnerId IN :partnerCommunityUsers
                AND Status__c != :CA_INVALIDATED_STATUS)
            FROM Course__c
            WHERE Id IN :courseIds
        ];

        for(Course__c aCourse : courseWithCAs){
            for(Course_Assignment__c courseAssignment : aCourse.Course_Assignments__r){
                courseAssignment.Status__c = CA_INVALIDATED_STATUS;
                courseAssignments.add(courseAssignment);
            }
        }
        return courseAssignments;
    }
}
//NOPMD
//Incident #6 - https://confluence.nct.org.uk:8443/x/EoSO