@SuppressWarnings('PMD.ApexSOQLInjection')
//Incident #49 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class SessionDetailsController {

    public Course__c courseRecord {get; set;}
    public String sessionFieldSetName {get; set;}

    public List<Session__c> getSessions() {

        String query = 'SELECT ';
        Id courseId = courseRecord.Id;

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Session__c.fieldSets.getMap().get(sessionFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Id FROM Session__c WHERE Course__c = :courseId WITH SECURITY_ENFORCED ORDER BY Date__c ASC';
        
        return Database.query(query);
    }
}