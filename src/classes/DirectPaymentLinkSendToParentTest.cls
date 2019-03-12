@isTest
private class DirectPaymentLinkSendToParentTest 
{
    private static testMethod void directPaymentLinkTest()
    {
        contact cont = new contact();
        cont.FirstName = 'NCT Child';
        cont.LastName = 'Trust';
        cont.Email = 'nct@gmail.com';
        cont.Prefered_First_Name__c = 'NCT';
        insert cont;        
        
        Payment_Link__c paymentLink = new Payment_Link__c();
        paymentLink.Contact__c = cont.id; 
        paymentLink.Email__c = 'nctchil@gmail.com';
        insert paymentLink;
        
        system.debug('payment'+paymentLink);
        
        DirectPaymentLinkSendToParent.paymentHubCallout(cont.Id);
       
        system.assertEquals('nctchil@gmail.com', paymentLink.Email__c);
        //DirectPaymentLinkSendToParent.sendPaymentLinkToParent(redirectURL);        
    } 
    private static testMethod void permissionCheck()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        System.runAs(u) {
            contact cont = new contact();
            cont.FirstName = 'NCT Child';
            cont.LastName = 'Trust';
            cont.Email = 'nct@gmail.com';
            cont.Prefered_First_Name__c = 'NCT';
            insert cont;        
            
            Payment_Link__c paymentLink = new Payment_Link__c();
            paymentLink.Contact__c = cont.id; 
            paymentLink.Email__c = 'nctchil@gmail.com';
            insert paymentLink;
            
            system.debug('payment'+paymentLink);
            
            DirectPaymentLinkSendToParent.paymentHubCallout(cont.Id);
           
            system.assertEquals('nctchil@gmail.com', paymentLink.Email__c);
            //DirectPaymentLinkSendToParent.sendPaymentLinkToParent(redirectURL);  
        }      
    } 

}