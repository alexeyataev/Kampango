@isTest
public class TestBatchReceiptReportBuilder {
    private Id bankReconcile;
    private String batchId;
    private Date fromDate = Date.today() - 30;
    private Date toDate = Date.today();
    private String provider = 'WorldPay';
    private String status = 'Not Created';
    private Boolean insertRecord = false;

    public TestBatchReceiptReportBuilder withBankReconcile(Id bankReconcile) {
        this.bankReconcile = bankReconcile;
        return this;
    }

    public TestBatchReceiptReportBuilder withBatchId(String batchId) {
        this.batchId = batchId;
        return this;
    }

    public TestBatchReceiptReportBuilder withFromDate(Date fromDate) {
        this.fromDate = fromDate;
        return this;
    }

    public TestBatchReceiptReportBuilder withToDate(Date toDate) {
        this.toDate = toDate;
        return this;
    }

    public TestBatchReceiptReportBuilder withProvider(String provider) {
        this.provider = provider;
        return this;
    }

    public TestBatchReceiptReportBuilder withStatus(String status) {
        this.status = status;
        return this;
    }
    
    public TestBatchReceiptReportBuilder insertRecord(Boolean insertRecord) {
        this.insertRecord = insertRecord;
        return this;
    }

    public Batch_Receipt_Report__c build() {
        Batch_Receipt_Report__c batchReceiptReport = new Batch_Receipt_Report__c(
            BankReconcile__c = this.bankReconcile,
            Batch_Id__c = this.batchId,
            From_Date__c = this.fromDate,
            To_Date__c = this.toDate,
            Provider__c = this.provider,
            Status__c = this.status
        );
        
        if (insertRecord) {
            insert batchReceiptReport;
        }
        
        return batchReceiptReport;
    }

}
