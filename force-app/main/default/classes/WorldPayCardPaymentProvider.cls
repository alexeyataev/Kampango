public class WorldPayCardPaymentProvider implements IPaymentServiceProvider {
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub-for-NPSP';
    private static final String SUCCESS_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'success';
    private static final String ERROR_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'error';
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ORIGIN = 'BookingJourney';
    public static String GetCardPaymentURL(String contactId, String feeAmount) {
        PaymentBody paymentBody = createPaymentBody(contactId, feeAmount);
        String installmentPayRequest = JSON.serialize(paymentBody);
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
    private static PaymentBody createPaymentBody(String contactId, String feeValue) {
        Payer payer = new Payer(contactId, PAYER_CONTACT_UPDATE);
        PaymentBody paymentBody = new PaymentBody(SUCCESS_PAGE, ERROR_PAGE, ORIGIN, payer, feeValue, PAYMENT_METHOD, SOURCE_CONNECTOR);
        return paymentBody;
    }
    private class PaymentBody {
        private String successURL {get;set;}
        private String failureURL {get;set;}
        private String origin {get;set;}
        private Payer payer {get;set;}
        private Map<String, String> payment {get;set;}
        private Map<String, String> paymentMethod {get;set;}
        private Map<String, String> sourceConnector {get;set;}
        private PaymentBody(String successURL, String failureURL, String origin, Payer payer, String payment, String paymentMethod, String sourceConnector) {
            this.successURL = successURL;
            this.failureURL = failureURL;
            this.origin = origin;
            this.payer = payer;
            this.payment = new Map<String, String> {'Amount' => payment};
            this.paymentMethod = new Map<String, String> {'Name' => paymentMethod};
            this.sourceConnector = new Map<String, String> {'Name' => sourceConnector};
        }
    }
    private class Payer {
        private Map<String, String> contact {get;set;}
        private String contactUpdate {get;set;}
        private Payer(String contactId, String contactUpdate) {
            this.contact = new Map<String, String> {'Id' => contactId};
            this.contactUpdate = contactUpdate;
        }
    }
}