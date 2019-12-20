public without sharing class ContactDetailsController {

    public List<Id> contactIds {get; set;}
    public String contactFieldSetName {get; set;}

    public List<Contact> getContacts() {

        String query = 'SELECT ';
        for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.Contact.fieldSets.getMap().get(contactFieldSetName).getFields()) {
            query += fieldSetMember.getFieldPath() + ', ';
        }
        query += 'Id FROM Contact WHERE Id IN :contactIds WITH SECURITY_ENFORCED';
        
        return Database.query(query);
    }
}
