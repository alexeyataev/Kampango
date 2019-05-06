@isTest
private class PaymentHubCalloutUtilitiesTest {
    @testSetup static void setup() {
       Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        acc.Name ='Test Branch';
        insert acc;
        List<Contact> firstContact = new List<Contact>();
        for(Integer i=0;i<2;i++){
            firstContact.add(new Contact(
            LastName = 'NCT CHild'+i,
            FirstName = 'Childs'+i,
            Phone = '09876543212',
            Email = 'nctchild4555'+i+'@gmail.com'));
        }
        insert firstContact;
        
    }
    @isTest 
    private static void paymentHubCallContactExists(){
        List<Contact> firstContact = [Select id,FirstName,LastName,Email from Contact where Phone = '09876543212']; 
        
        PaymentRequestVo.ContactVo cvo = new PaymentRequestVo.ContactVo();
            cvo.Email = firstContact[0].Email;        
            cvo.FirstName = firstContact[0].FirstName;
            cvo.LastName = firstContact[0].LastName;
          
        PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
        paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert paymentHubApiSettings; 
     
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt where  Payment_Method__c='Credit/Debit Card' limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PaymentHubCalloutUtilities.paymentHub(firstContact[0],membershipDetails,null);      
        Test.stopTest();
        system.assertEquals('Credit/Debit Card',membershipDetails.Payment_Method__c );
        
    }
    
}