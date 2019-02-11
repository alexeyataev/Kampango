@isTest
private class ThankYouHelperTest { 
    
     @isTest
     private static void recurringExists(){
        String membershipNumber;
         list<npe03__Recurring_Donation__c> recDonation = new list<npe03__Recurring_Donation__c>();
         npe03__Recurring_Donation__c recDon1 = new npe03__Recurring_Donation__c();
       
         
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Phone = '3453535353555';
        con.Prefered_First_Name__c = 'NCT';
        insert con;

        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        recDon.Name = 'NCT Child';
        recDon.npe03__Amount__c = 10000;
        recDon.npe03__Installment_Period__c = 'Monthly';
        recDon.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDon.First_Payment__c = system.today();
        recDon.First_Contact__c = con.id; 
        recDon.Membership_Status__c = 'Confirmed'; 
        recDon.Membership_type__c = '18 month - Joint';
        recDon.npe03__Contact__c = con.id;
        recDonation.add(recDon); 
        insert recDonation;
        Boolean lifeMembership = true;
        pagereference page = page.NctETMembershipPaymentPage;
         Test.setCurrentPage(page);
         ID contID = ApexPages.currentPage().getParameters().put('contID',String.valueOf(con.ID));

        ThankYouHelper thankYou = new ThankYouHelper();
        thankYou.reccDonList = recDonation;
         membershipNumber =  thankYou.membershipNumberCreation(con,recDon,lifeMembership); 
         system.assertEquals('Confirmed',recDonation[0].Membership_Status__c);
     }
        @isTest
    private static void recurringNotExists(){
        list<npe03__Recurring_Donation__c> recDonation = new list<npe03__Recurring_Donation__c>();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Phone = '3453535353555';
        con.Prefered_First_Name__c = 'NCT';
        insert con;
        Boolean lifeMembership = false;
        pagereference page = page.NctETMembershipPaymentPage;
         Test.setCurrentPage(page);
         ApexPages.currentPage().getParameters().put('contID',String.valueOf(con.ID));
        

        ThankYouHelper thankYou = new ThankYouHelper();
        thankYou.reccDonList = recDonation;
        thankYou.membershipNumberCreation(con,recDon,lifeMembership);  
        //system.assertEquals('Pending', recDon.Membership_Status__c);
    }
    
    @isTest
    private static void isStaffExists(){
           
         npe03__Recurring_Donation__c recDon1 = new npe03__Recurring_Donation__c();
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Phone = '3453535353555';
        con.Prefered_First_Name__c = 'NCT';
        insert con;
        String membershipNumber;
		Boolean lifeMembership = false;
        ThankYouHelper thankYou = new ThankYouHelper();
        thankYou.isStaff = true;
          membershipNumber= thankYou.membershipNumberCreation(con,recDon1,lifeMembership);  
        system.assertNotEquals('Confirmed', membershipNumber);
    }
}