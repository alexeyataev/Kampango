public with sharing class ContactProcessHelper {
    @InvocableMethod(label='Create Individual')
    public static void createIndividual(List<String> id) {
        Contact contact = [
            SELECT Id, IndividualId, FirstName, LastName, Salutation 
            FROM Contact 
            WHERE Id =: id[0]
            LIMIT 1
        ];
        Individual individual = new Individual(
            FirstName = contact.FirstName,
            LastName = contact.LastName,
            Salutation =  contact.Salutation
        );
        insert individual;
        contact.IndividualId = individual.Id;
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.DuplicateRuleHeader.AllowSave = true;
        Database.update(contact, dmlOption);
    }
}