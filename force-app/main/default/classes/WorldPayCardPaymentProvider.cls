public class WorldPayCardPaymentProvider implements IPaymentServiceProvider {
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub-for-NPSP';
    private static final String SUCCESS_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'success';
    private static final String ERROR_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'error';
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ORIGIN = 'BookingJourney';
    public static String GetCardPaymentURL(String contactId, String feeAmount) {
        PaymentApiRequest paymentBody = createPaymentBody(contactId, feeAmount);
        String installmentPayRequest = JSON.serialize(paymentBody, true);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:World_Pay_Auth');
        req.setBody(installmentPayRequest);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('api_token', API_TOKEN);
        req.setMethod('POST');
        req.setTimeout(120000);
        Http http = new Http();
        HttpResponse resp = http.send(req);
        cpm.API_Request_Response.PaymentPostRequest request = (cpm.API_Request_Response.PaymentPostRequest)JSON.deserializeStrict(resp.getBody(), cpm.API_Request_Response.PaymentPostRequest.class);
        return request.RedirectURL;
    }
    private static PaymentApiRequest createPaymentBody(String contactId, String feeValue) {
        PaymentApiRequest paymentApiRequest = new PaymentApiRequest();
        paymentApiRequest.successURL = SUCCESS_PAGE;
        paymentApiRequest.failureURL = ERROR_PAGE;
        paymentApiRequest.origin = ORIGIN;
        PaymentApiRequest payer = new PaymentApiRequest();
        payer.contactUpdate = PAYER_CONTACT_UPDATE;
        PaymentApiRequest contact = new PaymentApiRequest();
        contact.id = contactId;
        payer.contact = contact;
        paymentApiRequest.payer = payer;
        PaymentApiRequest payment = new PaymentApiRequest();
        payment.amount = feeValue;
        paymentApiRequest.payment = payment;
        PaymentApiRequest paymentMethod = new PaymentApiRequest();
        paymentMethod.name = PAYMENT_METHOD;
        paymentApiRequest.paymentMethod = paymentMethod;
        PaymentApiRequest sourceConnector = new PaymentApiRequest();
        sourceConnector.name = SOURCE_CONNECTOR;
        paymentApiRequest.sourceConnector = sourceConnector;
        return paymentApiRequest;
    }
    private class PaymentApiRequest {
        private String successURL {get;set;}
        private String failureURL {get;set;}
        private String origin {get;set;}
        private String id {get;set;}
        private String contactUpdate {get;set;}
        private String amount {get;set;}
        private String name {get;set;}
        private PaymentApiRequest payer {get;set;}
        private PaymentApiRequest contact {get;set;}
        private PaymentApiRequest payment {get;set;}
        private PaymentApiRequest paymentMethod {get;set;}
        private PaymentApiRequest sourceConnector {get;set;}
    }
}