@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public without sharing class AddContactForMembershipTest {
    private static final String CONTACT_NUMBER_RETURNED = '3325461';
    private static final String ERROR_NUMBER = '400';
    private static final String MESSAGE_TEXT_ERROR = 'Error';
    private static final String MESSAGE_TEXT_SUCCESS = 'Success';
    @testSetup static void createTestData() {
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account account =  accountBuilder
            .withRecordType('Household Account')
            .insertRecord(true)
            .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Smith')
            .withRecordType('Client')
            .withCareStatus('Waiting')
            .insertRecord(true)
            .build();
    }
    @isTest static void AddContact_ContactAdded_ContactNumberReturned() {
        Test.startTest();
        CareHelper.ContactObject contactObject = new CareHelper.ContactObject();
        CareHelper.ContactDetails contactDetails = new CareHelper.ContactDetails();
        contactDetails.contactNumber = CONTACT_NUMBER_RETURNED;
        contactObject.contact = contactDetails;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactObject));
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        List<String> contactIds = new List<String> {testContact.Id};
        List<AddContactResult> resultList = AddContactForMembershipHandler.addContact(contactIds);
        Test.stopTest();
        System.assertEquals(resultList[0].nctNumber, CONTACT_NUMBER_RETURNED);
    }
    @isTest static void AddContactError_ContactNotAdded_ErrorReturned() {
        Test.startTest();
        CareHelper.ContactObject contactObject = new CareHelper.ContactObject();
        CareHelper.ErrorObject errorObject = new CareHelper.ErrorObject();
        errorObject.errorMessage = MESSAGE_TEXT_ERROR;
        errorObject.errorNumber = ERROR_NUMBER;
        contactObject.error = new List<CareHelper.ErrorObject>();
        contactObject.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactObject));
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        List<String> contactIds = new List<String> {testContact.Id};
        List<AddContactResult> resultList = AddContactForMembershipHandler.addContact(contactIds);
        Test.stopTest();
        System.assert(resultList[0].error.contains('Response:\r\n' + MESSAGE_TEXT_ERROR));
    }
    @isTest static void AddContactBatch_ContactAdded_ContactNumberReturned() {
        Test.startTest();
        CareHelper.ContactObject contactObject = new CareHelper.ContactObject();
        CareHelper.ContactDetails contactDetails = new CareHelper.ContactDetails();
        contactDetails.contactNumber = CONTACT_NUMBER_RETURNED;
        contactObject.contact = contactDetails;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactObject));
        AddContactForMembershipBatch cacb = new AddContactForMembershipBatch();
        Database.executeBatch(cacb, 10);
        Test.stopTest();
        Contact contUpdated = [SELECT Care_Status__c, NCT_Number__c FROM Contact LIMIT 1];
        System.assertEquals(contUpdated.NCT_Number__c, CONTACT_NUMBER_RETURNED);
        System.assertEquals(contUpdated.Care_Status__c, MESSAGE_TEXT_SUCCESS);
    }
    @isTest static void AddContactBatchError_ContactNotAdded_ErrorReturned() {
        Test.startTest();
        CareHelper.ContactObject contactObject = new CareHelper.ContactObject();
        CareHelper.ErrorObject errorObject = new CareHelper.ErrorObject();
        errorObject.errorMessage = MESSAGE_TEXT_ERROR;
        errorObject.errorNumber = ERROR_NUMBER;
        contactObject.error = new List<CareHelper.ErrorObject>();
        contactObject.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactObject));
        AddContactForMembershipBatch cacb = new AddContactForMembershipBatch();
        Database.executeBatch(cacb, 10);
        Test.stopTest();
        Contact contUpdated = [SELECT Care_Status__c, Care_Error_Log__c FROM Contact LIMIT 1];
        System.assertEquals(contUpdated.Care_Status__c, CareHelper.FAILURE_STATUS);
        System.assert(contUpdated.Care_Error_Log__c.contains('Response:\r\n' + MESSAGE_TEXT_ERROR));
    }
}