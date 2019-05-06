@isTest
private class DirectPaymentLinkSendToParentTest 
{
    @testSetup static void setup() {
        List<Contact> contact = new List<Contact>();
        for(Integer i=0;i<2;i++){
            contact.add(new Contact(
            LastName = 'NCT CHild'+i,
            FirstName = 'Childs'+i,
            Phone = '09876543212',
            Email = 'nctchild4555'+i+'@gmail.com'));
        }
        insert contact;
        System.debug('contact:'+contact);
        List<Payment_Link__c> paymentLink = new List<Payment_Link__c>();
        for(Integer j=0; j<2; j++){
            paymentLink.add(new Payment_Link__c(
                Contact__c = contact[j].id,
        		Email__c = 'nctchil@gmail.com'
            ));
        }
        insert paymentLink;
    }
    private static testMethod void directPaymentLinkTest()
    {
         List<Contact> cont =[SELECT Id,Email, Name FROM Contact where Phone = '09876543212'];
        List<Payment_Link__c> payment = [Select id,Email__c from Payment_Link__c where Email__c='nctchil@gmail.com'];
        DirectPaymentLinkSendToParent.paymentHubCallout(cont[0].Id);        
        
        system.assertEquals('nctchil@gmail.com', payment[0].Email__c);      
    } 
    private static testMethod void permissionCheck()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        List<Contact> cont =[SELECT Id,Email, Name FROM Contact where Phone = '09876543212'];
        List<Payment_Link__c> payment = [Select id,Email__c from Payment_Link__c where Email__c='nctchil@gmail.com'];
        System.runAs(u) {
            
            DirectPaymentLinkSendToParent.paymentHubCallout(cont[0].Id);
           
            system.assertEquals('nctchil@gmail.com', payment[0].Email__c);  
        }      
    } 

}