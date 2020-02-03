@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public without sharing class AddBankDetailsForMembershipTest {

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
        cpm__Payment_Profile__c paymentProfile = paymentProfileBuilder.withContact(primaryContact)
            .withSortCode('123456')
            .withBankAccount('1234567890')
            .withHolderName('John Smith')
            .insertRecord(true)
            .build();
        TestInstallmentBuilder installmentBuilder = new TestInstallmentBuilder();
        cpm__Installment__c installment = installmentBuilder.withPrimaryContact(primaryContact.Id)
            .withPaymentProfile(paymentProfile.Id)
            .insertRecord(true)
            .build();
    }

    @isTest static void AddBankDetails_BankDetailsAdded_BankDetailNumberReturned() {
        Test.startTest();
        CareRequestBodyUtil.ContactBankAccountObject contactBankAccountObject = new CareRequestBodyUtil.ContactBankAccountObject();
        CareRequestBodyUtil.ContactBankAccountDetails contactBankAccountDetails = new CareRequestBodyUtil.ContactBankAccountDetails();
        contactBankAccountDetails.contactNumber = '3325461';
        contactBankAccountDetails.bankDetailNumber = '331257';
        contactBankAccountDetails.information = 'Added new account';
        contactBankAccountObject.contactBankAccount = contactBankAccountDetails;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactBankAccountObject));
        List<cpm__Installment__c> testInstallmentList = [SELECT Id, cpm__Payment_Profile__c, cpm__Contact__c FROM cpm__Installment__c LIMIT 1];
        List<AddBankDetailsResult> resultList = AddBankDetailsForMembershipHandler.addBankDetails(testInstallmentList);
        Test.stopTest();
        System.assertEquals(resultList[0].bankDetailsNumber, '331257');
    }

    @isTest static void AddBankDetailsError_BankDetailsNotAdded_ErrorReturned() {
        String errorMessage = 'Error';
        Test.startTest();
        CareRequestBodyUtil.ContactBankAccountObject contactBankAccountObject = new CareRequestBodyUtil.ContactBankAccountObject();
        CareRequestBodyUtil.ErrorObject errorObject = new CareRequestBodyUtil.ErrorObject();
        errorObject.errorMessage = errorMessage;
        errorObject.errorNumber = '400';
        contactBankAccountObject.error = new List<CareRequestBodyUtil.ErrorObject>();
        contactBankAccountObject.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactBankAccountObject));
        List<cpm__Installment__c> testInstallmentList = [SELECT Id, cpm__Contact__c, cpm__Payment_Profile__c FROM cpm__Installment__c LIMIT 1];
        List<AddBankDetailsResult> resultList = AddBankDetailsForMembershipHandler.addBankDetails(testInstallmentList);
        Test.stopTest();
        System.assertEquals(resultList[0].error, errorMessage);
    }
}