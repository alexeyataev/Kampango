@isTest
public with sharing class TestInstallmentBuilder {

    private String primaryContactId;
    private String bankDetailsNumber;
    private String paymentProfileId;
    private Boolean insertRecord = false;
    private Integer amount;

    public TestInstallmentBuilder withAmount(Integer amount)
    {
        this.amount = amount;
        return this;
    }

    public TestInstallmentBuilder withPrimaryContact(String primaryContactId)
    {
        this.primaryContactId = primaryContactId;
        return this;
    }

    public TestInstallmentBuilder withBankDetailsNumber(String bankDetailsNumber)
    {
        this.bankDetailsNumber = bankDetailsNumber;
        return this;
    }

    public TestInstallmentBuilder withPaymentProfile(String paymentProfileId)
    {
        this.paymentProfileId = paymentProfileId;
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
            cpm__Payment_Profile__c = this.paymentProfileId,
            cpm__Contact__c = this.primaryContactId,
            Bank_Details_Number__c = this.bankDetailsNumber
        );

        if(insertRecord)
        {
            insert installment;
        }

        return installment;
    }
}