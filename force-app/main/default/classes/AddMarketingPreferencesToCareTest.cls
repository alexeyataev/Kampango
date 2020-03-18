@isTest
public with sharing class AddMarketingPreferencesToCareTest {

    @testSetup static void createTestData() {
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account account =  accountBuilder
            .withRecordType('Household Account')
            .withBranchNumber('777')
            .insertRecord(true)
            .build();

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder
            .withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Smith')
            .withNctNumber('1234567')
            .insertRecord(true)
            .build();
    }

    @isTest
    static void AddMarketingPreferencesToCareTest() {
        Test.startTest();
            AddMarketingPreferencesToCare.Params paramsInstance = new AddMarketingPreferencesToCare.Params();
            paramsInstance.contactId = [SELECT Id FROM Contact LIMIT 1].Id;
            AddMarketingPreferencesToCare.addMarketingPreferences(new List<AddMarketingPreferencesToCare.Params>{ paramsInstance });
        Test.stopTest();
    }
    
}
