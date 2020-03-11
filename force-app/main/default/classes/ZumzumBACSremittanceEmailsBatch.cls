global class ZumzumBACSremittanceEmailsBatch implements Database.Batchable<Payment_Run_Line_Item__c> {
    
    private Id paymentRunId;
    private Id orgWideAddressId;
    private Id templateId;
    
    
    global ZumzumBACSremittanceEmailsBatch(Id paymentRunId, Id templateId, Id orgWideAddressId) {
        this.paymentRunId = paymentRunId;
        this.templateId = templateId;
        this.orgWideAddressId = orgWideAddressId;
    }
    
	global List<Payment_Run_Line_Item__c> start(Database.BatchableContext context) {
        return [
            SELECT Id, Name, Unpaid_Amount__c, Reference_Info__c,
            	Purchase_Invoice__r.Zumzum__Contact__c
            FROM Payment_Run_Line_Item__c
            WHERE Payment_Run__c = :paymentRunId
            AND Is_Email_Sent__c = false
        ];
    }
    
    global void execute(Database.BatchableContext context, List<Payment_Run_Line_Item__c> items) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        List<Payment_Run_Line_Item__c> itemsToUpdate = new List<Payment_Run_Line_Item__c>();
        for (Payment_Run_Line_Item__c prli : items) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTemplateId(templateId);
            message.setTargetObjectId(prli.Purchase_Invoice__r.Zumzum__Contact__c);
            message.setWhatId(prli.Id);
            message.setOrgWideEmailAddressId(orgWideAddressId);
            messages.add(message);
            
            prli.Is_Email_Sent__c = true;
        }
        update items;
        
        String error;
        try {
            Messaging.SendEmailResult[] emailResponse = Messaging.sendEmail(messages);
            System.debug('emailResponse is: ' + emailResponse);
        } catch (EmailException e){
            error = e.getMessage();
            if (error.contains('UNVERIFIED_SENDER_ADDRESS')) {
                throw e;
            } else {
                System.debug ('exception occured: ' + error);
            }
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
    
    
}