public with sharing class TestBatchReceiptReportItemBuilder {
    private Id bankReceipt;
    private Id batchReceiptReport;
    private String reference;
    private String acquirerAccount = 'Acquirer Account';
    private Decimal amount = 100.00;
    private Date capturedOn = Date.today();
    private String currencyCode = 'GBP';
    private String orderCode = 'X333X';
    private String paymentId = '123456';
    private String paymentMethod = 'Card';
    private Boolean insertRecord = false;

    public TestBatchReceiptReportItemBuilder withBankReceipt(Id bankReceipt) {
        this.bankReceipt = bankReceipt;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withBatchReceiptReport(Id batchReceiptReport) {
        this.batchReceiptReport = batchReceiptReport;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withReference(String reference) {
        this.reference = reference;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withAcquirerAccount(String acquirerAccount) {
        this.acquirerAccount = acquirerAccount;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withAmount(Decimal amount) {
        this.amount = amount;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withCapturedOn(Date capturedOn) {
        this.capturedOn = capturedOn;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withCurrencyCode(String currencyCode) {
        this.currencyCode = currencyCode;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withOrderCode(String orderCode) {
        this.orderCode = orderCode;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withPaymentId(String paymentId) {
        this.paymentId = paymentId;
        return this;
    }

    public TestBatchReceiptReportItemBuilder withPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
        return this;
    }

    public TestBatchReceiptReportItemBuilder insertRecord(Boolean insertRecord) {
        this.insertRecord = insertRecord;
        return this;
    }

    public Batch_Receipt_Report_Item__c build() {
        Batch_Receipt_Report_Item__c batchReceiptReportItem = new Batch_Receipt_Report_Item__c(
            Acquirer_Account__c = this.acquirerAccount,
            Amount__c = this.amount,
            Batch_Receipt_Report__c = this.batchReceiptReport,
            Captured_On__c = this.capturedOn,
            Currency_Code__c = this.currencyCode,
            Bank_Receipt__c = bankReceipt,
            Order_Code__c = this.orderCode,
            Payment_Id__c = this.paymentId,
            Payment_Method__c = this.paymentMethod,
            Reference__c = this.reference
        );

        if (insertRecord) {
            insert batchReceiptReportItem;
        }
        return batchReceiptReportItem;
    }
}
