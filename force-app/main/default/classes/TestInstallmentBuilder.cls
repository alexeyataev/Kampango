@isTest
public with sharing class TestInstallmentBuilder {

    private Contact primaryContact;
    private String bankDetailsNumber;
    private cpm__Payment_Profile__c paymentProfile;
    private Boolean insertRecord = false;
    private Integer amount;

    public TestInstallmentBuilder withAmount(Integer amount)
    {
        this.amount = amount;
        return this;
    }

    public TestInstallmentBuilder withPrimaryContact(Contact primaryContact)
    {
        this.primaryContact = primaryContact;
        return this;
    }

    public TestInstallmentBuilder withBankDetailsNumber(String bankDetailsNumber)
    {
        this.bankDetailsNumber = bankDetailsNumber;
        return this;
    }

    public TestInstallmentBuilder withPaymentProfile(cpm__Payment_Profile__c paymentProfile)
    {
        this.paymentProfile = paymentProfile;
        return this;
    }

    public TestInstallmentBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public cpm__Installment__c build()
    {
        cpm__Installment__c installment = new cpm__Installment__c(
            cpm__Amount__c = this.amount,
            cpm__Payment_Profile__c = this.paymentProfile.Id,
            cpm__Contact__c = this.primaryContact.Id,
            Bank_Details_Number__c = this.bankDetailsNumber
        );

        if(insertRecord)
        {
            insert installment;
        }

        return installment;
    }
}