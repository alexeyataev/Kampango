public class PaymentApiRequest{
    private String successURL {get;set;}
    private String failureURL {get;set;}
    private String origin {get;set;}
    private Payer payer {get;set;}
    private Payment payment {get;set;}
    private PaymentMethod paymentMethod {get;set;}
    private SourceConnector sourceConnector {get;set;}
    public PaymentApiRequest(String successURL, String failureURL, String origin, Payer payer, Payment payment, PaymentMethod paymentMethod, SourceConnector sourceConnector) {
        this.successURL = successURL;
        this.failureURL = failureURL;
        this.origin = origin;
        this.payer = payer;
        this.payment = payment;
        this.paymentMethod = paymentMethod;
        this.sourceConnector = sourceConnector;
    }
    public class Payer {
        private Contact sontact {get;set;}
        private String contactUpdate {get;set;}
        public Payer(Contact contact, String contactUpdate) {
            this.contact = contact;
            this.contactUpdate = contactUpdate;
        }
    }
    public class Contact {
        private String id {get;set;}
        public Contact(String contactId) {
            this.id = contactId;
        }
    }
    public class Payment {
        private String amount {get;set;}
        public Payment(String amount) {
            this.amount = amount;
        }
    }
    public class PaymentMethod {
        private String name {get;set;}
        public PaymentMethod(String name) {
            this.name = name;
        }
    }
    public class SourceConnector {
        private String name {get;set;}
        public SourceConnector(String name) {
            this.name = name;
        }
    }
}