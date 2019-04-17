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
        paymentReq.SuccessURL= paymentHubApiSettings.Payment_Status_Root_Url__c +'/nctPaymentHubSuccessMsgPage?contId='+ cont.Id;
 
        PaymentRequestVo.ContactVo cvo = new PaymentRequestVo.ContactVo();
        if(cont != null)
        {
            cvo.Email = cont.Email;        
            cvo.FirstName = cont.FirstName;
            cvo.LastName = cont.LastName;
        }
 
        PaymentRequestVo.PayerVo payerReq = new PaymentRequestVo.PayerVo();
        payerReq.contact = cvo;
        paymentReq.Payer = payerReq;
 
        PaymentRequestVo.PaymentVo payment = new PaymentRequestVo.PaymentVo();
        if(cont!=null){       
            payment.Amount=instlmntAmt;
        }

        paymentReq.Payment = payment;
        PaymentRequestVo.PaymentMethodVo paymentMethod = new PaymentRequestVo.PaymentMethodVo();
        paymentReq.PaymentMethod = paymentMethod;
 
        PaymentRequestVo.SourceConnectorVo sourceConnector = new PaymentRequestVo.SourceConnectorVo();
        paymentReq.SourceConnector = sourceConnector;
        
        HttpRequest paymentHubRequest = new HttpRequest();
        HttpResponse paymentHubResponse = new HttpResponse();
        Http paymentHubHttp = new Http(); 
        
        
        paymentHubRequest.setEndpoint('callout:Stripe_Payment_API');
        paymentHubRequest.setHeader('Content-Type','application/json; charset=UTF-8');
        paymentHubRequest.setHeader('api-token',paymentHubApiSettings.Credit_Card_Payment_API_Token__c);
        paymentHubRequest.setBody(JSON.serialize(paymentReq));
        System.debug('JSON.serialize(paymentReq):'+JSON.serialize(paymentReq));
        paymentHubRequest.setMethod('POST'); 
        paymentHubRequest.setTimeout(120000);    
        paymentHubResponse = paymentHubHttp.send(paymentHubRequest);
        responseContent = paymentHubResponse.getBody();
        redirectURL = responseContent.subString(responseContent.IndexOf('PaymentHub')+28, responseContent.lastIndexOf('PaymentMethod')-3);
        redirectURL += '&nooverride=1';
        
        return redirectURL;
    }
}