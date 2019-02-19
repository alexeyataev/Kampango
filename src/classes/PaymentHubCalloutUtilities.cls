public without sharing class PaymentHubCalloutUtilities {
    public String sessionProfile = userinfo.getUserType();
    public static String paymentHub(contact cont,Membership_Type__mdt membershipDetails, list<string> contactDetails){
        decimal instlmntAmt; 
        
        if(membershipDetails != null)
        {
           instlmntAmt = membershipDetails.Installment_Amount__c; 
        } 
        
        string responseContent;
        string redirectURL;
        
        HttpRequest tokenRequest = new HttpRequest();
        HttpResponse tokenResponse = new HttpResponse();
        Http tokenHttp = new Http();
        
        tokenRequest.setEndpoint(System.Label.ENDPOINTOAUTH+'client_id='+System.Label.CLIENTID+'&client_secret='+System.Label.CLIENT_SECRET+'&grant_type=password&username='+System.Label.ENDPOINT_USERNAME+'&password='+System.Label.ENDPOINT_PASSWORD);
        //tokenRequest.setEndpoint('https://test.salesforce.com/services/oauth2/token?client_id=3MVG95AcBeaB55lVpFY_Rw8rGI.KUCG9dcqi1zRxbXuXhdoYYpgHOQUg01kQrJyfp_yYqnT6F.aEXC1U7n06J&client_secret=5804933462634405366&grant_type=password&username=payment.api@nct.org.uk.preuat&password=payment123rl3GtuRGUj15A1W6ysGuUAT3N');
  
        tokenRequest.setMethod('POST'); 
        tokenRequest.setTimeout(120000);    
        
        tokenResponse = tokenHttp.send(tokenRequest);

        AcessTokenResponseVo accessTokenVo = (AcessTokenResponseVo)JSON.deserialize(tokenResponse.getBody(),AcessTokenResponseVo.class);

        
        PaymentRequestVo paymentReq = new PaymentRequestVo();
        paymentReq.SuccessURL= System.Label.PAYMENTSTATUSURL+'/nctPaymentHubSuccessMsgPage?contId='+ cont.Id;//'https://preuat-mynct.cs102.force.com/nctMembershipPaymentPage/nctPaymentHubErrorMsgPage'
        paymentReq.FailureURL= System.Label.PAYMENTSTATUSURL+'/nctPaymentHubErrorMsgPage';
        paymentReq.Origin='test';
 
        PaymentRequestVo.ContactVo cvo = new PaymentRequestVo.ContactVo();
        if(cont != null)
        {
            cvo.Email = cont.Email;        
          cvo.FirstName = cont.FirstName;
          cvo.LastName = cont.LastName;
        }
        else if (cont == null)
        {
            cvo.Email = contactDetails[0];        
          cvo.FirstName = contactDetails[1];
          cvo.LastName = contactDetails[2];
        }
 
        PaymentRequestVo.PayerVo payerReq = new PaymentRequestVo.PayerVo();
        payerReq.AllowDeduplication=true;
        payerReq.contact = cvo;
        payerReq.ContactUpdate ='replace';
        paymentReq.Payer = payerReq;
 
        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo();
        if(cont!=null){
        system.debug('*$*$**$*$ feeAmount  ' + instlmntAmt);        
        payment.Amount=instlmntAmt;
        }
        paymentReq.Payment = payment;
        PaymentRequestVo.PaymentMethodVo paymentMethod = new PaymentRequestVo.PaymentMethodVo();
        paymentMethod.Name='CreditCard';
        paymentReq.PaymentMethod = paymentMethod;
 
        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();
        sourceConnector.Name='PaymentHub';
        paymentReq.SourceConnector = sourceConnector;
 
        System.Debug('*$*$*$*$* JSON  =   ' + JSON.serializePretty(paymentReq));
        
        HttpRequest paymentHubRequest = new HttpRequest();
        HttpResponse paymentHubResponse = new HttpResponse();
        Http paymentHubHttp = new Http(); 
        
        paymentHubRequest.setEndpoint(System.Label.SF_INSTANCE+'/services/apexrest/cpm/v1.0/Payment'); 
        
        //paymentHubRequest.setEndpoint('https://cs102.salesforce.com/services/apexrest/cpm/v1.0/Payment');        
        paymentHubRequest.setHeader('Authorization','Bearer '+accessTokenVo.access_token);  
        //paymentHubRequest.setHeader('Authorization','Bearer '+ UserInfo.getSessionID()); 
        paymentHubRequest.setHeader('Content-Type','application/json; charset=UTF-8');
        paymentHubRequest.setHeader('Accept','application/json');
        
        paymentHubRequest.setHeader('api-token',System.Label.API_TOKEN);
        //paymentHubRequest.setHeader('api-token','IPy3Yvtin0aa2GPIke79Ewp24a0YSt6Daj5HJ9v9IGq2VTDYTWWkSx5jE2Pg54u02j0uHQZ3BwHfxFh8nKfXK4fiqZSQbZuXFQtQfAE926aFrwwVoOxPOJ6MiWSFpMc8b0UrOcbUD9pdcW7x8xNu3CtI5JfukTrRZqNByghsdTnWKLb79XrKpttmtHepMmVPv3QyPZYq');
        paymentHubRequest.setBody(JSON.serialize(paymentReq));
        paymentHubRequest.setMethod('POST'); 
        paymentHubRequest.setTimeout(120000);    
        paymentHubResponse = paymentHubHttp.send(paymentHubRequest);
        System.debug('*$*$*$*$*  RESPONSE =   ' + paymentHubResponse.getBody());
        responseContent = paymentHubResponse.getBody();
        system.debug('*$*$*$* responseContent ===   ' + responseContent);
        redirectURL = responseContent.subString(responseContent.IndexOf('PaymentHub')+28, responseContent.lastIndexOf('PaymentMethod')-3);
        system.debug('*$*$*$** redirectURL =   ' + redirectURL);
        redirectURL += '&nooverride=1';
        
        //NctETMembershipPaymentPageController paymentLinkDetails = new NctETMembershipPaymentPageController();
        //paymentLinkDetails.sendPaymentLinkToParent(redirectURL);
        
        return redirectURL;
                
    
    }
    
    
}