@isTest
private class PaymentHubCalloutUtilitiesTest {
    @isTest 
    private static void paymentHubCallContactExists(){
        contact cont = new contact();
        cont.FirstName = 'NCT Child';
        cont.LastName = 'Trust';
        cont.Email = 'nct@gmail.com';
        cont.Prefered_First_Name__c = 'NCT';
        insert cont; 
        
        list<String> contactDetails = new list<String>();
          
        PaymentHubApiSettings__c PaymentHubApiSettings = new PaymentHubApiSettings__c();
        PaymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        PaymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert PaymentHubApiSettings; 
     
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt where  Payment_Method__c='Credit/Debit Card' limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PaymentHubCalloutUtilities.paymentHub(cont,membershipDetails,contactDetails);    
        Test.stopTest();
        system.assertEquals('Credit/Debit Card',membershipDetails.Payment_Method__c );
        
    }
    @isTest 
    private static void paymentHubCallContactNotExists(){
        contact con = new contact();
        
         
        String FirstName = 'NCT Child';
        String LastName = 'Trust';
        String Email = 'nct@gmail.com';
        
        
        list<String> contactDetails = new list<String>();
        contactDetails.add(Email);
        contactDetails.add(FirstName);
        contactDetails.add(LastName);
          
        PaymentHubApiSettings__c PaymentHubApiSettings = new PaymentHubApiSettings__c();
        PaymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        PaymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert PaymentHubApiSettings; 
 

        
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt where Payment_Method__c='Credit/Debit Card' limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PaymentHubCalloutUtilities.paymentHub(con,membershipDetails,contactDetails); 
        Test.stopTest();
        system.assertEquals('Credit/Debit Card',membershipDetails.Payment_Method__c );
    }

}