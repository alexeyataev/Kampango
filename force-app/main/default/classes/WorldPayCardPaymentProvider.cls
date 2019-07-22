public class WorldPayCardPaymentProvider implements IPaymentServiceProvider {
    private static final String PAYER_CONTACT_UPDATE = 'none';
    private static final String PAYMENT_METHOD = 'Creditcard';
    private static final String SOURCE_CONNECTOR = 'PaymentHub-for-NPSP';
    private static final String SUCCESS_PAGE = !Parentforce_Community_Settings__c.getAll().values().isEmpty() ? Parentforce_Community_Settings__c.getAll().values()[0].BaseUrl__c + 'success' : '';
    private static final String ERROR_PAGE = !Parentforce_Community_Settings__c.getAll().values().isEmpty() ? Parentforce_Community_Settings__c.getAll().values()[0].BaseUrl__c + 'error' : '';
    private static final String ORIGIN = 'BookingJourney';
    private static final Boolean ALLOW_DEDUPLICATION = true;
    public static List<String> getPaymentLink(List<List<String>> params) {
        String contactId = params[0][0] != null ? params[0][0] : '';
        String feeAmount = params[0][1] != null ? params[0][1] : '';
        PaymentBody paymentBody = createPaymentBody(contactId, feeAmount);
        String installmentPayRequest = JSON.serialize(paymentBody);   
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:World_Pay_Test_Auth');
        req.setBody(installmentPayRequest);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('api_token', 'qJKBsZNzdqClIuKvGx0zIApojFpYSIBSFwDA2qalvq2BljHVIU1ktRM5KHfNciQyW9PRK4bxYgiNwxKuqokMK7zjfzcM47cj53crArfpl8siZD9vpm9u4swxg3nl75sD32BzZimaSvGnAsIBbQmwneacYkt9wSpddoxgJRJQo43esYuWTxp8SHzE8jgBv50Itvtu68wk');
        req.setMethod('POST');
        req.setTimeout(120000);
        Http http = new Http();
        HttpResponse resp = http.send(req);
        cpm.API_Request_Response.PaymentPostRequest request = (cpm.API_Request_Response.PaymentPostRequest)JSON.deserializeStrict(resp.getBody(), cpm.API_Request_Response.PaymentPostRequest.class);
        return new List<String>{request.RedirectURL};
    }
    private static PaymentBody createPaymentBody(String contactId, String feeValue) {
        Contact contact = new Contact(contactId);
        Payer payer = new Payer(ALLOW_DEDUPLICATION, contact, PAYER_CONTACT_UPDATE);
        Payment payment = new Payment(feeValue);
        PaymentMethod paymentMethod = new PaymentMethod(PAYMENT_METHOD);
        SourceConnector sourceConnector = new SourceConnector(SOURCE_CONNECTOR);
        PaymentBody paymentBody = new PaymentBody(SUCCESS_PAGE, ERROR_PAGE, ORIGIN, payer, payment, paymentMethod, sourceConnector);
        return paymentBody;
    }
    private class PaymentBody {
        private String SuccessURL {get;set;}
        private String FailureURL {get;set;}
        private String Origin {get;set;}
        private Payer Payer {get;set;}
        private Payment Payment {get;set;}
        private PaymentMethod PaymentMethod {get;set;}
        private SourceConnector SourceConnector {get;set;}
        private PaymentBody(String successURL, String failureURL, String origin, Payer payer, Payment payment, PaymentMethod paymentMethod, SourceConnector sourceConnector) {
            this.SuccessURL = successURL;
            this.FailureURL = failureURL;
            this.Origin = origin;
            this.Payer = payer;
            this.Payment = payment;
            this.PaymentMethod = paymentMethod;
            this.SourceConnector = sourceConnector;
        }
    }
    private class Payer {
        private Boolean AllowDeduplication {get;set;}
        private Contact Contact {get;set;}
        private String ContactUpdate {get;set;}
        private Payer(Boolean allowDeduplication, Contact contact, String contactUpdate) {
            this.AllowDeduplication = allowDeduplication;
            this.Contact = contact;
            this.ContactUpdate = contactUpdate;
        }
    }
    private class Contact {
        private String Id {get;set;}
        private Contact(String contactId) {
            this.Id = contactId;
        }
    }
    private class Payment {
        private String Amount {get;set;}
        private Payment(String amount) {
            this.Amount = amount;
        }
    }
    private class PaymentMethod {
        private String Name {get;set;}
        private PaymentMethod(String name) {
            this.Name = name;
        }
    }
    private class SourceConnector {
        private String Name {get;set;}
        private SourceConnector(String name) {
            this.Name = name;
        }
    }
}