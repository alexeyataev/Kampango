@isTest
public with sharing class TestInstallmentBuilder {
    private Integer amount;
    private String bankDetailsNumber;
    private Integer careAddMembershipAttempts = 0;
    private String careStatus = 'Waiting';
    private Boolean insertRecord = false;
    private String paymentProcessor;
    private String primaryContactId;
    private String status;

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
    
    public TestInstallmentBuilder withPaymentProcessor(String paymentProcessor)
    {
        this.paymentProcessor = paymentProcessor;
        return this;
    }

    public TestInstallmentBuilder withStatus(String status)
    {
        this.status = status;
        return this;
    }

    public TestInstallmentBuilder withCareStatus(String careStatus)
    {
        this.careStatus = careStatus;
        return this;
    }

    public TestInstallmentBuilder withBankDetailsNumber(String bankDetailsNumber)
    {
        this.bankDetailsNumber = bankDetailsNumber;
        return this;
    }

    public TestInstallmentBuilder withCareAddMembershipAttempts(Integer careAddMembershipAttempts) {
        this.careAddMembershipAttempts = careAddMembershipAttempts;
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
            Bank_Details_Number__c = this.bankDetailsNumber,
            Care_Add_Membership_Attempts__c = this.careAddMembershipAttempts,
            Care_Status__c = this.careStatus,
            cpm__Amount__c = this.amount,
            cpm__Contact__c = this.primaryContactId,
            cpm__Payment_Processor__c = this.paymentProcessor,
            cpm__Status__c = this.status
        );

        if(insertRecord)
        {
            insert installment;
        }

        return installment;
    }
}