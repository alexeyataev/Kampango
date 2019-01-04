global class DirectpaymentlinksendtoParent
{      
    public static npe03__Recurring_Donation__c RecurringDonation = new npe03__Recurring_Donation__c();
    @auraenabled
    webservice static void PaymentHubCallout(Id contId)
    {        
        string redirectURL;
        string responseContent;
        
        RecurringDonation = [select Id, npe03__Amount__c,First_Contact__r.Email, First_Contact__r.Prefered_First_Name__c,
                             First_Contact__r.LastName from npe03__Recurring_Donation__c where First_Contact__c =: contId limit 1];
        
        HttpRequest tokenRequest = new HttpRequest();
        HttpResponse tokenResponse = new HttpResponse();
        Http tokenHttp = new Http();
        
        tokenRequest.setEndpoint('https://test.salesforce.com/services/oauth2/token?client_id=3MVG95AcBeaB55lVpFY_Rw8rGI.KUCG9dcqi1zRxbXuXhdoYYpgHOQUg01kQrJyfp_yYqnT6F.aEXC1U7n06J&client_secret=5804933462634405366&grant_type=password&username=payment.api@nct.org.uk.preuat&password=payment123rl3GtuRGUj15A1W6ysGuUAT3N');
  
        tokenRequest.setMethod('POST'); 
        tokenRequest.setTimeout(120000);    
        tokenResponse = tokenHttp.send(tokenRequest);

        AcessTokenResponseVo accessTokenVo = (AcessTokenResponseVo) JSON.deserialize(tokenResponse.getBody(),AcessTokenResponseVo.class);

        
        PaymentRequestVo paymentReq = new PaymentRequestVo();
        paymentReq.SuccessURL='https://preuat-mynct.cs102.force.com/nctMembershipPaymentPage/nctPaymentHubSuccessMsgPage?contId='+ contId;
        paymentReq.FailureURL='https://preuat-mynct.cs102.force.com/nctMembershipPaymentPage/nctPaymentHubErrorMsgPage';
        paymentReq.Origin='test';

        PaymentRequestVo.ContactVo cvo = new PaymentRequestVo.ContactVo();
        if(RecurringDonation!= null)
        {
            cvo.Email = RecurringDonation.First_Contact__r.Email;        // use RecurringDonation.FirstContact.Email
            cvo.FirstName = RecurringDonation.First_Contact__r.Prefered_First_Name__c;  // use RecurringDonation.FirstContact. Prefered_First_Name__c
            cvo.LastName = RecurringDonation.First_Contact__r.LastName;   // use RecurringDonation.FirstContact.LastName
        }
         
        PaymentRequestVo.PayerVo payerReq = new PaymentRequestVo.PayerVo();
        payerReq.AllowDeduplication=true;
        payerReq.contact = cvo;
        payerReq.ContactUpdate ='replace';
        paymentReq.Payer = payerReq;

        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo(); 
        if(RecurringDonation != null)
        {
            payment.Amount=RecurringDonation.npe03__Amount__c; 
        }        
        paymentReq.Payment = payment;

        PaymentRequestVo.PaymentMethodVo paymentMethod = new PaymentRequestVo.PaymentMethodVo();
        paymentMethod.Name='CreditCard';
        paymentReq.PaymentMethod = paymentMethod;

        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();
        sourceConnector.Name='PaymentHub';
        paymentReq.SourceConnector = sourceConnector;
        
        HttpRequest paymentHubRequest = new HttpRequest();
        HttpResponse paymentHubResponse = new HttpResponse();
        Http paymentHubHttp = new Http(); 
        paymentHubRequest.setEndpoint('https://cs102.salesforce.com/services/apexrest/cpm/v1.0/Payment');        
        paymentHubRequest.setHeader('Authorization','Bearer '+accessTokenVo.access_token);  
        //paymentHubRequest.setHeader('Authorization','Bearer '+ UserInfo.getSessionID()); 
        paymentHubRequest.setHeader('Content-Type','application/json; charset=UTF-8');
        paymentHubRequest.setHeader('Accept','application/json');
        paymentHubRequest.setHeader('api-token','IPy3Yvtin0aa2GPIke79Ewp24a0YSt6Daj5HJ9v9IGq2VTDYTWWkSx5jE2Pg54u02j0uHQZ3BwHfxFh8nKfXK4fiqZSQbZuXFQtQfAE926aFrwwVoOxPOJ6MiWSFpMc8b0UrOcbUD9pdcW7x8xNu3CtI5JfukTrRZqNByghsdTnWKLb79XrKpttmtHepMmVPv3QyPZYq');
        paymentHubRequest.setBody(JSON.serialize(paymentReq));
        paymentHubRequest.setMethod('POST'); 
        paymentHubRequest.setTimeout(120000);    
        paymentHubResponse = paymentHubHttp.send(paymentHubRequest);
        System.debug('*$*$*$*$*  RESPONSE =   ' + paymentHubResponse.getBody());
        responseContent = paymentHubResponse.getBody();
        system.debug('*$*$*$* responseContent ===   ' + responseContent);
        redirectURL = responseContent.subString(responseContent.IndexOf('PaymentHub')+28, responseContent.lastIndexOf('PaymentMethod')-3);
		sendPaymentLinkToParent (redirectURL);
    }

public static void sendPaymentLinkToParent(string paymentLink)
    {   
        npe03__Recurring_Donation__c recurringdonationtwo;
        system.debug('*$*$* EMail Method was called   ' + paymentLink);
        EmailTemplate emailTemplateId = [SELECT Id,Name,Subject, Body,HtmlValue FROM EmailTemplate WHERE Name ='NctMembershipPayment'];
        String emailBodyValue = emailTemplateId.HtmlValue;
        String emailSubjectValue = emailTemplateId.Subject;
        Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
        emailBodyValue = emailBodyValue.replace('{!npe03__Recurring_Donation__c.First_Contact__c}',RecurringDonation.First_Contact__r.Prefered_First_Name__c);
        emailBodyValue = emailBodyValue.replace('href=""', 'href="' + paymentLink +'"');
        system.debug('   *$*$* emailBodyValue   ' + emailBodyValue);
        mail.setHtmlBody(emailBodyValue);
        mail.setToAddresses(new String[] {RecurringDonation.First_Contact__r.Email});
        mail.setSubject(emailSubjectValue);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});  
    }

}