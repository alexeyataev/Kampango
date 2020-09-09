global class BacsSendRemittanceEmailsBatch implements Database.Batchable<Payment_Run_Line_Item__c>, Database.AllowsCallouts {
    private final String EMAIL_ADDRESS = 'noreply-parentforce@nct.org.uk';
    private OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: EMAIL_ADDRESS LIMIT 1];
    private EmailTemplate emailTemplate = [SELECT Id, Body, Subject FROM EmailTemplate WHERE DeveloperName = 'BACSRemittanceEmail'];
    private List<Payment_Run_Line_Item__c> prliList;

    global BacsSendRemittanceEmailsBatch(List<Payment_Run_Line_Item__c> prliList) {
        this.prliList = prliList;
    }

    global Iterable<Payment_Run_Line_Item__c> start(Database.BatchableContext BC) {
        return (Iterable<Payment_Run_Line_Item__c>)prliList;
    }

    global void execute(Database.BatchableContext BC, List<Payment_Run_Line_Item__c> scope) {
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        for(Payment_Run_Line_Item__c prli : scope) {
            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
            singleEmailMessage.setSubject(emailTemplate.Subject);
            singleEmailMessage.setPlainTextBody(createEmailBody(emailTemplate.Body, prli));
            singleEmailMessage.setToAddresses(new List<String>{prli.Supplier_Account_Billing_Email__c});
            singleEmailMessage.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            singleEmailMessageList.add(singleEmailMessage);
            prli.Is_Email_Sent__c = true;
        }
        if (TestEmailUtility.emailsFeatureEnabled()) {
            Messaging.sendEmail(singleEmailMessageList);
        }
        update scope;
    }

    private String createEmailBody(String body, Payment_Run_Line_Item__c prli) {
        return String.format(body, new List<String> {String.valueOf(prli.Paid_Amount__c), prli.Reference_Info__c});
    }

    global void finish(Database.BatchableContext BC) {

    }
}