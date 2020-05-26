@isTest
public with sharing class TestPaymentProfileBuilder {

    private Id recordTypeId;
    private Contact primaryContact;
    private String sortCode;
    private String bankAccount;
    private String holderName;
    private String creditCardNumber;
    private Boolean insertRecord = false;

    public TestPaymentProfileBuilder withRecordType(string recordTypeName) {
        recordTypeId = Schema.SObjectType.cpm__Payment_Profile__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return this;
    }

    public TestPaymentProfileBuilder withContact(Contact primaryContact)
    {
        this.primaryContact = primaryContact;
        return this;
    }

    public TestPaymentProfileBuilder withCreditCardNumbert(String cardNumber)
    {
        this.creditCardNumber = cardNumber;
        return this;
    }



    public TestPaymentProfileBuilder withSortCode(String sortCode)
    {
        this.sortCode = sortCode;
        return this;
    }

    public TestPaymentProfileBuilder withBankAccount(String bankAccount)
    {
        this.bankAccount = bankAccount;
        return this;
    }

    public TestPaymentProfileBuilder withHolderName(String holderName)
    {
        this.holderName = holderName;
        return this;
    }

    public TestPaymentProfileBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public cpm__Payment_Profile__c build()
    {
        cpm__Payment_Profile__c paymentProfile = new cpm__Payment_Profile__c(
            RecordTypeId = this.recordTypeId,
            cpm__Contact__c = this.primaryContact.Id,
            cpm__Credit_Card_Number__c = this.creditCardNumber
        );

        if(insertRecord)
        {
            insert paymentProfile;
        }

        return paymentProfile;
    }
}