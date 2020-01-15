public without sharing class SessionDetailsController {

    public Course__c courseRecord {get; set;}
    public String sessionFieldSetName {get; set;}

    public List<Session__c> getSessions() {

        String query = 'SELECT ';

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Session__c.fieldSets.getMap().get(sessionFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Id FROM Session__c WHERE Course__c = \'' + courseRecord.Id + '\' WITH SECURITY_ENFORCED ORDER BY Date__c ASC';
        
        return Database.query(query);
    }
}