@isTest
public without sharing class AddContactForMembershipTest {

    @testSetup static void createPrimaryContact() {
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account account =  accountBuilder
            .withRecordType('Household Account')
            .insertRecord(true)
            .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
    }

    @isTest static void testAddContact() {
        Test.startTest();
        CareRequestBodyUtil.ContactOjbect contactOjbect = new CareRequestBodyUtil.ContactOjbect();
        CareRequestBodyUtil.ContactDetails contactDetails = new CareRequestBodyUtil.ContactDetails();
        contactDetails.contactNumber = '3325461';
        contactOjbect.contact = contactDetails;
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock(JSON.serialize(contactOjbect)));
        List<Contact> testContactList = [SELECT Id FROM Contact LIMIT 1];
        List<String> contactIds = new List<String> {testContactList[0].Id};
        List<AddContactResult> resultList = AddContactForMembershipHandler.addContact(contactIds);
        Test.stopTest();
        System.assertEquals(resultList[0].nctNumber, '3325461');
    }

    @isTest static void testAddContactError() {
        Test.startTest();
        CareRequestBodyUtil.ContactOjbect contactOjbect = new CareRequestBodyUtil.ContactOjbect();
        CareRequestBodyUtil.ErrorObject errorObject = new CareRequestBodyUtil.ErrorObject();
        errorObject.errorMessage = 'Error';
        errorObject.errorNumber = '400';
        contactOjbect.error = new List<CareRequestBodyUtil.ErrorObject>();
        contactOjbect.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock(JSON.serialize(contactOjbect)));
        List<Contact> testContactList = [SELECT Id FROM Contact LIMIT 1];
        List<String> contactIds = new List<String> {testContactList[0].Id};
        List<AddContactResult> resultList = AddContactForMembershipHandler.addContact(contactIds);
        Test.stopTest();
        //System.assertEquals(resultList[0].error, CareRequestBodyUtil.MESSAGE_TEXT_ERROR);
    }

    @isTest static void testAddContactBatch() {
        Test.startTest();
        CareRequestBodyUtil.ContactOjbect contactOjbect = new CareRequestBodyUtil.ContactOjbect();
        CareRequestBodyUtil.ContactDetails contactDetails = new CareRequestBodyUtil.ContactDetails();
        contactDetails.contactNumber = '3325461';
        contactOjbect.contact = contactDetails;
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock(JSON.serialize(contactOjbect)));
        AddContactForMembershipBatch cacb = new AddContactForMembershipBatch();
        Database.executeBatch(cacb, 10);
        Test.stopTest();
        System.assertEquals([SELECT NCT_Number__c FROM Contact LIMIT 1].NCT_Number__c, '3325461');
    }
}