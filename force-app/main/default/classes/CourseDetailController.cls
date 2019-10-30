public with sharing class CourseDetailController {

    @AuraEnabled(cacheable=true)
    public static List<Session__c> retrieveRelatedSessions(String courseId) {
        if ((Schema.sObjectType.Session__c.isAccessible() &&
                Schema.sObjectType.Session__c.fields.Date__c.isAccessible() &&
                Schema.sObjectType.Session__c.fields.Start__c.isAccessible() &&
                Schema.sObjectType.Session__c.fields.End__c.isAccessible() &&
                Schema.sObjectType.Session__c.fields.Venue__c.isAccessible()) &&
                (Schema.sObjectType.Venue__c.isAccessible() &&
                Schema.sObjectType.Venue__c.fields.Town__c.isAccessible() &&
                Schema.sObjectType.Venue__c.fields.Postcode__c.isAccessible() &&
                Schema.sObjectType.Venue__c.fields.Street_Address__c.isAccessible() &&
                Schema.sObjectType.Venue__c.fields.County__c.isAccessible() &&
                Schema.sObjectType.Venue__c.fields.Name.isAccessible())) {
        }
        return [
                SELECT Date__c, Start__c, End__c, Venue__r.Town__c, Venue__r.Postcode__c, Venue__r.Street_Address__c,
                        Venue__r.County__c, Venue__c, Venue__r.Name
                FROM Session__c
                WHERE Course__c = :courseId
                AND (Type__c != 'Reunion' OR (Type__c = 'Reunion' AND Status__c != 'Provisional'))
                ORDER BY Date__c, Start__c
        ];
    }
}