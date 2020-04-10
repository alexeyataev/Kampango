@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.ExcessiveParameterList')
//Incident #67 - https://confluence.nct.org.uk:8443/x/EoSO
//Incident #79 - https://confluence.nct.org.uk:8443/x/EoSO
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
            courseAssignmentsToUpdate.addAll(CourseAssignmentsToChangeIfSessionsInserted(newSessionList));
        }else if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){
            courseAssignmentsToUpdate.addAll(CourseAssignmentsToChangeIfSessionsDeleted(oldSessionList));
        }

        dmlWrapper.objectsToUpdate.addAll(courseAssignmentsToUpdate);
        return dmlWrapper;
    }
    

     @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #22 - https://confluence.nct.org.uk:8443/x/EoSO
    private List<Course_Assignment__c> courseAssignmentsToChangeIfSessionsUpdated(List<Session__c> newSessionList, List<Session__c> oldSessionList) {
        Set<Id> courseAssignmentIds = new Set<Id>();
        Set<Id> newPractitionerIds = new Set<Id>();
        Set<Id> oldPractitionerIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();
        Map<Id, Session__c> oldSessionMap = new Map<Id, Session__c>(oldSessionList);

        for (Session__c session : newSessionList) {
            Boolean condition = session.Course_Assignment__c != NULL &&
                    (session.Type__c != 'Reunion' || session.Status__c == 'Confirmed' ||
                            oldSessionMap.get(session.Id).Status__c == 'Confirmed') &&
                    (session.Date__c != oldSessionMap.get(session.Id).Date__c ||
                            session.Start__c != oldSessionMap.get(session.Id).Start__c ||
                            session.End__c != oldSessionMap.get(session.Id).End__c ||
                            session.Lunch_Break_Minutes__c != oldSessionMap.get(session.Id).Lunch_Break_Minutes__c ||
                            session.Venue__c != oldSessionMap.get(session.Id).Venue__c ||
                            session.Room__c != oldSessionMap.get(session.Id).Room__c ||
                            session.Status__c != oldSessionMap.get(session.Id).Status__c ||
                            session.Practitioner_Fee_Rate__c != oldSessionMap.get(session.Id).Practitioner_Fee_Rate__c);
            if (condition) {
                courseAssignmentIds.add(session.Course_Assignment__c);
            } else if (session.Practitioner__c != oldSessionMap.get(session.Id).Practitioner__c) {
                newPractitionerIds.add(session.Practitioner__c);
                oldPractitionerIds.add(oldSessionMap.get(session.Id).Practitioner__c);
                courseIds.add(oldSessionMap.get(session.Id).Course__c);
            } else if (session.Course_assignment__c != oldSessionMap.get(session.Id).Course_Assignment__c) {
                courseAssignmentIds.add(oldSessionMap.get(session.Id).Course_Assignment__c);                
            }
        }

        setCourseAssignmentsStatusDependOnWhetherPractitionerHasSessions(newPractitionerIds, courseIds, courseAssignmentsToUpdate);
        setCourseAssignmentsStatusDependOnWhetherPractitionerHasSessions(oldPractitionerIds, courseIds, courseAssignmentsToUpdate);
        
        List<Course_Assignment__c> courseAssignmentsToInvalidate = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id IN :courseAssignmentIds
                AND Status__c NOT IN (:COURSE_ASSIGNMENT_INVALIDATED_STATUS, :COURSE_ASSIGNMENT_WITHDRAWN_STATUS)
            WITH SECURITY_ENFORCED
        ];

        if(!courseAssignmentsToInvalidate.isEmpty()) {
            for(Course_Assignment__c assignment : courseAssignmentsToInvalidate){
                assignment.Status__c = COURSE_ASSIGNMENT_INVALIDATED_STATUS;
                courseAssignmentsToUpdate.add(assignment);
            }
        }

        
        return courseAssignmentsToUpdate;
    }


    private List<Course_Assignment__c> courseAssignmentsToChangeIfSessionsInserted(List<Session__c> sessionsToIterate) {
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();
        Set<Id> practitionerIds = new Set<Id>();
        Set<Id> courseIds = new Set<Id>();

        for(Session__c aSession : sessionsToIterate) {
            practitionerIds.add(aSession.Practitioner__c);
            courseIds.add(aSession.Course__c);
        }

        setCourseAssignmentsStatusDependOnWhetherPractitionerHasSessions(practitionerIds, courseIds, courseAssignmentsToUpdate);

        return courseAssignmentsToUpdate;
    }


    private List<Course_Assignment__c> courseAssignmentsToChangeIfSessionsDeleted(List<Session__c> sessionsToIterate) {
        List<Course_Assignment__c> courseAssignmentsToUpdate = new List<Course_Assignment__c>();
        Set<Id> courseAssignmentIds = new Set<Id>();

        for(Session__c aSession : sessionsToIterate) {
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }

        setCourseAssignmentsStatusDependOnWhetherAssignedSessions(courseAssignmentIds, courseAssignmentsToUpdate);

        return courseAssignmentsToUpdate;
    }

 
    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #19, 20 - https://confluence.nct.org.uk:8443/x/EoSO
    private static List<Course_Assignment__c> setCourseAssignmentsStatusDependOnWhetherPractitionerHasSessions(Set<Id> practitionerIds, Set<Id> courseIds, List<Course_Assignment__c> courseAssignmentsToUpdate) {
    
    List<User> partnerCommunityUsers = [
            SELECT Id
            FROM User
            WHERE ContactId IN :practitionerIds
            WITH SECURITY_ENFORCED
        ];

        List<Course__c> coursesSessionsAndCourseAssignmentsToWithdrawn = [
            SELECT Id,
                    (
                        SELECT Status__c, Number_of_Sessions__c
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
            for(Course_Assignment__c assignment : aCourse.Course_Assignments__r) {
                if(aCourse.Sessions__r.isEmpty() && assignment.Number_of_Sessions__c != 0) {
                    assignment.Status__c = COURSE_ASSIGNMENT_WITHDRAWN_STATUS;
                    courseAssignmentsToUpdate.add(assignment);
                } else {
                    assignment.Status__c = COURSE_ASSIGNMENT_INVALIDATED_STATUS;
                    courseAssignmentsToUpdate.add(assignment);
                }
            }
        }
        return courseAssignmentsToUpdate;
	}


    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #21 - https://confluence.nct.org.uk:8443/x/EoSO
    private static List<Course_Assignment__c> setCourseAssignmentsStatusDependOnWhetherAssignedSessions(Set<Id> courseAssignmentIds, List<Course_Assignment__c> courseAssignmentsToUpdate) {
    
    List<Course_Assignment__c> coursesAssignmentsToChangeStatus = [
            SELECT Status__c,
                (
                    SELECT Id
                    FROM Sessions__r
                )
            FROM Course_Assignment__c
            WHERE Id IN :courseAssignmentIds
                AND Status__c != :COURSE_ASSIGNMENT_WITHDRAWN_STATUS
            WITH SECURITY_ENFORCED
        ];

        for (Course_Assignment__c courseAssignment : coursesAssignmentsToChangeStatus) {
            if(courseAssignment.Sessions__r.isEmpty()) {
                courseAssignment.Status__c = COURSE_ASSIGNMENT_WITHDRAWN_STATUS;
                courseAssignmentsToUpdate.add(courseAssignment);
            } else {
                courseAssignment.Status__c = COURSE_ASSIGNMENT_INVALIDATED_STATUS;
                courseAssignmentsToUpdate.add(courseAssignment);
            }                 
        }

        return courseAssignmentsToUpdate;
	}
}