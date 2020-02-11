@SuppressWarnings('PMD.ApexSOQLInjection')
//Incident #48 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class PractitionerDetailsController {

    public Course__c courseRecord {get; set;}
    public String practitionerFieldSetName {get; set;}

    public List<Contact> getPractitioners() {

        String query = 'SELECT ';
        Id courseId = courseRecord.Id;

        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Contact.fieldSets.getMap().get(practitionerFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Id FROM Contact WHERE Id IN (SELECT Practitioner__c FROM Session__c WHERE Course__c = :courseId) WITH SECURITY_ENFORCED';
        
        return Database.query(query);
    }
}
