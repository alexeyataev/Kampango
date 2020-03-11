@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public without sharing class AddMembershipTest {
    private static final String MESSAGE_TEXT_ERROR = 'Error';
    private static final String MESSAGE_TEXT_SUCCESS = 'Success';
    private static final String ERROR_NUMBER = '400';
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
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c installment = installmentBuilder.withPrimaryContact(primaryContact.Id)
            .withBankDetailsNumber('331257')
            .withPaymentProcessor('PaymentHub-WorldPay')
            .withStatus('Collected')
            .insertRecord(true)
            .build();
    }

    @isTest static void AddMembershipBatch_MembershipAdded_StatusSuccess() {
        Test.startTest();
        CareRequestBodyUtil.MembershipOjbect membershipOjbect = new CareRequestBodyUtil.MembershipOjbect();
        membershipOjbect.status = MESSAGE_TEXT_SUCCESS;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(membershipOjbect));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c installmentUpdated = [SELECT Care_Add_Membership_Attepmts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c LIMIT 1];
        System.assertEquals(installmentUpdated.Care_Add_Membership_Attepmts__c, 1);
        System.assertEquals(installmentUpdated.Care_Membership_Added__c, true);
        System.assertEquals(installmentUpdated.Care_Error_Log__c, null);
        System.assertEquals(installmentUpdated.Care_Status__c, MESSAGE_TEXT_SUCCESS);
    }

    @isTest static void AddMembershipBatchError_MembershipNotAdded_StatusError() {
        Test.startTest();
        CareRequestBodyUtil.MembershipOjbect membershipOjbect = new CareRequestBodyUtil.MembershipOjbect();
        membershipOjbect.status = MESSAGE_TEXT_ERROR;
        CareRequestBodyUtil.ErrorObject errorObject = new CareRequestBodyUtil.ErrorObject();
        errorObject.errorMessage = MESSAGE_TEXT_ERROR;
        errorObject.errorNumber = ERROR_NUMBER;
        membershipOjbect.error = new List<CareRequestBodyUtil.ErrorObject>();
        membershipOjbect.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(membershipOjbect));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c installmentUpdated = [SELECT Care_Add_Membership_Attepmts__c, Care_Membership_Added__c, Care_Error_Log__c FROM cpm__Installment__c LIMIT 1];
        System.assertEquals(installmentUpdated.Care_Add_Membership_Attepmts__c, 1);
        System.assertEquals(installmentUpdated.Care_Membership_Added__c, false);
        System.assertEquals(installmentUpdated.Care_Error_Log__c, MESSAGE_TEXT_ERROR);
    }
}