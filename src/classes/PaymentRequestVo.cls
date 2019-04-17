public with sharing class PaymentRequestVo {
    private static PaymentHubApiSettings__c paymentHubApiSettings = PaymentHubApiSettings__c.getInstance();
    public String successURL{get;set;}
    String failureURL = paymentHubApiSettings.Payment_Status_Root_Url__c +'/nctPaymentHubErrorMsgPage';
    String origin ='test';
    public PayerVo payer{get;set;}
    public PaymentVo payment{get;set;}
    public PaymentMethodVo paymentMethod{get;set;}
    public SourceConnectorVo sourceConnector{get;set;}
    
    
    	//Assessment Vo
	public class PayerVo{
	    Boolean allowDeduplication =true;
		public ContactVo contact{get;set;}
		String contactUpdate ='replace';
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
	    String name = 'CreditCard';
	}

	public class SourceConnectorVo{
	    String name = 'PaymentHub';
	    
	}
}