@isTest
private class ContactProcessHelperTest {
    @testSetup
    static void setupData() {
        TestContactBuilder contactBuilder = new TestContactBuilder();
        contactBuilder.withSalutation('Mr')
                      .withLastName('Test')
                      .withFirstName('Contact')
                      .withRecordType('Client')
                      .insertRecord(true)
                      .build();
    }

    @isTest
    static void createIndividual() {
        Contact contact = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        ContactProcessHelper.createIndividual(new List<String>{contact.Id});
        List<Individual> individuals = [
            SELECT FirstName, LastName
            FROM Individual
            WHERE FirstName =: contact.FirstName
            AND LastName =: contact.LastName
        ];
        System.assertEquals(2, individuals.size());
    }
}