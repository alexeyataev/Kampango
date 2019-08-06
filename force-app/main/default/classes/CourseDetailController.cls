public with sharing class CourseDetailController {

    @AuraEnabled(cacheable=true)
    public static List<Session__c> retrieveRelatedSessions(String courseId){
        List<Session__c> sessions;
        sessions = [
            SELECT Date__c, Start__c, End__c
            FROM Session__c
            WHERE Course__c = :courseId
        ];
        return sessions;
    }

}
