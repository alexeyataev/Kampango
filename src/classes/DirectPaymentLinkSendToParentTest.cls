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
        
        npe03__Recurring_Donation__c recurringDonation = new npe03__Recurring_Donation__c();
        recurringDonation.First_Contact__c = cont.Id;
        recurringDonation.npe03__Amount__c = 10000;
        recurringDonation.npe03__Contact__c = cont.Id;
        recurringDonation.Membership_type__c = '12 Months Standard - Individual';        
        insert recurringDonation;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        DirectPaymentLinkSendToParent.paymentHubCallout(cont.Id);
        Test.stopTest();
        system.assertEquals('12 Months Standard - Individual', recurringDonation.Membership_type__c);
        //DirectPaymentLinkSendToParent.sendPaymentLinkToParent(redirectURL);        
    } 

}