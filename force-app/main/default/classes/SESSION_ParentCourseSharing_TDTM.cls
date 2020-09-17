@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #150 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class SESSION_ParentCourseSharing_TDTM extends npsp.TDTM_Runnable {  
    private static final String APEX_SHARING_REASON_SESSION_PRACTITIONER = 'Session_Practitioner__c';
    private static final String ACCESS_LEVEL_READ = 'Read';
    private Map<Id, Id> userIdsByPractitionerIds = new Map<Id,Id>();

    @SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #151 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> newSessions = (List<Session__c>) triggerNew;
        List<Session__c> oldSessions = (List<Session__c>) triggerOld;
        List<Course__Share> courseSharesToInsert = new List<Course__Share>();
        List<Course__Share> courseSharesToDelete = new List<Course__Share>();
        Map<String, List<Session__c>> changedSessions = new Map<String, List<Session__c>>();

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            courseSharesToInsert.addAll(insertCourseSharesSessionInserted(newSessions));
        } else if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            changedSessions = getChangedSessionsSessionUpdated(newSessions, oldSessions);
            courseSharesToInsert.addAll(insertCourseSharesSessionInserted(changedSessions.get('NewSessions')));
            courseSharesToDelete.addAll(deleteCourseSharesSessionDeleted(changedSessions.get('OldSessions')));
        } else if (triggerAction == npsp.TDTM_Runnable.Action.AfterDelete) {
            courseSharesToDelete.addAll(deleteCourseSharesSessionDeleted(oldSessions));
        }

        dmlWrapper.objectsToInsert.addAll(courseSharesToInsert);
        dmlWrapper.objectsToDelete.addAll(courseSharesToDelete);
        return dmlWrapper;
    }


    private List<Course__Share> insertCourseSharesSessionInserted(List<Session__c> newSessions) {
        List<Course__Share> courseSharesToInsert = new List<Course__Share>();
        Map<Id, Set<Id>> userIdsByCourseIds = getCoursesToShareWithUsers(newSessions);
        userIdsByCourseIds = removeUsersWithExistingCourseSharing(userIdsByCourseIds);
        courseSharesToInsert = createShareRecords(userIdsByCourseIds);
        return courseSharesToInsert;
    }


    private List<Course__Share> deleteCourseSharesSessionDeleted(List<Session__c> oldSessions) {
        List<Course__Share> courseSharesToDelete = new List<Course__Share>();
        Map<Id, Set<Id>> userIdsByCourseIds = getCoursesToShareWithUsers(oldSessions);
        courseSharesToDelete = getCourseSharesToDelete(userIdsByCourseIds, oldSessions);
        return courseSharesToDelete;
    }


    private  Map<String, List<Session__c>> getChangedSessionsSessionUpdated(List<Session__c> newSessions, List<Session__c> oldSessions) {
        Map<String, List<Session__c>> changedSessions = new Map<String, List<Session__c>>{
            'NewSessions' => new List<Session__c>(),
            'OldSessions' => new List<Session__c>()
        };
        Map<Id, Session__c> oldSessionsMap = new Map<Id, Session__c>(oldSessions);

        for (Session__c session : newSessions) {
            if (oldSessionsMap.get(session.Id).Practitioner__c != session.Practitioner__c) {
                changedSessions.get('NewSessions').add(session);
                changedSessions.get('OldSessions').add(oldSessionsMap.get(session.Id));
            }            
        }
        return changedSessions;
    }


    private Map<Id, Set<Id>> getCoursesToShareWithUsers(List<Session__c> sessionsToCheck) {
        Map<Id, Set<Id>> userIdsByCourseIds = new Map<Id, Set<Id>>();
        Set<Id> courseIds = new Set<Id>();
        Set<Id> practitionerIds = new Set<Id>();

        for (Session__c session : sessionsToCheck) {
            courseIds.add(session.Course__c);
            practitionerIds.add(session.Practitioner__c);
        }

        List<Course__c> coursesWithSessions = [
            SELECT Id, (
                SELECT Practitioner__c 
                FROM Sessions__r 
                WHERE Practitioner__c IN :practitionerIds
                )
            FROM Course__c
            WHERE Id IN :courseIds
                AND Main_Practitioner__c NOT IN :practitionerIds
            WITH SECURITY_ENFORCED
        ];

        userIdsByPractitionerIds = getPractitionersWithUserIds(practitionerIds);

        if (!userIdsByPractitionerIds.isEmpty()) {
            for (Course__c course : coursesWithSessions) {
                for (Session__c session : course.Sessions__r) {
                    if (userIdsByCourseIds.containsKey(course.Id)) {
                        userIdsByCourseIds.get(course.Id).add(userIdsByPractitionerIds.get(session.Practitioner__c));        
                    } else {
                        userIdsByCourseIds.put(course.Id, new Set<Id>{userIdsByPractitionerIds.get(session.Practitioner__c)});
                    } 
                }
            }
        }
        return userIdsByCourseIds;
    }


    private Map<Id, Id> getPractitionersWithUserIds(Set<Id> practitionerIds) {
        Map<Id, Id> userIdsByPractitionerIds = new Map<Id, Id>();
        List<User> usersWithContactIds = [
            SELECT ContactId
            FROM User
            WHERE ContactId IN :practitionerIds
            WITH SECURITY_ENFORCED
        ];

        for (User user : usersWithContactIds) {
            userIdsByPractitionerIds.put(user.ContactId, user.Id);
        }
        return userIdsByPractitionerIds;
    }


    private Map<Id, Set<Id>> removeUsersWithExistingCourseSharing(Map<Id, Set<Id>> userIdsByCourseIds) {
        Set<Id> userIds = new Set<Id>();

        for (Id courseId : userIdsByCourseIds.keySet()) {
            for (Id userId : userIdsByCourseIds.get(courseId)) {
                userIds.add(userId);
            }
        }

        for (Course__Share courseShare : [
            SELECT ParentId, UserOrGroupId
            FROM Course__Share
            WHERE ParentId IN :userIdsByCourseIds.keySet() 
                AND UserOrGroupId IN :userIds
            WITH SECURITY_ENFORCED
        ]) {
            if (userIdsByCourseIds.containsKey(courseShare.ParentId) && userIdsByCourseIds.get(courseShare.ParentId).contains(courseShare.UserOrGroupId)) {
                for (Id userId : userIdsByCourseIds.get(courseShare.ParentId)) {
                    if (userId == courseShare.UserOrGroupId) {
                        userIdsByCourseIds.get(courseShare.ParentId).remove(userId);
                        if (userIdsByCourseIds.get(courseShare.ParentId).isEmpty()) {
                            userIdsByCourseIds.remove(courseShare.ParentId);
                        }
                    }
                }
            }
        }
        return userIdsByCourseIds;
    }


    private List<Course__Share> createShareRecords(Map<Id, Set<Id>> userIdsByCourseIds) {
        List<Course__Share> courseSharesToInsert = new List<Course__Share>();

        for (Id courseId : userIdsByCourseIds.keySet()) {
            for (Id userId : userIdsByCourseIds.get(courseId)) {
                Course__Share courseShr = new Course__Share();
                courseShr.ParentId = courseId;
                courseShr.UserOrGroupId = userId;
                courseShr.AccessLevel = ACCESS_LEVEL_READ;
                courseShr.RowCause = APEX_SHARING_REASON_SESSION_PRACTITIONER;
                courseSharesToInsert.add(courseShr);
            }
        }
        return courseSharesToInsert;
    }


    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #152 - https://confluence.nct.org.uk:8443/x/EoSO
    private List<Course__Share> getCourseSharesToDelete(Map<Id, Set<Id>> userIdsByCourseIds, List<Session__c> sessionsToCheck) {
        Map<Id, Set<Id>> practitionerIdsByCourseIds = new Map<Id,Set<Id>>();
        
        for (Session__c session : sessionsToCheck) {
            if (practitionerIdsByCourseIds.containsKey(session.Course__c)) {
                practitionerIdsByCourseIds.get(session.Course__c).add(session.Practitioner__c);        
            } else {
                practitionerIdsByCourseIds.put(session.Course__c, new Set<Id>{session.Practitioner__c});
            } 
        }

        for (Id courseId : userIdsByCourseIds.keySet()) {
            for (Id userId : userIdsByCourseIds.get(courseId)) {
                for (Id practitionerId : practitionerIdsByCourseIds.get(courseId)) {
                    if (userIdsByPractitionerIds.get(practitionerId) == userId) {
                        userIdsByPractitionerIds.remove(practitionerId);
                    }
                }
            }
        }

        return [
            SELECT ParentId, UserOrGroupId 
            FROM Course__Share
            WHERE ParentId IN :practitionerIdsByCourseIds.keySet() 
                AND UserOrGroupId IN :userIdsByPractitionerIds.values()
            WITH SECURITY_ENFORCED
        ];
    }    
}
