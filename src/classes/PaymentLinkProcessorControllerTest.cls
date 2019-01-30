/**
*   @author: Mahanth Garlapati
*   @description: This is test class that covers code coverage to the 
*                 PaymentLinkProcessorController class.
**/

@isTest
private class PaymentLinkProcessorControllerTest {
	
	@testSetup static void setup() {
		List<Payment_Link__c> paymentLinkList = new List<Payment_Link__c>();
		List<Contact> contactList = new List<Contact>();

		for(Integer i = 0; i <= 30; i++){
			Contact cont = new Contact();
			cont.FirstName = 'Sony'+i;
			cont.LastName = 'Ericson'+i;
			cont.Email = 'sonyericson'+i+'@test.com';
			contactList.add(cont);
		}
		insert contactList;

		for(Integer i = 0; i <= 30; i++){
			Payment_Link__c paymentLink = new Payment_Link__c();
			paymentLink.Contact__c = contactList[i].Id;
			paymentLink.Email__c = contactList[i].Email;
			paymentLink.Link_Sent_Date__c = Date.today().addDays(-i);
			paymentLink.Payment_Link__c = 'https://cssdev4-mynct.cs100.force.com/apex/phstr__stripecheckout?failureRedirectURL=https%253A%252F%252Ftestdeploy-mynct.cs100.force.com%252FnctMembershipPaymentPage%252FnctPaymentHubErrorMsgPage&id=a2b1x0000004jJRAAY&successRedirectURL=https%253A%252F%252Ftestdeploy-mynct.cs100.force.com%252FnctMembershipPaymentPage%252FnctPaymentHubSuccessMsgPage%253FcontId%253D0031x000007rsQoAAI';
			paymentLinkList.add(paymentLink);
		}
		insert paymentLinkList;
	}
	
	@isTest static void testActivePaymentLink() {
		List<Payment_Link__c> paymentLinkList = [ 
                                                    SELECT 
                                                        Payment_Link__c,
                                                        Id,
                                                        Link_Status__c 
                                                    FROM 
                                                        Payment_Link__c 
                                                    WHERE 
                                                        Link_Status__c='Active' 
                                                ];
		Test.StartTest(); 
		ApexPages.currentPage().getParameters().put('paymentId', paymentLinkList[0].Id);
		PaymentLinkProcessorController paymentLinkProcessor = new PaymentLinkProcessorController();		
		PageReference pg = 	paymentLinkProcessor.redirect();
		Test.StopTest();
		System.assertNotEquals(null, pg);
		System.AssertEquals(pg.getUrl(), paymentLinkList[0].Payment_Link__c);										
	}
	
	@isTest static void testExpiredPaymentLink() {
		
				List<Payment_Link__c> paymentLinkList = [ 
                                                    		SELECT 
                                                        		Payment_Link__c,
                                                        		Id,
                                                        		Link_Status__c 
                                                    		FROM 
                                                        		Payment_Link__c 
                                                    		WHERE 
                                                        		Link_Status__c='Expired' 
                                                		];

		Test.StartTest(); 
		ApexPages.currentPage().getParameters().put('paymentId', paymentLinkList[0].Id); 
		PaymentLinkProcessorController paymentLinkProcessor = new PaymentLinkProcessorController();		
		PageReference pg = 	paymentLinkProcessor.redirect();
		Test.StopTest();
		System.assertEquals(null, pg);
										
	}
}