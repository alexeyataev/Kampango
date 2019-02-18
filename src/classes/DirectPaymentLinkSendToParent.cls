global without sharing class DirectPaymentLinkSendToParent
{    
    
    public static npe03__Recurring_Donation__c recurringDonation = new npe03__Recurring_Donation__c();
    @auraenabled
    webservice static void paymentHubCallout(Id contId)
    {     
        String redirectURL;

        recurringDonation = [select Id, npe03__Amount__c,First_Contact__r.Email, First_Contact__r.Prefered_First_Name__c,
                             First_Contact__r.LastName from npe03__Recurring_Donation__c where First_Contact__c =: contId limit 1];
        
        Contact contact = new COntact(Id=contId);
        redirectURL = PaymentHubCalloutUtilities.PaymentHub(contact,null,null, recurringDonation);
        sendPaymentLinkToParent(redirectURL);
     }

      public static void sendPaymentLinkToParent(string paymentLink)
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
        emailBodyValue = emailBodyValue.replace('{!npe03__Recurring_Donation__c.First_Contact__c}',recurringDonation.First_Contact__r.Prefered_First_Name__c);
        emailBodyValue = emailBodyValue.replace('href=""', 'href="' + paymentLink +'"');
        system.debug('   *$*$* emailBodyValue   ' + emailBodyValue);
        mail.setHtmlBody(emailBodyValue);
        mail.setToAddresses(new String[] {recurringDonation.First_Contact__r.Email});
        mail.setSubject(emailSubjectValue);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});  
       }

}