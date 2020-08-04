@SuppressWarnings('PMD.EmptyStatementBlock')
//Incident #63 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class BatchOutboundBACSpayment implements Database.Batchable<sObject>{
    public Id paymentRunId;

    private static final String PAYMENT_RUN_RESULT_STATUS_ERROR = 'Error';
    private static final String PAYMENT_RUN_STATUS_READY = 'Ready';
    private static final String PAYMENT_RUN_STATUS_FAILED = 'Failed To Create Transactions';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Payment_Run__c, Payment_Run__r.Name, Account__c, Purchase_Invoice__c, Status__c, Unpaid_Amount__c ' + 
            'FROM Payment_Run_Line_Item__c ' + 
            'WHERE Payment_Run__c = \'' + paymentRunId + '\' AND Payment_Run__r.Status__c = \'Processing\' AND Purchase_Invoice__r.Zumzum__Paid__c <> \'Y\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Payment_Run_Line_Item__c> paymentRunLineItems) {
        OutboundBACSpaymentHelper.processPaymentRunLineItems(paymentRunLineItems);
    }

    public void finish(Database.BatchableContext bc) {
        Payment_Run__c paymentRun = [SELECT Id FROM Payment_Run__c WHERE Id = :paymentRunId];
        AsyncApexJob batchOutboundBACSPaymentJob = [SELECT Id, Status, NumberOfErrors
                                                    FROM AsyncApexJob WHERE Id =
                                                    :BC.getJobId()];
        
        if(batchOutboundBACSPaymentJob.NumberOfErrors > 0){
            paymentRun.Status__c = PAYMENT_RUN_STATUS_FAILED;
        }else{
            paymentRun.Status__c = PAYMENT_RUN_STATUS_READY;
        }

        update paymentRun;
    }

    public BatchOutboundBACSpayment(Id paymentRunId) {
        this.paymentRunId = paymentRunId;
    }

    @InvocableMethod(
        label='Create Bank Supplier Payments'
        description='ZZ API is called for each Purchase Invoice Line Item'
        category='Payment_Run__c'
    )
    public static void runBatch(List<Id> paymentRunIds) {
        Integer batchSize = Financial_Settings__c.getInstance().Payment_Run_Line_Item_Batch_Size__c == null ? 10 : Integer.valueOf(Financial_Settings__c.getInstance().Payment_Run_Line_Item_Batch_Size__c);
        BatchOutboundBACSpayment myBatchObject = new BatchOutboundBACSpayment(paymentRunIds[0]);
        Id batchId = Database.executeBatch(myBatchObject, batchSize);
    }
}