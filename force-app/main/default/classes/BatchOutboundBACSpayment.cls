public class BatchOutboundBACSpayment implements Database.Batchable<sObject>{
    public Id paymentRunId;
    public Database.QueryLocator start(Database.BatchableContext bc) {
         return Database.getQueryLocator(
            'SELECT ID, Name,' + ' ' +
                '(' +
                'SELECT Id, Name, Payment_Run__c, Account__c, Purchase_Invoice__c, Status__c, Unpaid_Amount__c' + ' ' +
                'FROM Payment_Run_Line_Items__r' +
                ')' + ' '+ 
            'FROM Payment_Run__c' + ' ' + 
            'WHERE Id = ' + ' ' +  '\'' + paymentRunId + '\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Payment_Run__c> records){
        for (Payment_Run__c p: records){
            OutboundBACSpaymentHelper.processPaymentRun(p);
        }
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

    public BatchOutboundBACSpayment(){
        //this.paymentRunId = paymentRunId;
    }

    public BatchOutboundBACSpayment(Id paymentRunId){
        this.paymentRunId = paymentRunId;
    }
    
    @InvocableMethod(
        label='Create Bank Supplier Payments'
        description='ZZ API is called for each Purchase Invoice Line Item'
        category='Payment_Run__c'
    )
    public static void runBatch(List<Id> paymentRunIds){
        BatchOutboundBACSpayment myBatchObject = new BatchOutboundBACSpayment(paymentRunIds[0]);
        Id batchId = Database.executeBatch(myBatchObject, 1);
    }
}