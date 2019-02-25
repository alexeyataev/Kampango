public without sharing class DirectPaymentLinkSendToParent
{    
    
    public static Payment_Link__c paymentLink = new Payment_Link__c();
    @auraenabled
    public static void paymentHubCallout(Id contId)
    {     
        paymentLink= [SELECT Id, Name, Contact__c,Payment_Link__c FROM Payment_Link__c where Contact__c =: contId limit 1];
        sendPaymentLinkToParent(paymentLink);
     }
      public static void sendPaymentLinkToParent(Payment_Link__c payLink)
      {   
        
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setTargetObjectId(payLink.Contact__c);
          message.setWhatId(payLink.Id);
          EmailTemplate emailTemplateId = [SELECT Id,Name,Subject, Body,HtmlValue FROM EmailTemplate WHERE Name ='NctMembershipPayment'];
          message.setTemplateId(emailTemplateId.Id);
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
       }

}