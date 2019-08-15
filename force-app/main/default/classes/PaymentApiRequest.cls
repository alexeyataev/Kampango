public class PaymentApiRequest{
    private String SuccessURL {get;set;}
    private String FailureURL {get;set;}
    private String Origin {get;set;}
    private Payer Payer {get;set;}
    private Payment Payment {get;set;}
    private PaymentMethod PaymentMethod {get;set;}
    private Recurring Recurring {get;set;}
    private SourceConnector SourceConnector {get;set;}
    public PaymentApiRequest(String successURL, String failureURL, String origin, Payer payer, Payment payment, PaymentMethod paymentMethod, SourceConnector sourceConnector) {
        this.SuccessURL = successURL;
        this.FailureURL = failureURL;
        this.Origin = origin;
        this.Payer = payer;
        this.Payment = payment;
        this.PaymentMethod = paymentMethod;
        this.SourceConnector = sourceConnector;
    }
    // DD
    public PaymentApiRequest(String successURL, String failureURL, String origin, Payer payer, Payment payment, PaymentMethod paymentMethod, Recurring recurring, SourceConnector sourceConnector) {
        this.SuccessURL = successURL;
        this.FailureURL = failureURL;
        this.Origin = origin;
        this.Payer = payer;
        this.Payment = payment;
        this.PaymentMethod = paymentMethod;
        this.Recurring = recurring;
        this.SourceConnector = sourceConnector;
    }
    public class Payer {
        private Contact Contact {get;set;}
        private String ContactUpdate {get;set;}
        public Payer(Contact contact, String contactUpdate) {
            this.Contact = contact;
            this.ContactUpdate = contactUpdate;
        }
    }
    public class Contact {
        private String Id {get;set;}
        public Contact(String contactId) {
            this.Id = contactId;
        }
    }
    public class Payment {
        private String Amount {get;set;}
        public Payment(String amount) {
            this.Amount = amount;
        }
    }
    public class PaymentMethod {
        private String Name {get;set;}
        private Map<String, String> PaymentProfile {get;set;}
        public PaymentMethod(String name) {
            this.Name = name;
        }
        public PaymentMethod(String name, Map<String, String> paymentProfile) {
            this.Name = name;
            this.PaymentProfile = paymentProfile;
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