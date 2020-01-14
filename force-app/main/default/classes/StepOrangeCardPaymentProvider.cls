public class StepOrangeCardPaymentProvider {
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ERROR_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + '/s/failure';
    private static final String ORIGIN = 'BookingJourney';
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub';
    private static final String SUCCESS_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + '/s/success/?bookingId=';
    public static CardPaymentUrlResult getCardPaymentURL(StepOrangePaymentParameters stepOrangePaymentParameters) {
        PaymentApiRequest paymentBody = createPaymentBody(stepOrangePaymentParameters);
        createPaymentRequest(paymentBody);
        cpm.API_Payment_V1_0.postPayment();
        CardPaymentUrlResult cardPaymentUrlResult = createPaymentUrlResult();
        return cardPaymentUrlResult;
    }
    public static CardPaymentUrlResult getCardPaymentPlanURL(StepOrangePaymentParameters stepOrangePaymentParameters) {
        PaymentApiRequest paymentBody = createPaymentPlanBody(stepOrangePaymentParameters);
        createPaymentRequest(paymentBody);
        cpm.API_Payment_V1_0.postPayment();
        CardPaymentUrlResult cardPaymentUrlResult = createPaymentUrlResult();
        return cardPaymentUrlResult;
    }
    @TestVisible
    private static PaymentApiRequest createPaymentBody(StepOrangePaymentParameters stepOrangePaymentParameters) {
        PaymentApiRequest.Contact contact = new PaymentApiRequest.Contact(stepOrangePaymentParameters.contactId);
        PaymentApiRequest.PaymentApiRequestParams paymentApiParams = new PaymentApiRequest.PaymentApiRequestParams();
        paymentApiParams.origin = ORIGIN;
        paymentApiParams.URLs = new PaymentApiRequest.URLs(SUCCESS_PAGE + stepOrangePaymentParameters.bookingId, ERROR_PAGE);
        paymentApiParams.payer = new PaymentApiRequest.Payer(contact, PAYER_CONTACT_UPDATE);
        Map<String, String> customFields = new Map<String, String>();
        customFields.put('Sales_Invoice__c', stepOrangePaymentParameters.salesInvoiceId);
        paymentApiParams.payment = new PaymentApiRequest.Payment(String.valueOf(stepOrangePaymentParameters.amount), customFields);
        paymentApiParams.paymentMethod = new PaymentApiRequest.PaymentMethod(PAYMENT_METHOD);
        paymentApiParams.sourceConnector = new PaymentApiRequest.SourceConnector(SOURCE_CONNECTOR);
        PaymentApiRequest paymentBody = new PaymentApiRequest(paymentApiParams);
        return paymentBody;
    }
    @TestVisible
    private static PaymentApiRequest createPaymentPlanBody(StepOrangePaymentParameters stepOrangePaymentParameters) {
        PaymentApiRequest.Contact contact = new PaymentApiRequest.Contact(stepOrangePaymentParameters.contactId);
        PaymentApiRequest.PaymentApiRequestParams paymentApiParams = new PaymentApiRequest.PaymentApiRequestParams();
        paymentApiParams.origin = ORIGIN;
        paymentApiParams.URLs = new PaymentApiRequest.URLs(SUCCESS_PAGE + stepOrangePaymentParameters.bookingId, ERROR_PAGE);
        paymentApiParams.payer = new PaymentApiRequest.Payer(contact, PAYER_CONTACT_UPDATE);
        Map<String, String> customFields = new Map<String, String>();
        customFields.put('Sales_Invoice__c', stepOrangePaymentParameters.salesInvoiceId);
        paymentApiParams.recurring = new PaymentApiRequest.Recurring(stepOrangePaymentParameters.amountRecurring, 'Monthly', stepOrangePaymentParameters.paymentPlanStartDate, stepOrangePaymentParameters.paymentPlanEndDate);
        paymentApiParams.payment = new PaymentApiRequest.Payment(String.valueOf(stepOrangePaymentParameters.amount), customFields);
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