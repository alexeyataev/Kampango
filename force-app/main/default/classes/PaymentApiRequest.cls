public class PaymentApiRequest{
    private String successURL {get;set;}
    private String failureURL {get;set;}
    private String origin {get;set;}
    private Payer payer {get;set;}
    private Payment payment {get;set;}
    private PaymentMethod paymentMethod {get;set;}
    private Recurring recurring {get;set;}
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
    // DD
    public PaymentApiRequest(String successURL, String failureURL, String origin, Payer payer, Payment payment, PaymentMethod paymentMethod, Recurring recurring, SourceConnector sourceConnector) {
        this.successURL = successURL;
        this.failureURL = failureURL;
        this.origin = origin;
        this.payer = payer;
        this.payment = payment;
        this.paymentMethod = paymentMethod;
        this.recurring = recurring;
        this.sourceConnector = sourceConnector;
    }
    public class Payer {
        private Contact contact {get;set;}
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
        private Map<String, String> paymentProfile {get;set;}
        public PaymentMethod(String name) {
            this.name = name;
        }
        public PaymentMethod(String name, Map<String, String> paymentProfile) {
            this.name = name;
            this.paymentProfile = paymentProfile;
        }
    }
    public class Recurring {
        private String Amount {get;set;}
        private String Frequency {get;set;}
        private String StartDate {get;set;}
        public Recurring(String amount, String frequency, String startDate) {
            this.Amount = amount;
            this.Frequency = frequency;
            this.StartDate = startDate;
        }
    }
    public class SourceConnector {
        private String Name {get;set;}
        public SourceConnector(String name) {
            this.Name = name;
        }
    }
}