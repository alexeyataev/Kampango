global with sharing class PaymentRequestVo {
    
    global String SuccessURL{get;set;}
    global String FailureURL{get;set;}
    global String Origin{get;set;}
    global PayerVo Payer{get;set;}
    global PaymentVo Payment{get;set;}
    global PaymentMethodVo PaymentMethod{get;set;}
    global SourceConnectorVo SourceConnector{get;set;}
    
    
    	//Assessment Vo
	global class PayerVo{
	    global Boolean AllowDeduplication{get;set;}
		global ContactVo contact{get;set;}
		global String ContactUpdate{get;set;}
	}
    
	global class PaymentVo{
	    global Decimal Amount{get;set;}
	}

	global class ContactVo{
	    global String Email{get;set;}
	    global String FirstName{get;set;}
	    global String LastName{get;set;}
	}

	global class PaymentMethodVo{
	    global String Name{get;set;}
	}

	global class SourceConnectorVo{
	    global String Name{get;set;}
	}
}