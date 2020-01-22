public class StepOrangeCardPaymentProvider implements IPaymentServiceProvider {
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub-for-NPSP';
    private static final String SUCCESS_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + '/s/success';
    private static final String ERROR_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + '/s/failure';
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ORIGIN = 'BookingJourney';

    public static String getCardPaymentURL(String contactId, String feeAmount) {
        PaymentApiRequest paymentBody = createPaymentBody(contactId, feeAmount);
        String installmentPayRequest = JSON.serialize(paymentBody, true);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Step_Orange_Auth');
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
        PaymentApiRequest.Contact contact = new PaymentApiRequest.Contact(contactId);
        PaymentApiRequest.PaymentApiRequestParams paymentApiParams = new PaymentApiRequest.PaymentApiRequestParams();
        paymentApiParams.origin = ORIGIN;
        paymentApiParams.URLs = new PaymentApiRequest.URLs(SUCCESS_PAGE, ERROR_PAGE);
        paymentApiParams.payer = new PaymentApiRequest.Payer(contact, PAYER_CONTACT_UPDATE);
        paymentApiParams.payment = new PaymentApiRequest.Payment(feeValue);
        paymentApiParams.paymentMethod = new PaymentApiRequest.PaymentMethod(PAYMENT_METHOD);
        paymentApiParams.sourceConnector = new PaymentApiRequest.SourceConnector(SOURCE_CONNECTOR);
        PaymentApiRequest paymentBody = new PaymentApiRequest(paymentApiParams);
        return paymentBody;
    }
}