public class PaymentApiRequest{
    private String successURL {get;set;}
    private String failureURL {get;set;}
    private String origin {get;set;}
    private Payer payer {get;set;}
    private Payment payment {get;set;}
    private PaymentMethod paymentMethod {get;set;}
    private SourceConnector sourceConnector {get;set;}
    private Recurring recurring {get;set;}
    public PaymentApiRequest(PaymentApiRequestParams apiRequestParams) {
        this.successURL = apiRequestParams.URLs.successURL;
        this.failureURL = apiRequestParams.URLs.failureURL;
        this.origin = apiRequestParams.origin;
        this.payer = apiRequestParams.payer;
        this.payment = apiRequestParams.payment;
        this.paymentMethod = apiRequestParams.paymentMethod;
        this.recurring = apiRequestParams.recurring;
        this.sourceConnector = apiRequestParams.sourceConnector;
    }
    public class PaymentApiRequestParams {
        public URLs urls { get; set; }
        public String origin { get; set; }
        public Payer payer { get; set; }
        public Payment payment { get; set; }
        public PaymentMethod paymentMethod { get; set; }
        public Recurring recurring { get; set;}
        public SourceConnector sourceConnector { get; set; }
    }
    public class URLs {
        private String successURL { get; set; }
        private String failureURL { get; set; }
        public URLs(String successURL, String failureURL) {
            this.successURL = successURL;
            this.failureURL = failureURL;
        }
    }
    public class Payer {
        private Contact contact {get;set;}
        private String contactUpdate {get;set;}
        public Payer(Contact contact, String contactUpdate) {
            this.contact = contact;
            this.contactUpdate = contactUpdate;
        }
    }
    public class Recurring {
        private Decimal amount {get;set;}
        private String frequency {get;set;}
        private Date startDate {get;set;}
        private Date endDate {get;set;}
        public Recurring(Decimal amount, String frequency, Date startDate, Date endDate) {
            this.amount = amount;
            this.frequency = frequency;
            this.startDate = startDate;
            this.endDate = endDate;
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
        private Map<String, String> customFields {get;set;}
        public Payment(String amount, Map<String, String> customFields) {
            this.amount = amount;
            this.customFields = customFields;
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