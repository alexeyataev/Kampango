public with sharing class PaymentRequestVo {
    
    public String successURL{get;set;}
    public String failureURL{get;set;}
    public String origin{get;set;}
    public PayerVo payer{get;set;}
    public PaymentVo payment{get;set;}
    public PaymentMethodVo paymentMethod{get;set;}
    public SourceConnectorVo sourceConnector{get;set;}
    
    
    	//Assessment Vo
	public class PayerVo{
	    public Boolean allowDeduplication{get;set;}
		public ContactVo contact{get;set;}
		public String contactUpdate{get;set;}
	}
    
	public class PaymentVo{
	    public Decimal amount{get;set;}
	}

	public class ContactVo{
	    public String email{get;set;}
	    public String firstName{get;set;}
	    public String lastName{get;set;}
	}

	public class PaymentMethodVo{
	    public String name{get;set;}
	}

	public class SourceConnectorVo{
	    public String name{get;set;}
	    public String name{get;set;}
	}
}