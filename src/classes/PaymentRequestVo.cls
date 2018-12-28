global with sharing class PaymentRequestVo {
    
    global String successURL{get;set;}
    global String failureURL{get;set;}
    global String origin{get;set;}
    global PayerVo payer{get;set;}
    global PaymentVo payment{get;set;}
    global PaymentMethodVo paymentMethod{get;set;}
    global SourceConnectorVo sourceConnector{get;set;}
    
    
    	//Assessment Vo
	global class PayerVo{
	    global Boolean allowDeduplication{get;set;}
		global ContactVo contact{get;set;}
		global String contactUpdate{get;set;}
	}
    
	global class PaymentVo{
	    global Decimal amount{get;set;}
	}

	global class ContactVo{
	    global String email{get;set;}
	    global String firstName{get;set;}
	    global String lastName{get;set;}
	}

	global class PaymentMethodVo{
	    global String name{get;set;}
	}

	global class SourceConnectorVo{
	    global String name{get;set;}
	}
}