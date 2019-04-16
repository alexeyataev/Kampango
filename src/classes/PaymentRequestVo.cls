public with sharing class PaymentRequestVo {
    
   
    public PayerVo payer{get;set;}
    public PaymentVo payment{get;set;}
    public SourceConnectorVo sourceConnector{get;set;}

    	//Assessment Vo
	public class PayerVo{
	    public Boolean allowDeduplication{get;set;}
		public ContactVo contact{get;set;}
		public String contactUpdate,successURL,failureURL,origin;
        //public String successURL{get;set;}
        //public String failureURL{get;set;}
        //public String origin{get;set;}
	}
    
	public class PaymentVo{
	    public Decimal amount{get;set;}
        public String name{get;set;}
	}

	public class ContactVo{
	    public String email,firstName,lastName;
	    //public String firstName{get;set;}
	    //public String lastName{get;set;}
	}

	public class SourceConnectorVo{
	    public String name{get;set;}
	    
	}
}