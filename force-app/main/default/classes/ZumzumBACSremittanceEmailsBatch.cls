public class ZumzumBACSremittanceEmailsBatch implements Database.Batchable<Payment_Run_Line_Item__c> {
    
    private Id paymentRunId;
    private Id orgWideAddressId;
    private Id templateId;
    private String templateBody;
    
    public ZumzumBACSremittanceEmailsBatch(Id paymentRunId, Id templateId, Id orgWideAddressId) {
        this.paymentRunId = paymentRunId;
        this.templateId = templateId;
        this.orgWideAddressId = orgWideAddressId;
        this.templateBody = [SELECT Id, HtmlValue FROM EmailTemplate WHERE Id =: templateId].HtmlValue;
    }
    
    public List<Payment_Run_Line_Item__c> start(Database.BatchableContext context) {
        return [
            SELECT Id, Name, Paid_Amount__c, Unpaid_Amount__c, Reference_Info__c,
                Purchase_Invoice__r.Zumzum__Contact__c, 
                Purchase_Invoice__r.Zumzum__Contact__r.Email, 
                Purchase_Invoice__r.Zumzum__Contact__r.FirstName,
                Purchase_Invoice__r.Zumzum__Account__r.Billing_Email__c
            FROM Payment_Run_Line_Item__c
            WHERE Payment_Run__c = :paymentRunId
            AND Is_Email_Sent__c = false
            AND (Purchase_Invoice__r.Zumzum__Contact__c != null OR Purchase_Invoice__r.Zumzum__Account__c != null)
        ];
    }
    
    public void execute(Database.BatchableContext context, List<Payment_Run_Line_Item__c> items) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        List<Payment_Run_Line_Item__c> itemsToUpdate = new List<Payment_Run_Line_Item__c>();
        for (Payment_Run_Line_Item__c prli : items) {
            if(prli.Purchase_Invoice__r.Zumzum__Contact__c != null) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if(prli.Purchase_Invoice__r.Zumzum__Contact__r.Email != null) {
                    message.setTargetObjectId(prli.Purchase_Invoice__r.Zumzum__Contact__c);
                    message.setTemplateId(templateId);
                } else if(prli.Purchase_Invoice__r.Zumzum__Account__r.Billing_Email__c != null &&
                prli.Purchase_Invoice__r.Zumzum__Contact__r.FirstName != null &&
                prli.Paid_Amount__c != null &&
                prli.Reference_Info__c != null) {
                    message.setToAddresses(new List<String> {prli.Purchase_Invoice__r.Zumzum__Account__r.Billing_Email__c});
                    String mergedTemplateBody = templateBody
                        .replace('{!Contact.FirstName}', prli.Purchase_Invoice__r.Zumzum__Contact__r.FirstName)
                        .replace('{!Payment_Run_Line_Item__c.Paid_Amount__c}', String.valueOf(prli.Paid_Amount__c))
                        .replace('{!Payment_Run_Line_Item__c.Reference_Info__c}', prli.Reference_Info__c);
                    message.setHtmlBody(mergedTemplateBody);
                } else {
                    continue;
                }
                message.setWhatId(prli.Id);
                message.setOrgWideEmailAddressId(orgWideAddressId);
                messages.add(message);
                prli.Is_Email_Sent__c = true;
                if(prli.Purchase_Invoice__r.Zumzum__Contact__r.Email == null && prli.Purchase_Invoice__r.Zumzum__Account__r.Billing_Email__c != null) {
                    
                }
            }
        }
        update items;
        
        String error;

        Messaging.SendEmailResult[] emailResponse = Messaging.sendEmail(messages);
        System.debug('emailResponse is: ' + emailResponse);
    }
    
    public void finish(Database.BatchableContext context) {
        Payment_Run__c paymentRun = [
            SELECT Id, Status__c FROM Payment_Run__c 
            WHERE Id = :paymentRunId
        ];
        paymentRun.Status__c = 'Closed';
        update paymentRun;
    }
}