@isTest
public with sharing class TestInstallmentBuilder {

    private Id accountId;
    private Id primaryContactId;
    private Id salesInvoiceId;
    private Id recurringPaymentId;
    private String bankDetailsNumber;
    private String paymentProfileId;
    private String status = 'Collected';
    private String careStatus = 'Waiting';
    private String paymentProcessor = 'PaymentHub-WorldPay';
    private String paymentMethod = 'CreditCard';
    private Boolean insertRecord = false;
    private Decimal amount = 1;
    private Integer careAddMembershipAttempts = 0;

    public TestInstallmentBuilder withAccount(Id accountId)
    {
        this.accountId = accountId;
        return this;
    }
    
    public TestInstallmentBuilder withAmount(Decimal amount)
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

    public TestInstallmentBuilder withPaymentProfile(String paymentProfileId)
    {
        this.paymentProfileId = paymentProfileId;
        return this;
    }

    public TestInstallmentBuilder withPaymentProcessor(String paymentProcessor)
    {
        this.paymentProcessor = paymentProcessor;
        return this;
    }

    public TestInstallmentBuilder withPaymentMethod(String paymentMethod)
    {
        this.paymentMethod = paymentMethod;
        return this;
    }

    public TestInstallmentBuilder withSalesInvoice(Id salesInvoiceId)
    {
        this.salesInvoiceId = salesInvoiceId;
        return this;
    }

    public TestInstallmentBuilder withRecurringPayment(Id recurringPaymentId)
    {
        this.recurringPaymentId = recurringPaymentId;
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
            cpm__Amount__c = this.amount,
            cpm__Payment_Profile__c = this.paymentProfileId,
            cpm__Contact__c = this.primaryContactId,
            Bank_Details_Number__c = this.bankDetailsNumber,
            cpm__Status__c = this.status,
            cpm__Payment_Method__c = this.paymentMethod,
            cpm__Payment_Processor__c = this.paymentProcessor,
            Sales_Invoice__c = salesInvoiceId,
            cpm__Recurring_Payment__c = recurringPaymentId,
            Care_Add_Membership_Attempts__c = this.careAddMembershipAttempts,
            Care_Status__c = this.careStatus
        );

        if(insertRecord)
        {
            insert installment;
        }

        return installment;
    }
}