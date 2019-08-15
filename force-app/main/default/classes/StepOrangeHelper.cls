public class StepOrangeHelper {
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub-for-NPSP';
    private static final String SUCCESS_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'success';
    private static final String ERROR_PAGE = Parentforce_Community_Settings__c.getOrgDefaults().Base_Url__c + 'error';
    private static final String API_TOKEN = Parentforce_Community_Settings__c.getOrgDefaults().API_Token__c;
    private static final String ORIGIN = 'BookingJourney';
    public static String getCardPaymentURL(Booking__c booking, Boolean isRecurring) {
        PaymentApiRequest paymentBody = createPaymentBody(booking, isRecurring);
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
        system.debug('###getCardPaymentURL request' + JSON.serializePretty(paymentBody, true));
        cpm.API_Request_Response.PaymentPostRequest request = (cpm.API_Request_Response.PaymentPostRequest)JSON.deserializeStrict(resp.getBody(), cpm.API_Request_Response.PaymentPostRequest.class);
        return request.RedirectURL;
    }
    private static PaymentApiRequest createPaymentBody(Booking__c booking, Boolean isRecurring) {
        PaymentApiRequest.Contact contact = new PaymentApiRequest.Contact(booking.Primary_Contact__c);
        PaymentApiRequest.Payer payer = new PaymentApiRequest.Payer(contact, PAYER_CONTACT_UPDATE);
        PaymentApiRequest.Payment payment;
        PaymentApiRequest.PaymentMethod paymentMethod;
        PaymentApiRequest.Recurring recurring;
        if(isRecurring) {
            recurring = new PaymentApiRequest.Recurring('25', 'Monthly', '2099-12-01');
            //paymentMethod = new PaymentApiRequest.PaymentMethod(PAYMENT_METHOD, new Map<String, String>{'cpm__BIC_Code__c' => 'AEGONL2A', 'cpm__Holder_Name__c' => 'J. Smith', 'cpm__IBAN__c' => 'NL65AEGO0731729259'});
            cpm__Payment_Profile__c pProfile = [SELECT Id, cpm__BIC_Code__c, cpm__Holder_Name__c, cpm__IBAN__c FROM cpm__Payment_Profile__c WHERE cpm__Contact__c =: booking.Primary_Contact__c LIMIT 1];
            paymentMethod = new PaymentApiRequest.PaymentMethod(PAYMENT_METHOD, 
                new Map<String, String>{'cpm__BIC_Code__c' => pProfile.cpm__BIC_Code__c, 'cpm__Holder_Name__c' => pProfile.cpm__Holder_Name__c, 'cpm__IBAN__c' => pProfile.cpm__IBAN__c});
        } else {
            payment = new PaymentApiRequest.Payment(String.valueOf(booking.Course__r.Fee__c));
            paymentMethod = new PaymentApiRequest.PaymentMethod(PAYMENT_METHOD);
        }
        PaymentApiRequest.SourceConnector sourceConnector = new PaymentApiRequest.SourceConnector(SOURCE_CONNECTOR);
        PaymentApiRequest paymentBody = new PaymentApiRequest(SUCCESS_PAGE, ERROR_PAGE, ORIGIN, payer, payment, paymentMethod, recurring, sourceConnector);
        return paymentBody;
    }
}