@isTest
public with sharing class TestPaymentProfileBuilder {

    private Contact primaryContact;
    private String sortCode;
    private String bankAccount;
    private String holderName;
    private Boolean insertRecord = false;

    public TestPaymentProfileBuilder withContact(Contact primaryContact)
    {
        this.primaryContact = primaryContact;
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
            cpm__Contact__c = this.primaryContact.Id,
            paybacs__Sort_Code__c = this.sortCode,
            cpm__Bank_Account__c = this.bankAccount,
            cpm__Holder_Name__c = this.holderName
        );

        if(insertRecord)
        {
            insert paymentProfile;
        }

        return paymentProfile;
    }
}