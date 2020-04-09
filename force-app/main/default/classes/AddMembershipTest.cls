@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public without sharing class AddMembershipTest {
    private static final String CARE_WAITING_STATUS = 'Waiting';
    private static final String MESSAGE_TEXT_ERROR = 'Error Test Reason Message';
    private static final String SUCCESS_STATUS = 'Success';
    private static final String FAILURE_STATUS = 'Failure';
    private static final String ERROR_NUMBER = '400';
    private static final String PAYMENT_PROCESSOR = 'PaymentHub-WorldPay';
    private static final String PAYMENT_STATUS = 'Collected';
    private static final String MEMBERSHIP_TYPE_A = 'A';
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
            .withMembershipType(MEMBERSHIP_TYPE_A)
            .insertRecord(false)
            .build(),
            installmentBuilder.withPrimaryContact(primaryContact.Id)
            .withBankDetailsNumber('331258')
            .withPaymentProcessor(PAYMENT_PROCESSOR)
            .withStatus(PAYMENT_STATUS)
            .withCareStatus(FAILURE_STATUS)
            .withCareAddMembershipAttempts(1)
            .withMembershipType(MEMBERSHIP_TYPE_A)
            .insertRecord(false)
            .build(),
            installmentBuilder.withPrimaryContact(primaryContact.Id)
            .withBankDetailsNumber('331259')
            .withPaymentProcessor(PAYMENT_PROCESSOR)
            .withStatus(PAYMENT_STATUS)
            .withCareStatus(FAILURE_STATUS)
            .withCareAddMembershipAttempts(1)
            .withMembershipType(MEMBERSHIP_TYPE_A)
            .insertRecord(false)
            .build()
        };
        insert installments;
    }

    @isTest static void AddMembershipBatch_MembershipAdded_StatusSuccess() {
        Test.startTest();
        updateInstallmentCareWaiting('331258');
        CareHelper.MembershipObject membershipObject = new CareHelper.MembershipObject();
        membershipObject.status = SUCCESS_STATUS;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(membershipObject));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c installmentNotAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331257'];
        cpm__Installment__c installmentAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331258'];
        cpm__Installment__c installmentAttemptedBeforeWaiting = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331259'];
        System.assertEquals(installmentNotAttemptedBefore.Care_Add_Membership_Attempts__c, 1);
        System.assertEquals(installmentNotAttemptedBefore.Care_Status__c, SUCCESS_STATUS);
        System.assertEquals(installmentNotAttemptedBefore.Care_Error_Log__c, null);
        System.assertEquals(installmentNotAttemptedBefore.Care_Membership_Added__c, true);
        System.assertEquals(installmentAttemptedBefore.Care_Add_Membership_Attempts__c, 2);
        System.assertEquals(installmentAttemptedBefore.Care_Status__c, SUCCESS_STATUS);
        System.assertEquals(installmentAttemptedBefore.Care_Error_Log__c, null);
        System.assertEquals(installmentAttemptedBefore.Care_Membership_Added__c, true);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Add_Membership_Attempts__c, 1);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Status__c, FAILURE_STATUS);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Error_Log__c, null);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Membership_Added__c, false);
    }

    @isTest static void AddMembershipBatchError_MembershipNotAdded_StatusError() {
        Test.startTest();
        updateInstallmentCareWaiting('331258');
        CareHelper.MembershipObject membershipObject = new CareHelper.MembershipObject();
        membershipObject.status = FAILURE_STATUS;
        CareHelper.ErrorObject errorObject = new CareHelper.ErrorObject();
        errorObject.errorMessage = MESSAGE_TEXT_ERROR;
        errorObject.errorNumber = ERROR_NUMBER;
        membershipObject.error = new List<CareHelper.ErrorObject>();
        membershipObject.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(membershipObject));
        AddMembershipBatch camb = new AddMembershipBatch();
        Database.executeBatch(camb, 10);
        Test.stopTest();
        cpm__Installment__c installmentNotAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331257'];
        cpm__Installment__c installmentAttemptedBefore = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331258'];
        cpm__Installment__c installmentAttemptedBeforeWaiting = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c = '331259'];
        System.assertEquals(installmentNotAttemptedBefore.Care_Add_Membership_Attempts__c, 1);
        System.assertEquals(installmentNotAttemptedBefore.Care_Status__c, FAILURE_STATUS);
        System.assertEquals(installmentNotAttemptedBefore.Care_Error_Log__c, MESSAGE_TEXT_ERROR);
        System.assertEquals(installmentNotAttemptedBefore.Care_Membership_Added__c, false);
        System.assertEquals(installmentAttemptedBefore.Care_Add_Membership_Attempts__c, 2);
        System.assertEquals(installmentAttemptedBefore.Care_Status__c, FAILURE_STATUS);
        System.assertEquals(installmentAttemptedBefore.Care_Error_Log__c, MESSAGE_TEXT_ERROR);
        System.assertEquals(installmentAttemptedBefore.Care_Membership_Added__c, false);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Add_Membership_Attempts__c, 1);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Status__c, FAILURE_STATUS);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Error_Log__c, null);
        System.assertEquals(installmentAttemptedBeforeWaiting.Care_Membership_Added__c, false);
    }

    private static void updateInstallmentCareWaiting(String bankDetailsNumber) {
        cpm__Installment__c installment = [SELECT Care_Add_Membership_Attempts__c, Care_Membership_Added__c, Care_Error_Log__c, Care_Status__c FROM cpm__Installment__c WHERE Bank_Details_Number__c =: bankDetailsNumber];
        installment.Care_Status__c = CARE_WAITING_STATUS;
        update installment;
    }
}