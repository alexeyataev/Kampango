public without sharing class PractitionerDetailsController {

    public Course__c courseRecord {get; set;}
    public String practitionerFieldSetName {get; set;}

    public List<Contact> getPractitioners() {

        String query = 'SELECT ';
        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Contact.fieldSets.getMap().get(practitionerFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Id FROM Contact WHERE Id IN (SELECT Practitioner__c FROM Session__c WHERE Course__c = \'' + courseRecord.Id + '\') WITH SECURITY_ENFORCED';
        
        return Database.query(query);
    }
}
