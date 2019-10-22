@isTest
public without sharing class CareAddMembershipTest {

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
            .withBankDetailsNumber('12345')
            .withPaymentProfile(paymentProfile)
            .insertRecord(true)
            .build();
    }

    @isTest static void testAddMembershipBatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock('{"Membership": {"Status": "Success"}}'));
        CareAddMembershipBatch camb = new CareAddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        System.assertEquals([SELECT Care_Membership_Added__c FROM cpm__Installment__c LIMIT 1].Care_Membership_Added__c, true);
    }
}