public without sharing class PaymentHubCalloutUtilities {
    private static PaymentHubApiSettings__c paymentHubApiSettings = PaymentHubApiSettings__c.getInstance();
    
    public static String paymentHub(contact cont,Membership_Type__mdt membershipDetails, list<string> contactDetails){
        decimal instlmntAmt; 

        if(membershipDetails != null)
        {
           instlmntAmt = membershipDetails.Installment_Amount__c; 
        } 

        string responseContent;
        string redirectURL;
        PaymentRequestVo paymentReq = new PaymentRequestVo();
        
        PaymentRequestVo.ContactVo cvo = new PaymentRequestVo.ContactVo();
        if(cont != null)
        {
            cvo.Email = cont.Email;        
            cvo.FirstName = cont.FirstName;
            cvo.LastName = cont.LastName;
        }
 
        PaymentRequestVo.PayerVo payerReq = new PaymentRequestVo.PayerVo();
        payerReq.AllowDeduplication=true;
        payerReq.contact = cvo;
        payerReq.ContactUpdate ='replace';
        payerReq.SuccessURL= paymentHubApiSettings.Payment_Status_Root_Url__c +'/nctPaymentHubSuccessMsgPage?contId='+ cont.Id;
        payerReq.FailureURL= paymentHubApiSettings.Payment_Status_Root_Url__c +'/nctPaymentHubErrorMsgPage';
        payerReq.Origin='test';
        payerReq.Name='CreditCard';
        if(cont!=null){       
            payerReq.Amount=instlmntAmt;
        }
        paymentReq.Payer = payerReq;
 
 
        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();
        sourceConnector.Name='PaymentHub';
        paymentReq.SourceConnector = sourceConnector;
        
        HttpRequest paymentHubRequest = new HttpRequest();
        HttpResponse paymentHubResponse = new HttpResponse();
        Http paymentHubHttp = new Http(); 
        
        
        paymentHubRequest.setEndpoint('callout:Stripe_Payment_API');
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