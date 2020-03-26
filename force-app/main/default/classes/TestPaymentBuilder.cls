@isTest
public with sharing class TestPaymentBuilder {

    private Id accountId;
    private Id primaryContactId;
    private Id paymentProfileId;
    private Id installmentId;
    private String paymentProcessor = 'PaymentHub-WorldPay';
    private String paymentMethod = 'CreditCard';
    private Boolean insertRecord = false;
    private Decimal amount = 1;
    private Date collectionDate = Date.today();

    public TestPaymentBuilder withAccount(Id accountId)
    {
        this.accountId = accountId;
        return this;
    }

    public TestPaymentBuilder withAmount(Decimal amount)
    {
        this.amount = amount;
        return this;
    }

    public TestPaymentBuilder withCollectionDate(Date collectionDate)
    {
        this.collectionDate = collectionDate;
        return this;
    }

    public TestPaymentBuilder withPrimaryContact(String primaryContactId)
    {
        this.primaryContactId = primaryContactId;
        return this;
    }

    public TestPaymentBuilder withPaymentProfile(String paymentProfileId)
    {
        this.paymentProfileId = paymentProfileId;
        return this;
    }

    public TestPaymentBuilder withPaymentProcessor(String paymentProcessor)
    {
        this.paymentProcessor = paymentProcessor;
        return this;
    }

    public TestPaymentBuilder withPaymentMethod(String paymentMethod)
    {
        this.paymentMethod = paymentMethod;
        return this;
    }

    public TestPaymentBuilder withInstallment(Id installmentId)
    {
        this.installmentId = installmentId;
        return this;
    }

    public TestPaymentBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public cpm__Payment__c build()
    {
        cpm__Payment__c payment = new cpm__Payment__c(
            cpm__Account__c = this.accountId,
            cpm__Amount__c = this.amount,
            cpm__Collection_Date__c = this.collectionDate,
            cpm__Contact__c = this.primaryContactId,
            cpm__Installment__c = this.installmentId,
            cpm__Payment_Method__c = this.paymentMethod,
            cpm__Payment_Processor__c = this.paymentProcessor,
            cpm__Payment_Profile__c = this.paymentProfileId          
        );

        if(insertRecord)
        {
            insert payment;
        }

        return payment;
    }
}