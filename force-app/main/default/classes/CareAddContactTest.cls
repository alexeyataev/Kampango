@isTest
public without sharing class CareAddContactTest {

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
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock('{"Contact": {"Action":"Create","ContactKey": "3325461","AddressNumber": "26663388","ContactNumber": "3325461"}}'));
        List<Contact> testContactList = [SELECT Id FROM Contact LIMIT 1];
        List<String> contactIds = new List<String> {testContactList[0].Id};
        List<MembershipResultObject> membershipResultObjectList = CareAddContactHandler.addContact(contactIds);
        Test.stopTest();
        System.assertEquals(membershipResultObjectList[0].messageType, 'success');
        System.assertEquals(membershipResultObjectList[0].messageText, '3325461');
    }

    @isTest static void testAddContactError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock('{"Error"}'));
        List<Contact> testContactList = [SELECT Id FROM Contact LIMIT 1];
        List<String> contactIds = new List<String> {testContactList[0].Id};
        List<MembershipResultObject> membershipResultObjectList = CareAddContactHandler.addContact(contactIds);
        Test.stopTest();
        System.assertEquals(membershipResultObjectList[0].messageType, 'error');
        System.assertEquals(membershipResultObjectList[0].messageText, 'error!');
    }

    @isTest static void testAddContactBatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock('{"Contact": {"Action":"Create","ContactKey": "3325461","AddressNumber": "26663388","ContactNumber": "3325461"}}'));
        CareAddContactBatch cacb = new CareAddContactBatch();
        Database.executeBatch(cacb, 10);
        Test.stopTest();
        System.assertEquals([SELECT NCT_Number__c FROM Contact LIMIT 1].NCT_Number__c, '3325461');
    }
}