public with sharing class CourseDetailController {

    @AuraEnabled(cacheable=true)
    public static List<Session__c> retrieveRelatedSessions(String courseId){
        List<Session__c> sessions;
        sessions = [
            SELECT  Date__c,
                    Start__c,
                    End__c,
                    Type__c,
                    Status__c,
                    Additional_Information__c,
                    Venue__c,
                    Venue__r.Town__c,
                    Venue__r.Postcode__c,
                    Venue__r.Street_Address__c,
                    Venue__r.County__c,
                    Venue__r.Name
            FROM Session__c
            WHERE Course__c = :courseId
            AND (Status__c = 'Confirmed' OR Type__c = 'Reunion')
            ORDER BY Date__c, Start__c
        ];

        return sessions;
    }

}
