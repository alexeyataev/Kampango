public class FinDockCardPaymentProvider implements IPaymentServiceProvider {
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ORIGIN = 'BookingJourney';
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub';
    public static CardPaymentUrlResult getCardPaymentPlanUrlForBooking(CardPaymentParameters paymentParameters) {
        PaymentApiRequest paymentBody = createPaymentPlanBody(paymentParameters);
        createPaymentRequest(paymentBody);
        cpm.API_Payment_V1_0.postPayment();
        CardPaymentUrlResult cardPaymentUrlResult = createPaymentUrlResult();
        return cardPaymentUrlResult;
    }
    public static CardPaymentUrlResult getCardPaymentUrl(CardPaymentParameters paymentParameters) {
        PaymentApiRequest paymentBody = createPaymentBody(paymentParameters);
        createPaymentRequest(paymentBody);
        cpm.API_Payment_V1_0.postPayment();
        CardPaymentUrlResult cardPaymentUrlResult = createPaymentUrlResult();
        return cardPaymentUrlResult;
    }
    @TestVisible
    private static PaymentApiRequest createPaymentBody(CardPaymentParameters paymentParameters) {
        PaymentApiRequest.Contact contact = new PaymentApiRequest.Contact(paymentParameters.contactId);
        PaymentApiRequest.PaymentApiRequestParams paymentApiParams = new PaymentApiRequest.PaymentApiRequestParams();
        paymentApiParams.origin = ORIGIN;
        paymentApiParams.URLs = new PaymentApiRequest.URLs(paymentParameters.errorPage, paymentParameters.successPage);
        paymentApiParams.payer = new PaymentApiRequest.Payer(contact, PAYER_CONTACT_UPDATE);
        Map<String, String> customFields = new Map<String, String>();
        customFields.put('Sales_Invoice__c', paymentParameters.salesInvoiceId);
        paymentApiParams.payment = new PaymentApiRequest.Payment(String.valueOf(paymentParameters.amount), customFields);
        paymentApiParams.paymentMethod = new PaymentApiRequest.PaymentMethod(PAYMENT_METHOD);
        paymentApiParams.sourceConnector = new PaymentApiRequest.SourceConnector(SOURCE_CONNECTOR);
        PaymentApiRequest paymentBody = new PaymentApiRequest(paymentApiParams);
        return paymentBody;
    }
    @TestVisible
    private static PaymentApiRequest createPaymentPlanBody(CardPaymentParameters paymentParameters) {
        PaymentApiRequest.Contact contact = new PaymentApiRequest.Contact(paymentParameters.contactId);
        PaymentApiRequest.PaymentApiRequestParams paymentApiParams = new PaymentApiRequest.PaymentApiRequestParams();
        paymentApiParams.origin = ORIGIN;
        paymentApiParams.URLs = new PaymentApiRequest.URLs(paymentParameters.errorPage, paymentParameters.successPage);
        paymentApiParams.payer = new PaymentApiRequest.Payer(contact, PAYER_CONTACT_UPDATE);
        Map<String, String> customFields = new Map<String, String>();
        customFields.put('Sales_Invoice__c', paymentParameters.salesInvoiceId);
        paymentApiParams.recurring = new PaymentApiRequest.Recurring(paymentParameters.amountRecurring, 'Monthly', paymentParameters.paymentPlanStartDate, paymentParameters.paymentPlanEndDate);
        paymentApiParams.payment = new PaymentApiRequest.Payment(String.valueOf(paymentParameters.amount), customFields);
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
        );system.System.debug(response);
        CardPaymentUrlResult cardPaymentUrlResult = new CardPaymentUrlResult();
        cardPaymentUrlResult.url = response.RedirectURL;
        return cardPaymentUrlResult;
    }
}