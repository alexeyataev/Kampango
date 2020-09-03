@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #68 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class SESSION_RevertCourseToDraft_TDTM extends npsp.TDTM_Runnable{
    private static final String COURSE_STATUS_DRAFT = 'Draft';
    private static final String COURSE_STATUS_CANCELLING = 'Cancelling';
    private static final String COURSE_STATUS_CANCELLED = 'Cancelled';
    private static final String SESSION_TYPE_REUNION = 'Reunion';
     @SuppressWarnings('PMD.ApexCRUDViolation, PMD.ExcessiveParameterList')
    //Incident #23 - https://confluence.nct.org.uk:8443/x/EoSO
    //Incident #79 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> newSessionList = (List<Session__c>) triggerNew;
        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;
        List<Course__c> coursesToUpdate = new List<Course__c>();

        Set<Id> courseIds = new Set<Id>();

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            for (Session__c session : newSessionList) {
                courseIds.add(session.Course__c);
            }
        } else if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            courseIds.addAll(idsOfCoursesToChange(newSessionList, oldSessionList));

        } else if (triggerAction == npsp.TDTM_Runnable.Action.afterDelete) {
            for (Session__c session : oldSessionList) {
                courseIds.add(session.Course__c);
            }
        }

        List<Course__c> courses = [
            SELECT Id,
            Status__c
            FROM Course__c
            WHERE Id IN :courseIds
                AND Status__c NOT IN (:COURSE_STATUS_DRAFT, :COURSE_STATUS_CANCELLING, :COURSE_STATUS_CANCELLED)
            WITH SECURITY_ENFORCED
        ];

        if(!courses.isEmpty()) {
            for (Course__c course : courses) {
                course.Status__c = COURSE_STATUS_DRAFT;
                coursesToUpdate.add(course);
            }
        }
        dmlWrapper.objectsToUpdate.addAll(coursesToUpdate);
        return dmlWrapper;
    }

    private Set<Id> idsOfCoursesToChange(List<Session__c> newSessionList,List<Session__c> oldSessionList) {
        Set<Id> courseIds = new Set<Id>();
        Map<Id, Session__c> oldSessionMap = new Map<Id, Session__c>(oldSessionList);

        for (Session__c session : newSessionList) {
            Boolean condition = (session.Type__c != SESSION_TYPE_REUNION &&
                    oldSessionMap.get(session.Id).Type__c != SESSION_TYPE_REUNION) &&
                    (session.Hours__c != oldSessionMap.get(session.Id).Hours__c ||
                            session.Practitioner__c != oldSessionMap.get(session.Id).Practitioner__c ||
                            session.Practitioner_Licence__c != oldSessionMap.get(session.Id).Practitioner_Licence__c ||
                            session.Room__c != oldSessionMap.get(session.Id).Room__c ||
                            session.Status__c != oldSessionMap.get(session.Id).Status__c);
            if (condition) {
                courseIds.add(session.Course__c);
            }
        }
        return courseIds;
    }
}