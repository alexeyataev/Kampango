@isTest
public without sharing class CareAddBankDetailsTest {

    @testSetup static void createInstallment() {
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
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        TestPaymentProfileBuilder paymentProfileBuilder = new TestPaymentProfileBuilder();
        cpm__Payment_Profile__c paymentProfile = paymentProfileBuilder.withContact(primaryContact)
            .withSortCode('1111')
            .withBankAccount('2222')
            .withHolderName('test')
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c installment = installmentBuilder.withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withPaymentProfile(paymentProfile)
            .insertRecord(true)
            .build();
    }

    @isTest static void testAddBankDetails() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock('{"ContactBankAccount": {"ContactNumber": "3325461","BankDetailNumber": "331257","Information": "Added new account"}}'));
        List<cpm__Installment__c> testInstallmentList = [SELECT Id, cpm__Payment_Profile__c, NCT_Number_Parent__c, cpm__Contact__c FROM cpm__Installment__c LIMIT 1];
        List<MembershipResultObject> membershipResultObjectList = CareAddBankDetailsHandler.addBankDetails(testInstallmentList);
        Test.stopTest();
        System.assertEquals(membershipResultObjectList[0].messageType, 'success');
        System.assertEquals(membershipResultObjectList[0].messageText, '331257');
    }

    @isTest static void testAddBankDetailsError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock('{"Error"}'));
        List<cpm__Installment__c> testInstallmentList = [SELECT Id, NCT_Number_Parent__c, cpm__Contact__c FROM cpm__Installment__c LIMIT 1];
        List<MembershipResultObject> membershipResultObjectList = CareAddBankDetailsHandler.addBankDetails(testInstallmentList);
        Test.stopTest();
        System.assertEquals(membershipResultObjectList[0].messageType, 'error');
        System.assertEquals(membershipResultObjectList[0].messageText, 'error!');
    }
}