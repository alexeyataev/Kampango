@isTest
private class ThankYouHelperTest {    
    @isTest static void recurringExists(){
         String membershipNumber;
         Membership_Type__mdt membershipDetails;

        contact con = new contact();
        con.FirstName = 'NCTChild123455';
        con.LastName = 'Trust1123445677';
        con.Email = 'nct12113331@gmail.com';
        con.Phone = '3453535353555';
        con.Prefered_First_Name__c = 'NCT';
        insert con;

        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        recDon.Name = 'NCTChild';
        recDon.npe03__Amount__c = 10000;
        recDon.npe03__Date_Established__c = System.Date.today();
        recDon.npe03__Installment_Period__c = 'Monthly';
        recDon.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDon.First_Payment__c = system.today();
        recDon.First_Contact__c = con.id; 
        recDon.Membership_Status__c = 'Confirmed'; 
        recDon.Membership_type__c = '18 month - Joint';
        recDon.npe03__Contact__c = con.id;
        insert recDon;
        Test.startTest();
        pagereference page = page.NctETMembershipPaymentPage;
        Test.setCurrentPage(page);
        ID contID = ApexPages.currentPage().getParameters().put('contID',String.valueOf(con.ID));
        ThankyouHelper.membershipDetails = membershipDetails;
        membershipNumber =  ThankYouHelper.membershipNumberCreation(con,recDon); 
        system.assertEquals('Confirmed',recDon.Membership_Status__c);
        Test.stopTest();
     }
     @isTest static void recurringNotExists(){
        list<npe03__Recurring_Donation__c> recDonation = new list<npe03__Recurring_Donation__c>();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Phone = '3453535353555';
        con.Prefered_First_Name__c = 'NCT';
        insert con;
        Membership_Type__mdt membershipDetails;
        Test.startTest();
        pagereference page = page.NctETMembershipPaymentPage;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('contID',String.valueOf(con.ID));
        
        ThankYouHelper.reccDonList = recDonation;
        ThankYouHelper.membershipNumberCreation(con,recDon);  
        system.assertEquals(null, recDon.Membership_Status__c);
        Test.stopTest();
    }
    
    @isTest
    private static void isStaffExists(){
           
         npe03__Recurring_Donation__c recDon1 = new npe03__Recurring_Donation__c();
        npe03__Recurring_Donation__c recDonation = new npe03__Recurring_Donation__c();
        contact con = new contact();
        con.FirstName = 'NCT Child';
        con.LastName = 'Trust';
        con.Email = 'nct@gmail.com';
        con.Phone = '3453535353555';
        con.Prefered_First_Name__c = 'NCT';
        insert con;
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c, No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c,GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt WHERE 
													Payment_Type__c='Life Membership - Free' limit 1];
        
        String membershipNumber;
		Test.startTest();
        ThankYouHelper thankYou = new ThankYouHelper();
        ThankYouHelper.membershipDetails = membershipDetails;
        membershipNumber = ThankYouHelper.membershipNumberCreation(con,recDon1);  
        system.assertNotEquals('Confirmed', membershipNumber);
        Test.stopTest();
    }
    @isTest static void permissionCheck(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        System.runAs(u) {
            list<npe03__Recurring_Donation__c> recDonation = new list<npe03__Recurring_Donation__c>();
            npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
            contact con = new contact();
            con.FirstName = 'NCT Child';
            con.LastName = 'Trust';
            con.Email = 'nct@gmail.com';
            con.Phone = '3453535353555';
            con.Prefered_First_Name__c = 'NCT';
            insert con;
            Membership_Type__mdt membershipDetails;
            Test.startTest();
            pagereference page = page.NctETMembershipPaymentPage;
            Test.setCurrentPage(page);
            ApexPages.currentPage().getParameters().put('contID',String.valueOf(con.ID));
            
            ThankYouHelper.reccDonList = recDonation;
            ThankYouHelper.membershipNumberCreation(con,recDon);  
            system.assertEquals(null, recDon.Membership_Status__c);
            Test.stopTest();
        }
    }
    
}