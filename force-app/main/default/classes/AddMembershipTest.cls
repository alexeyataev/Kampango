@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public without sharing class AddMembershipTest {
    private static final String MESSAGE_TEXT_ERROR = 'Error Test Reason Message';
    private static final String SUCCESS_STATUS = 'Success';
    private static final String FAILURE_STATUS = 'Failure';
    private static final String ERROR_NUMBER = '400';
    private static final String PAYMENT_PROCESSOR = 'PaymentHub-WorldPay';
    private static final String PAYMENT_STATUS = 'Collected';
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
        TestPaymentProfileBuilder paymentProfileBuilder = new TestPaymentProfileBuilder();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        List<cpm__Installment__c> installments = new List<cpm__Installment__c> {
            installmentBuilder.withPrimaryContact(primaryContact.Id)
            .withBankDetailsNumber('331257')
            .withPaymentProcessor(PAYMENT_PROCESSOR)
            .withStatus(PAYMENT_STATUS)
            .insertRecord(false)
            .build(),
            installmentBuilder.withPrimaryContact(primaryContact.Id)
            .withBankDetailsNumber('331258')
            .withPaymentProcessor(PAYMENT_PROCESSOR)
            .withStatus(PAYMENT_STATUS)
            .withCareAddMembershipAttempts(1)
            .insertRecord(false)
            .build()
        };
        insert installments;
    }

    @isTest static void AddMembershipBatch_MembershipAdded_StatusSuccess() {
        Test.startTest();
        CareRequestBodyUtil.MembershipOjbect membershipOjbect = new CareRequestBodyUtil.MembershipOjbect();
        membershipOjbect.status = SUCCESS_STATUS;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(membershipOjbect));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c installmentUpdatedNotAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331257'];
        cpm__Installment__c installmentUpdatedAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331258'];
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Add_Membership_Attempts__c, 1);
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Status__c, SUCCESS_STATUS);
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Error_Log__c, null);
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Membership_Added__c, true);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Add_Membership_Attempts__c, 2);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Status__c, SUCCESS_STATUS);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Error_Log__c, null);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Membership_Added__c, true);
    }

    @isTest static void AddMembershipBatchError_MembershipNotAdded_StatusError() {
        Test.startTest();
        CareRequestBodyUtil.MembershipOjbect membershipOjbect = new CareRequestBodyUtil.MembershipOjbect();
        membershipOjbect.status = FAILURE_STATUS;
        CareRequestBodyUtil.ErrorObject errorObject = new CareRequestBodyUtil.ErrorObject();
        errorObject.errorMessage = MESSAGE_TEXT_ERROR;
        errorObject.errorNumber = ERROR_NUMBER;
        membershipOjbect.error = new List<CareRequestBodyUtil.ErrorObject>();
        membershipOjbect.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(membershipOjbect));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c installmentUpdatedNotAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331257'];
        cpm__Installment__c installmentUpdatedAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331258'];
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Add_Membership_Attempts__c, 1);
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Status__c, FAILURE_STATUS);
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Error_Log__c, MESSAGE_TEXT_ERROR);
        System.assertEquals(installmentUpdatedNotAttemptedBefore.Care_Membership_Added__c, false);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Add_Membership_Attempts__c, 2);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Status__c, FAILURE_STATUS);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Error_Log__c, MESSAGE_TEXT_ERROR);
        System.assertEquals(installmentUpdatedAttemptedBefore.Care_Membership_Added__c, false);
    }
}