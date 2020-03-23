@isTest
public with sharing class TestRecurringPaymentBuilder {

    private Id primaryContactId;
    private Id paymentProfileId;
    private Id salesInvoiceId;
    private String paymentProcessor = 'PaymentHub-WorldPay';
    private String paymentMethod = 'CreditCard';
    private String status = 'New';
    private String collectionDayofMonth = '3';
    private String frequency = 'Monthly';
    private Boolean active = true;
    private Boolean insertRecord = false;
    private Decimal amount = 1;
    private Date startDate = Date.today();
    private Date endDate = Date.today() + 90;
    private Date lastCollectionDate = Date.today() + 30;
    private Date nextCollectionDate = Date.today() + 30;

    public TestRecurringPaymentBuilder withAmount(Decimal amount)
    {
        this.amount = amount;
        return this;
    }

    public TestRecurringPaymentBuilder withNextCollectionDate(Date nextCollectionDate)
    {
        this.nextCollectionDate = nextCollectionDate;
        return this;
    }

    public TestRecurringPaymentBuilder withLastCollectionDate(Date lastCollectionDate)
    {
        this.lastCollectionDate = lastCollectionDate;
        return this;
    }

    public TestRecurringPaymentBuilder withPrimaryContact(String primaryContactId)
    {
        this.primaryContactId = primaryContactId;
        return this;
    }

    public TestRecurringPaymentBuilder withStatus(String status)
    {
        this.status = status;
        return this;
    }

    public TestRecurringPaymentBuilder withPaymentProfile(String paymentProfileId)
    {
        this.paymentProfileId = paymentProfileId;
        return this;
    }

    public TestRecurringPaymentBuilder withPaymentProcessor(String paymentProcessor)
    {
        this.paymentProcessor = paymentProcessor;
        return this;
    }

    public TestRecurringPaymentBuilder withPaymentMethod(String paymentMethod)
    {
        this.paymentMethod = paymentMethod;
        return this;
    }

    public TestRecurringPaymentBuilder withSalesInvoice(Id salesInvoiceId)
    {
        this.salesInvoiceId = salesInvoiceId;
        return this;
    }

    public TestRecurringPaymentBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public cpm__Recurring_Payment__c build()
    {
        cpm__Recurring_Payment__c recurringPayment = new cpm__Recurring_Payment__c(
            cpm__Amount__c = this.amount,
            cpm__Contact__c = this.primaryContactId,
            Sales_Invoice__c = this.salesInvoiceId,
            cpm__Status__c = this.status,
            cpm__Active__c = this.active,
            cpm__Start_Date__c = this.startDate,
            cpm__End_Date__c = this.endDate,
            cpm__Bank_Statement_Description__c = '__TO_BE_REPLACED__',
            cpm__Payment_Method__c = this.paymentMethod,
            cpm__Payment_Processor__c = this.paymentProcessor,
            cpm__Payment_Profile__c = this.paymentProfileId,
            cpm__Collection_Day_of_Month__c = this.collectionDayofMonth,
            cpm__Frequency__c = this.frequency,
            cpm__ls_coll_date__c = this.lastCollectionDate,
            cpm__Next_Collection_Date__c = this.nextCollectionDate
        );

        if(insertRecord)
        {
            insert recurringPayment;
        }

        return recurringPayment;
    }
}