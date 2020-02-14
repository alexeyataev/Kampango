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
                    Is_Location_At_Home__c,
                    Additional_Information__c,
                    Location_Postcode__c,
                    Location_Street__c,
                    Location_County__c,
                    Location_Town__c,
                    Location_Name__c,
                    Location_Id__c
            FROM Session__c
            WHERE Course__c = :courseId
            AND (Status__c = 'Confirmed' OR Type__c = 'Reunion')
            WITH SECURITY_ENFORCED
            ORDER BY Date__c, Start__c
        ];

        return sessions;
    }
}