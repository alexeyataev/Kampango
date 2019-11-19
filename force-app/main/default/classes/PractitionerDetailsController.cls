public without sharing class PractitionerDetailsController {

    public Course__c courseRecord {get; set;}

    public List<Contact> getPractitioners() {

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
