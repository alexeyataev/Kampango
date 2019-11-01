public with sharing class CourseDetailController {

    @SuppressWarnings('PMD.ApexCRUDViolation')
    //Incident #26 - https://confluence.nct.org.uk:8443/x/EoSO
    @AuraEnabled(cacheable=true)
    public static List<Session__c> retrieveRelatedSessions(String courseId){
        return [
            SELECT Id, Date__c, Start__c, End__c, Venue__r.Town__c, Venue__r.Postcode__c, Venue__r.Street_Address__c,
                Venue__r.County__c, Venue__c, Venue__r.Name
            FROM Session__c
            WHERE Course__c = :courseId
            AND (Type__c != 'Reunion' OR (Type__c = 'Reunion' AND Status__c != 'Provisional'))
            WITH SECURITY_ENFORCED
            ORDER BY Date__c, Start__c
        ];
    }
}