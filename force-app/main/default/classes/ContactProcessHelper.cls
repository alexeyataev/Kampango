public with sharing class ContactProcessHelper {
    @InvocableMethod(label='Create Individual')
    public static void createIndividual(List<String> id) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, IndividualId, FirstName, LastName, Salutation 
            FROM Contact 
            WHERE Id IN : id
        ]);
        Map<Id, Individual> contactIndividualMap = new Map<Id, Individual>();
        for(Contact contact : contactMap.values()) {
            contactIndividualMap.put(
                contact.Id,
                new Individual(
                    FirstName = contact.FirstName,
                    LastName = contact.LastName,
                    Salutation =  contact.Salutation
                )
            );
        }
        insert contactIndividualMap.values();
        for(Id contactId : contactIndividualMap.keySet()) {
            contactMap.get(contactId).IndividualId = contactIndividualMap.get(contactId).Id;
        }
        
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.DuplicateRuleHeader.AllowSave = true;
        Database.update(contactMap.values(), dmlOption);
    }
}