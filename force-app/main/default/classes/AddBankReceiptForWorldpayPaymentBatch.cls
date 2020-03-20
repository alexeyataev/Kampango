//@SuppressWarnings('PMD.EmptyStatementBlock')
//Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO
public class AddBankReceiptForWorldpayPaymentBatch implements Database.Batchable<sObject> {
    private static final String INSTALLMENT_STATUS = 'Collected';
    private static final String PAYMENT_PROCESSOR = 'PaymentHub-WorldPay';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, cpm__Amount__c, cpm__Installment__r.Sales_Invoice__c, cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c FROM cpm__Payment__c WHERE cpm__Installment__r.cpm__Status__c =\'' +  INSTALLMENT_STATUS + '\' AND cpm__Installment__r.cpm__Payment_Processor__c =\'' + PAYMENT_PROCESSOR + '\' AND Id NOT IN (SELECT Payment__c FROM Zumzum__Bank_Receipt__c)');
    }

    public void execute(Database.BatchableContext bc, List<cpm__Payment__c> scope){
        AddBankReceiptForPaymentHandler.addBankReceipts(scope);
    }

    public void finish(Database.BatchableContext bc){
    
    }
}