@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public without sharing class AddBankDetailsForMembershipTest {

    private static final String MESSAGE_TEXT_ERROR = 'Error';
    private static final String ERROR_NUMBER = '400';
    private static final String BANK_DETAILS_NUMBER = '331257';

    @testSetup static void createTestData() {

        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account account =  accountBuilder
            .withRecordType('Household Account')
            .withBranchNumber('777')
            .insertRecord(true)
            .build();

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder
            .withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Smith')
            .withNctNumber('123123')
            .insertRecord(true)
            .build();
    }

    @isTest static void AddBankDetails_BankDetailsAdded_BankDetailNumberReturned() {
        Test.startTest();
        CareRequestBodyUtil.ContactBankAccountObject contactBankAccountObject = new CareRequestBodyUtil.ContactBankAccountObject();
        CareRequestBodyUtil.ContactBankAccountDetails contactBankAccountDetails = new CareRequestBodyUtil.ContactBankAccountDetails();
        contactBankAccountDetails.contactNumber = '3325461';
        contactBankAccountDetails.bankDetailNumber = BANK_DETAILS_NUMBER;
        contactBankAccountDetails.information = 'Added new account';
        contactBankAccountObject.contactBankAccount = contactBankAccountDetails;
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactBankAccountObject));
        List<AddBankDetailsResult> resultList = AddBankDetailsForMembershipHandler.addBankDetails( getInstallmentList() );
        Test.stopTest();

        System.assertEquals(resultList[0].bankDetailsNumber, BANK_DETAILS_NUMBER, 'Will return Bank Detail Number');
    }

    @isTest static void AddBankDetailsNull_NotNctNumber_NullReturned() {
        Test.startTest();
        CareRequestBodyUtil.ContactBankAccountObject contactBankAccountObject = new CareRequestBodyUtil.ContactBankAccountObject();
        CareRequestBodyUtil.ErrorObject errorObject = new CareRequestBodyUtil.ErrorObject();
        errorObject.errorMessage = MESSAGE_TEXT_ERROR;
        errorObject.errorNumber = ERROR_NUMBER;
        contactBankAccountObject.error = new List<CareRequestBodyUtil.ErrorObject>();
        contactBankAccountObject.error.add(errorObject);
        Test.setMock(HttpCalloutMock.class, new SendMembershipHttpResponseMock(contactBankAccountObject));
        List<AddBankDetailsResult> resultList = AddBankDetailsForMembershipHandler.addBankDetails( getInstallmentList() );
        Test.stopTest();
        System.assertEquals(resultList[0].error, MESSAGE_TEXT_ERROR, 'Will return message error');
    }

    @isTest static void AddBankDetailsExeption_NctNumberIsNotAdded_ExeptionReturned() {
        Test.startTest();
        cpm__Installment__c isntallmentInstance = new cpm__Installment__c();

        Contact cnt = [SELECT Id, NCT_Number__c FROM Contact LIMIT 1];
        cnt.NCT_Number__c = null;
        update cnt;

        isntallmentInstance.cpm__Contact__c = cnt.Id;
        List<AddBankDetailsResult> resultList = AddBankDetailsForMembershipHandler.addBankDetails( new List<cpm__Installment__c> {isntallmentInstance} );
        Test.stopTest();
    }

    private static List<cpm__Installment__c> getInstallmentList() {
        cpm__Installment__c isntallmentInstance = new cpm__Installment__c();
        isntallmentInstance.cpm__Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        isntallmentInstance.Account_Name__c = 'Account_1';
        isntallmentInstance.Sort_Code__c = '2400000';

        return new List<cpm__Installment__c> {isntallmentInstance};
    }
}