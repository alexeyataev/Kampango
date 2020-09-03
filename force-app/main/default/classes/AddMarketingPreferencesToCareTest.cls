@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #65 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class AddMarketingPreferencesToCareTest {
    private static final String ERROR_NUMBER = '400';
    private static final String MESSAGE_TEXT_ERROR = 'Error Test Reason Message';
    private static final String MESSAGE_TEXT_HTTP_ERROR = 'HTTP Error Reason Message';
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
        List<Individual> individualInstance = [SELECT Has_Opted_In_SMS__c, Has_Opted_In_Telephone__c, Has_Opted_In_Post__c, Has_Opted_In_Email__c FROM Individual LIMIT 1];
        individualInstance[0].Has_Opted_In_SMS__c = true;
        individualInstance[0].Has_Opted_In_Post__c = true;
        update individualInstance;
        Test.startTest();
        CareHelper.MarketingPreferencesObject marketingPreferencesObject = new CareHelper.MarketingPreferencesObject();
        CareHelper.MarketingPreferencesDetails marketingPreferencesDetails = new CareHelper.MarketingPreferencesDetails();
        marketingPreferencesDetails.standardDocument = 'GDPR010';
        marketingPreferencesDetails.documentNumber = '2080834';
        marketingPreferencesDetails.docType = 'GDPR';
        marketingPreferencesObject.document = marketingPreferencesDetails;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(marketingPreferencesObject));
        AddMarketingPreferencesToCare.Params paramsInstance = new AddMarketingPreferencesToCare.Params();
        paramsInstance.contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        AddMarketingPreferencesToCare.addMarketingPreferencesAction(new List<AddMarketingPreferencesToCare.Params>{ paramsInstance });
        System.assertEquals(individualInstance.size(), 1, 'Should be returned 1 Individual record');
        Test.stopTest();
    }
    @isTest
    static void AddMarketingPreferencesError_MarketingPreferencesNotAdded_ErrorReturned() {
        List<Individual> individualInstance = [SELECT Has_Opted_In_SMS__c, Has_Opted_In_Telephone__c, Has_Opted_In_Post__c, Has_Opted_In_Email__c FROM Individual LIMIT 1];
        individualInstance[0].Has_Opted_In_SMS__c = true;
        individualInstance[0].Has_Opted_In_Post__c = true;
        update individualInstance;
        Test.startTest();
        CareHelper.MarketingPreferencesObject marketingPreferencesObject = new CareHelper.MarketingPreferencesObject();
        CareHelper.ErrorObject errorObject = new CareHelper.ErrorObject();
        errorObject.errorMessage = MESSAGE_TEXT_ERROR;
        errorObject.errorNumber = ERROR_NUMBER;
        marketingPreferencesObject.error = new List<CareHelper.ErrorObject>();
        marketingPreferencesObject.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(marketingPreferencesObject));
        AddMarketingPreferencesToCare.Params paramsInstance = new AddMarketingPreferencesToCare.Params();
        paramsInstance.contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        AddMarketingPreferencesToCare.addMarketingPreferencesAction(new List<AddMarketingPreferencesToCare.Params>{ paramsInstance });
        Test.stopTest();
        Contact contUpdated = [SELECT Care_Status__c, Care_Error_Log__c FROM Contact LIMIT 1];
        System.assertEquals(contUpdated.Care_Status__c, CareHelper.FAILURE_STATUS);
        System.assert(contUpdated.Care_Error_Log__c.contains('Response:\r\n' + MESSAGE_TEXT_ERROR));
    }
    @isTest
    static void AddMarketingPreferencesHttpError_MarketingPreferencesNotAdded_ErrorReturned() {
        List<Individual> individualInstance = [SELECT Has_Opted_In_SMS__c, Has_Opted_In_Telephone__c, Has_Opted_In_Post__c, Has_Opted_In_Email__c FROM Individual LIMIT 1];
        individualInstance[0].Has_Opted_In_SMS__c = true;
        individualInstance[0].Has_Opted_In_Post__c = true;
        update individualInstance;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(MESSAGE_TEXT_HTTP_ERROR, false));
        AddMarketingPreferencesToCare.Params paramsInstance = new AddMarketingPreferencesToCare.Params();
        paramsInstance.contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        AddMarketingPreferencesToCare.addMarketingPreferencesAction(new List<AddMarketingPreferencesToCare.Params>{ paramsInstance });
        Test.stopTest();
        Contact contUpdated = [SELECT Care_Status__c, Care_Error_Log__c FROM Contact LIMIT 1];
        System.assertEquals(contUpdated.Care_Status__c, CareHelper.FAILURE_STATUS);
        System.assert(contUpdated.Care_Error_Log__c.contains('Response:\r\n' + MESSAGE_TEXT_HTTP_ERROR));
    }
}