public without sharing class DirectPaymentLinkSendToParent
{    
    
    public static Payment_Link__c paymentLink = new Payment_Link__c();
    @auraenabled
    public static void paymentHubCallout(Id contId)
    {     
        String redirectURL;

        paymentLink= [SELECT Id, Name, Contact__c,Contact__r.Email, Data_Source__c, Email__c, Link_Sent_Date__c, Link_Status__c, Payment_Key__c, Payment_Link__c, Contact_FirstName__c FROM Payment_Link__c where Contact__c =: contId limit 1];
        redirectURL = paymentLink.Payment_Link__c;
        sendPaymentLinkToParent(redirectURL, paymentLink);
     }
      public static void sendPaymentLinkToParent(string paymentLink, Payment_Link__c payLink)
      {   
        npe03__Recurring_Donation__c recurringdonationtwo;
        system.debug('*$*$* EMail Method was called   ' + paymentLink);
              if (!Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
             }
        EmailTemplate emailTemplateId = [SELECT Id,Name,Subject, Body,HtmlValue FROM EmailTemplate WHERE Name ='NctMembershipPayment'];
        String emailBodyValue = emailTemplateId.HtmlValue;
        String emailSubjectValue = emailTemplateId.Subject;
        Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
        emailBodyValue = emailBodyValue.replace('{!npe03__Recurring_Donation__c.First_Contact__c}',payLink.Contact_FirstName__c);
        emailBodyValue = emailBodyValue.replace('href=""', 'href="' + paymentLink +'"');
        system.debug('   *$*$* emailBodyValue   ' + emailBodyValue);
        mail.setHtmlBody(emailBodyValue);
        mail.setToAddresses(new String[] {payLink.Contact__r.Email});
        mail.setSubject(emailSubjectValue);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});  
       }

}