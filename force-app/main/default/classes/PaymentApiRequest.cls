public class PaymentApiRequest{
    private String successURL {get;set;}
    private String failureURL {get;set;}
    private String origin {get;set;}
    private Payer payer {get;set;}
    private Payment payment {get;set;}
    private PaymentMethod paymentMethod {get;set;}
    private SourceConnector sourceConnector {get;set;}

    public PaymentApiRequest(String apiRequestParams) {
        PaymentApiRequestParams paymentParams = (PaymentApiRequestParams)JSON.deserialize(apiRequestParams,PaymentApiRequestParams.class);
        this.successURL = paymentParams.successURL;
        this.failureURL = paymentParams.failureURL;
        this.origin = paymentParams.origin;
        this.payer = paymentParams.payer;
        this.payment = paymentParams.payment;
        this.paymentMethod = paymentParams.paymentMethod;
        this.sourceConnector = paymentParams.sourceConnector;
    }

    public class PaymentApiRequestParams {
        public String successURL { get; set; }
        public String failureURL { get; set; }
        public String origin { get; set; }
        public Payer payer { get; set; }
        public Payment payment { get; set; }
        public PaymentMethod paymentMethod { get; set; }
        public SourceConnector sourceConnector { get; set; }
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