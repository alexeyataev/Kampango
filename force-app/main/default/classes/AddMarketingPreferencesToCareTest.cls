@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #65 - https://confluence.nct.org.uk:8443/x/EoSO
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
    static void AddMarketingPreferences_MarketingPreferencesAdded_DocumentReturned() {

        Individual individualInstance = [SELECT SMS__c, Telephone__c, Post__c, Email__c FROM Individual];
        individualInstance.SMS__c = true;
        individualInstance.Post__c = true;
        update individualInstance;

        Test.startTest();
            CareRequestBodyUtil.MarketingPreferencesObject marketingPreferencesObject = new CareRequestBodyUtil.MarketingPreferencesObject();
            CareRequestBodyUtil.MarketingPreferencesDetails marketingPreferencesDetails = new CareRequestBodyUtil.MarketingPreferencesDetails();
            marketingPreferencesDetails.standardDocument = 'GDPR010';
            marketingPreferencesDetails.documentNumber = '2080834';
            marketingPreferencesDetails.docType = 'GDPR';
            marketingPreferencesObject.document = marketingPreferencesDetails;
            Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(marketingPreferencesObject));
            AddMarketingPreferencesToCare.Params paramsInstance = new AddMarketingPreferencesToCare.Params();
            paramsInstance.contactId = [SELECT Id FROM Contact LIMIT 1].Id;
            AddMarketingPreferencesToCare.addMarketingPreferences(new List<AddMarketingPreferencesToCare.Params>{ paramsInstance });
        Test.stopTest();
    }
}
