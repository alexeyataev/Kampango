public with sharing class ContactProcessHelper {
    @InvocableMethod(label='Create Individual')
    public static void createIndividual(List<String> id) {
        List<Contact> contactList = [
            SELECT Id, IndividualId, FirstName, LastName, Salutation 
            FROM Contact 
            WHERE Id IN : id
        ];
        List<Individual> individualList = new List<individual>();
        for(Contact contact : contactList) {
            Individual individual = new Individual(
                FirstName = contact.FirstName,
                LastName = contact.LastName,
                Salutation =  contact.Salutation
            );
            individualList.add(individual);
        }
        insert individualList;
        for(Integer i = 0; i < individualList.size(); i++) {
            contactList[i].IndividualId = individualList[i].Id;
        }
        
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.DuplicateRuleHeader.AllowSave = true;
        Database.update(contactList, dmlOption);
    }
}