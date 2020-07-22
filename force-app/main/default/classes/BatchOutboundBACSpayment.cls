@SuppressWarnings('PMD.EmptyStatementBlock')
//Incident #63 - https://confluence.nct.org.uk:8443/x/EoSO
public class BatchOutboundBACSpayment implements Database.Batchable<sObject>{
    public Id paymentRunId;

    private static final String PAYMENT_RUN_RESULT_STATUS_ERROR = 'Error';
    private static final String PAYMENT_RUN_STATUS_READY = 'Ready';
    private static final String PAYMENT_RUN_STATUS_FAILED = 'Failed To Create Transactions';

    public Database.QueryLocator start(Database.BatchableContext bc) {
         return Database.getQueryLocator(
            'SELECT ID, Name,' + ' ' +
                '(' +
                'SELECT Id, Name, Payment_Run__c, Account__c, Purchase_Invoice__c, Status__c, Unpaid_Amount__c' + ' ' +
                'FROM Payment_Run_Line_Items__r' +
                ')' + ' '+ 
            'FROM Payment_Run__c' + ' ' + 
            'WHERE Id = ' + ' ' +  '\'' + paymentRunId + '\'' + ' ' +
                'AND Status__c = \'Processing\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Payment_Run__c> paymentRuns) {
        for (Payment_Run__c paymentRun : paymentRuns) {
            String runPaymentResponseResult = OutboundBACSpaymentHelper.processPaymentRun(paymentRun);
            if (runPaymentResponseResult == PAYMENT_RUN_RESULT_STATUS_ERROR) {
                paymentRun.Status__c = PAYMENT_RUN_STATUS_FAILED;
                paymentRun.Bank_Supplier_Payment_Error_Log__c = runPaymentResponseResult;
            } else {
                paymentRun.Status__c = PAYMENT_RUN_STATUS_READY;
                paymentRun.Bank_Supplier_Payment_Error_Log__c = '';
            }
        }
        update paymentRuns;
    }

    public void finish(Database.BatchableContext bc) {}

    public BatchOutboundBACSpayment(Id paymentRunId) {
        this.paymentRunId = paymentRunId;
    }

    @InvocableMethod(
        label='Create Bank Supplier Payments'
        description='ZZ API is called for each Purchase Invoice Line Item'
        category='Payment_Run__c'
    )
    public static void runBatch(List<Id> paymentRunIds) {
        BatchOutboundBACSpayment myBatchObject = new BatchOutboundBACSpayment(paymentRunIds[0]);
        Id batchId = Database.executeBatch(myBatchObject, 1);
    }
}