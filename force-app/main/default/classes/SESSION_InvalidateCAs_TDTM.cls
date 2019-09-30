global with sharing class SESSION_InvalidateCAs_TDTM extends npsp.TDTM_Runnable{
    private static final String COURSE_ASSIGNMENT_INVALIDATED_STATUS = 'Invalidated';
    private static final String COURSE_ASSIGNMENT_WITHDRAWN_STATUS = 'Withdrawn';
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> newSessionList = (List<Session__c>) triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            courseAssignmentsToUpdate.addAll(CourseAssignmentsToChangeIfSessionsUpdated(newSessionList, oldSessionList));
        }else if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){
            courseAssignmentsToUpdate.addAll(CourseAssignmentsToChangeIfSessionsInsertedOrDeleted(newSessionList));
        }else if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){
            courseAssignmentsToUpdate.addAll(CourseAssignmentsToChangeIfSessionsInsertedOrDeleted(oldSessionList));
        }

        dmlWrapper.objectsToUpdate.addAll(courseAssignmentsToUpdate);
        return dmlWrapper;
    }
    //NOPMD
    //Incident #5 - https://confluence.nct.org.uk:8443/x/EoSO

    private List<Course_Assignment__c> CourseAssignmentsToChangeIfSessionsUpdated(List<Session__c> newSessionList, List<Session__c> oldSessionList) {
        Set<Id> courseAssignmentIds = new Set<Id>();
        Set<Id> practitionerIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();

        for(Integer i = 0; i < newSessionList.size(); i++) {
            if(newSessionList[i].Course_Assignment__c != NULL) {
                if((newSessionList[i].Type__c != 'Reunion' &&
                    (newSessionList[i].Date__c != oldSessionList[i].Date__c ||
                        newSessionList[i].Start__c != oldSessionList[i].Start__c ||
                        newSessionList[i].End__c != oldSessionList[i].End__c ||
                        newSessionList[i].Lunch_Break_Minutes__c != oldSessionList[i].Lunch_Break_Minutes__c ||
                        newSessionList[i].Venue__c != oldSessionList[i].Venue__c ||
                        newSessionList[i].Room__c != oldSessionList[i].Room__c)) ||
                    (newSessionList[i].Type__c == 'Reunion' && newSessionList[i].Status__c == 'Confirmed'
                        && oldSessionList[i].Status__c == 'Provisional')) {
                    courseAssignmentIds.add(newSessionList[i].Course_Assignment__c);
                } else if(newSessionList[i].Practitioner__c != oldSessionList[i].Practitioner__c){
                    practitionerIds.add(oldSessionList[i].Practitioner__c);
                    courseIds.add(oldSessionList[i].Course__c);
                }
            }
        }

        List<User> partnerCommunityUsers = [
            SELECT Id
            FROM User
            WHERE ContactId IN :practitionerIds
            WITH SECURITY_ENFORCED
        ];

        List<Course__c> coursesSessionsAndCourseAssignmentsToWithdrawn = [
            SELECT Id,
                    (
                        SELECT Status__c
                        FROM Course_Assignments__r
                        WHERE OwnerId IN :partnerCommunityUsers
                            AND Status__c != :COURSE_ASSIGNMENT_WITHDRAWN_STATUS
                    ),
                    (
                        SELECT Id
                        FROM Sessions__r
                        WHERE Practitioner__c IN :practitionerIds
                    )
            FROM Course__c
            WHERE Id IN :courseIds
            WITH SECURITY_ENFORCED
        ];

        for(Course__c aCourse : coursesSessionsAndCourseAssignmentsToWithdrawn){
            for(Course_Assignment__c assignment : aCourse.Course_Assignments__r){
                if(aCourse.Sessions__r.isEmpty()){
                    assignment.Status__c = COURSE_ASSIGNMENT_WITHDRAWN_STATUS;
                    courseAssignmentsToUpdate.add(assignment);
                }else{
                    assignment.Status__c = COURSE_ASSIGNMENT_INVALIDATED_STATUS;
                    courseAssignmentsToUpdate.add(assignment);
                }
            }
        }

        List<Course_Assignment__c> courseAssignmentsToInvalidate = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id IN :courseAssignmentIds
                AND Status__c != :COURSE_ASSIGNMENT_INVALIDATED_STATUS
            WITH SECURITY_ENFORCED
        ];

        if(!courseAssignmentsToInvalidate.isEmpty()) {
            for(Course_Assignment__c assignment : courseAssignmentsToInvalidate){
                assignment.Status__c = COURSE_ASSIGNMENT_INVALIDATED_STATUS;
                courseAssignmentsToUpdate.add(assignment);
            }
        }

        //NOPMD
        //Incident #4 - https://confluence.nct.org.uk:8443/x/EoSO
        if(!courseAssignmentsToInvalidate.isEmpty()) {
            for(Course_Assignment__c assignment : courseAssignmentsToInvalidate){
                assignment.Status__c = COURSE_ASSIGNMENT_INVALIDATED_STATUS;
                courseAssignmentsToUpdate.add(assignment);
            }
        }
        return courseAssignmentsToUpdate;
    }

    private List<Course_Assignment__c> CourseAssignmentsToChangeIfSessionsInsertedOrDeleted(List<Session__c> sessionsToIterate) {
        List<Course_Assignment__c> courseAssignments = new List<Course_Assignment__c>();
        Set<Id> practitionerIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();

        for(Session__c aSession : sessionsToIterate) {
            practitionerIds.add(aSession.Practitioner__c);
            courseIds.add(aSession.Course__c);
        }

        List<User> partnerCommunityUsers =[
            SELECT Id
            FROM User
            WHERE ContactId IN :practitionerIds
            WITH SECURITY_ENFORCED
        ];

        List<Course__c> coursesSessionsAndCourseAssignmentsToWithdrawn = [
            SELECT Id,
                (
                    SELECT Status__c
                    FROM Course_Assignments__r
                    WHERE OwnerId IN :partnerCommunityUsers
                    AND Status__c != :COURSE_ASSIGNMENT_WITHDRAWN_STATUS
                ),
                (
                    SELECT Id
                    FROM Sessions__r
                    WHERE Practitioner__c IN :practitionerIds
                )
            FROM Course__c
            WHERE Id IN :courseIds
            WITH SECURITY_ENFORCED
        ];

        for(Course__c aCourse : coursesSessionsAndCourseAssignmentsToWithdrawn) {
            for(Course_Assignment__c courseAssignment : aCourse.Course_Assignments__r){
                if(aCourse.Sessions__r.isEmpty()){
                    courseAssignment.Status__c = COURSE_ASSIGNMENT_WITHDRAWN_STATUS;
                    courseAssignments.add(courseAssignment);
                }else{
                    courseAssignment.Status__c = COURSE_ASSIGNMENT_INVALIDATED_STATUS;
                    courseAssignments.add(courseAssignment);
                }
            }
        }
        return courseAssignments;
    }
}
//NOPMD
//Incident #6 - https://confluence.nct.org.uk:8443/x/EoSO