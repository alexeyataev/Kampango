public without sharing class PaymentHubCalloutUtilities {
    
    
    private static PaymentHubApiSettings__c paymentHubApiSettings = PaymentHubApiSettings__c.getInstance();
    private static PaymentAPISettings__c paymentApiSettings = PaymentAPISettings__c.getInstance();
    
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
        
        tokenRequest.setEndpoint(paymentApiSettings.ENDPOINTOAUTH__c+'client_id='+paymentApiSettings.CLIENTID__c+'&client_secret='+paymentApiSettings.CLIENT_SECRET__c+'&grant_type=password&username='+paymentApiSettings.ENDPOINT_USERNAME__c+'&password='+paymentApiSettings.ENDPOINT_PASSWORD__c);
        
        tokenRequest.setMethod('POST'); 
        tokenRequest.setTimeout(120000);    
        
        tokenResponse = tokenHttp.send(tokenRequest);

        AcessTokenResponseVo accessTokenVo = (AcessTokenResponseVo)JSON.deserialize(tokenResponse.getBody(),AcessTokenResponseVo.class);

        
        
        PaymentRequestVo paymentReq = new PaymentRequestVo();
        paymentReq.SuccessURL= paymentHubApiSettings.Payment_Status_Root_Url__c +'/nctPaymentHubSuccessMsgPage?contId='+ cont.Id;
        paymentReq.FailureURL= paymentHubApiSettings.Payment_Status_Root_Url__c +'/nctPaymentHubErrorMsgPage';
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
            payment.Amount=instlmntAmt;
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
        
        paymentHubRequest.setEndpoint(paymentApiSettings.SF_INSTANCE__c+'/services/apexrest/cpm/v1.0/Payment');
        paymentHubRequest.setHeader('Authorization','Bearer '+accessTokenVo.access_token);
        paymentHubRequest.setHeader('Content-Type','application/json; charset=UTF-8');
        paymentHubRequest.setHeader('api-token',paymentHubApiSettings.Credit_Card_Payment_API_Token__c);
        paymentHubRequest.setBody(JSON.serialize(paymentReq));
        paymentHubRequest.setMethod('POST'); 
        paymentHubRequest.setTimeout(120000);    
        paymentHubResponse = paymentHubHttp.send(paymentHubRequest);
        responseContent = paymentHubResponse.getBody();
        redirectURL = responseContent.subString(responseContent.IndexOf('PaymentHub')+28, responseContent.lastIndexOf('PaymentMethod')-3);
        redirectURL += '&nooverride=1';
        
        return redirectURL;
    }
}