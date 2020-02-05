@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #53 - https://confluence.nct.org.uk:8443/x/EoSO
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
                    Venue_Postcode__c,
                    Venue_Street__c,
                    Venue_County__c,
                    Venue_Town__c,
                    Venue_Name__c,
                    Venue_Id__c
            FROM Session__c
            WHERE Course__c = :courseId
            AND (Status__c = 'Confirmed' OR Type__c = 'Reunion')
            WITH SECURITY_ENFORCED
            ORDER BY Date__c, Start__c
        ];

        return sessions;
    }

}
