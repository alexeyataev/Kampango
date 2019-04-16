public with sharing class PaymentRequestVo {
    
   
    public PayerVo payer{get;set;}
    public SourceConnectorVo sourceConnector{get;set;}

    	//Assessment Vo
	public class PayerVo{
	    public Boolean allowDeduplication{get;set;}
		public ContactVo contact{get;set;}
		public String contactUpdate;
        public String successURL;
        public String failureURL;
        public String origin;
        public Decimal amount{get;set;}
        public String name{get;set;}
	}
    

	public class ContactVo{
	    public String email;
	    public String firstName;
	    public String lastName;
	}

	public class SourceConnectorVo{
	    public String name{get;set;}
	    
	}
}