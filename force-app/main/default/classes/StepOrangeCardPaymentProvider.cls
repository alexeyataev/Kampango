public class StepOrangeCardPaymentProvider implements IPaymentServiceProvider {
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ERROR_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + '/s/failure';
    private static final String ORIGIN = 'BookingJourney';
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub';
    private static final String SUCCESS_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + '/s/success/?bookingId={0}';
    public static CardPaymentUrlResult getCardPaymentURL(cpm__Installment__c installment, String bookingId) {
        PaymentApiRequest paymentBody = createPaymentBody(installment, bookingId);
        createPaymentRequest(paymentBody);
        cpm.API_Payment_V1_0.postPayment();
        CardPaymentUrlResult cardPaymentUrlResult = createPaymentUrlResult();
        return cardPaymentUrlResult;
    }
    @TestVisible
    private static PaymentApiRequest createPaymentBody(cpm__Installment__c installment, String bookingId) {
        PaymentApiRequest.Contact contact = new PaymentApiRequest.Contact(installment.cpm__Contact__c);
        PaymentApiRequest.PaymentApiRequestParams paymentApiParams = new PaymentApiRequest.PaymentApiRequestParams();
        paymentApiParams.origin = ORIGIN;
        paymentApiParams.URLs = new PaymentApiRequest.URLs(String.format(SUCCESS_PAGE, new List<String>{bookingId}), ERROR_PAGE);
        paymentApiParams.payer = new PaymentApiRequest.Payer(contact, PAYER_CONTACT_UPDATE);
        Map<String, String> customFields = new Map<String, String>();
        customFields.put('Sales_Invoice__c', installment.Sales_Invoice__c);
        paymentApiParams.payment = new PaymentApiRequest.Payment(String.valueOf(installment.cpm__Amount__c), customFields);
        paymentApiParams.paymentMethod = new PaymentApiRequest.PaymentMethod(PAYMENT_METHOD);
        paymentApiParams.sourceConnector = new PaymentApiRequest.SourceConnector(SOURCE_CONNECTOR);
        PaymentApiRequest paymentBody = new PaymentApiRequest(paymentApiParams);
        return paymentBody;
    }
    @TestVisible
    private static void createPaymentRequest(PaymentApiRequest paymentBody) {
        String installmentPayRequest = JSON.serialize(paymentBody, true);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addHeader('api_token', API_TOKEN);
        req.requestBody = Blob.valueof(installmentPayRequest);
        RestContext.request = req;
        RestContext.response = res;
    }
    @TestVisible
    private static CardPaymentUrlResult createPaymentUrlResult() {
        cpm.API_Request_Response.PaymentPostResponse response = (cpm.API_Request_Response.PaymentPostResponse)JSON.deserializeStrict(
            RestContext.response.responseBody.toString(), 
            cpm.API_Request_Response.PaymentPostResponse.class
        );
        CardPaymentUrlResult cardPaymentUrlResult = new CardPaymentUrlResult();
        cardPaymentUrlResult.url = response.RedirectURL;
        return cardPaymentUrlResult;
    }
}