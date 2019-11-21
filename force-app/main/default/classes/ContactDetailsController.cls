public without sharing class ContactDetailsController {
    
    public Course__c courseRecord {get; set;}

    public List<Contact> getContacts() {

        return [
            SELECT Name, Phone, Email
            FROM Contact 
            WHERE Id 
                IN (SELECT Practitioner__c 
                    FROM Session__c 
                    WHERE Course__c = :courseRecord.Id)
            WITH SECURITY_ENFORCED
        ];
    }
}
