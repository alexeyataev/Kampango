@isTest
public without sharing class AddMembershipTest {

    @testSetup static void createInstallment() {
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
            .insertRecord(true)
            .build();
        TestPaymentProfileBuilder paymentProfileBuilder = new TestPaymentProfileBuilder();
        cpm__Payment_Profile__c paymentProfile = paymentProfileBuilder.withContact(primaryContact)
            .withSortCode('123456')
            .withBankAccount('1234567890')
            .withHolderName('John Smith')
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c installment = installmentBuilder.withPrimaryContact(primaryContact.Id)
            .withBankDetailsNumber('331257')
            .withPaymentProfile(paymentProfile.Id)
            .insertRecord(true)
            .build();
    }

    @isTest static void testAddMembershipBatch() {
        Test.startTest();
        CareRequestBodyUtil.MembershipOjbect membershipOjbect = new CareRequestBodyUtil.MembershipOjbect();
        membershipOjbect.status = 'Success';
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock(JSON.serialize(membershipOjbect)));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c installmentUpdated = [SELECT Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c LIMIT 1];
        System.assertEquals(installmentUpdated.Care_Membership_Added__c, true);
        System.assertEquals(installmentUpdated.Care_Error_Log__c, null);
        System.assertEquals(installmentUpdated.Care_Status__c, 'Success');
    }

    @isTest static void testAddMembershipBatchError() {
        Test.startTest();
        CareRequestBodyUtil.MembershipOjbect membershipOjbect = new CareRequestBodyUtil.MembershipOjbect();
        membershipOjbect.status = 'Error';
        CareRequestBodyUtil.ErrorObject errorObject = new CareRequestBodyUtil.ErrorObject();
        errorObject.errorMessage = 'Error';
        errorObject.errorNumber = '400';
        membershipOjbect.error = new List<CareRequestBodyUtil.ErrorObject>();
        membershipOjbect.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new CareSendMembershipHttpResponseMock(JSON.serialize(membershipOjbect)));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c testInstallment = [SELECT Care_Membership_Added__c, Care_Error_Log__c FROM cpm__Installment__c LIMIT 1];
        System.assertEquals(testInstallment.Care_Membership_Added__c, false);
        System.assertEquals(testInstallment.Care_Error_Log__c, 'Error');
    }
}