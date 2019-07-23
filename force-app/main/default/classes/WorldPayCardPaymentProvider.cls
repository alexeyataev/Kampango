public class WorldPayCardPaymentProvider implements IPaymentServiceProvider {
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = '{"Name":"Creditcard"}';
    private static final String SOURCE_CONNECTOR = '{"Name":"PaymentHub-for-NPSP"}';
    private static final String SUCCESS_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'success';
    private static final String ERROR_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'error';
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ORIGIN = 'BookingJourney';
    public static String GetCardPaymentURL(String contactId, String feeAmount) {
        PaymentBody paymentBody = createPaymentBody(contactId, feeAmount);
        String installmentPayRequest = JSON.serialize(paymentBody);
        system.debug(installmentPayRequest);
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
        String contactParam = '{"Id":"' + contactId + '"}';
        Payer payer = new Payer(contactParam, PAYER_CONTACT_UPDATE);
        String feeParam = '{"Amount":"' + feeValue + '"}';
        PaymentBody paymentBody = new PaymentBody(SUCCESS_PAGE, ERROR_PAGE, ORIGIN, payer, feeParam, PAYMENT_METHOD, SOURCE_CONNECTOR);
        return paymentBody;
    }
    private class PaymentBody {
        private String SuccessURL {get;set;}
        private String FailureURL {get;set;}
        private String Origin {get;set;}
        private Payer Payer {get;set;}
        private Object Payment {get;set;}
        private Object PaymentMethod {get;set;}
        private Object SourceConnector {get;set;}
        private PaymentBody(String successURL, String failureURL, String origin, Payer payer, String payment, String paymentMethod, String sourceConnector) {
            this.SuccessURL = successURL;
            this.FailureURL = failureURL;
            this.Origin = origin;
            this.Payer = payer;
            this.Payment = JSON.deserializeUntyped(payment);
            this.PaymentMethod = JSON.deserializeUntyped(paymentMethod);
            this.SourceConnector = JSON.deserializeUntyped(sourceConnector);
        }
    }
    private class Payer {
        private Object Contact {get;set;}
        private String ContactUpdate {get;set;}
        private Payer(String contactParam, String contactUpdate) {
            this.Contact = JSON.deserializeUntyped(contactParam);
            this.ContactUpdate = contactUpdate;
        }
    }
}