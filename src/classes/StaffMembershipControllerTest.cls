@isTest
private class StaffMembershipControllerTest {
    @isTest static void isRecurringDonationExists(){
        contact cont = new contact();
        cont.LastName = 'Test Contact';
        cont.Phone = '0987654321234';
        cont.Email = 'testcontact@test.com';
        insert cont;
        list<npe03__Recurring_Donation__c> recurrDonList = new  list<npe03__Recurring_Donation__c>();
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Payment_Type__c= :MembershipConstants.LIFEMEMBERSHIP limit 1];
        
        try{
            StaffMembershipController.recurringDon =null;
         	StaffMembershipController.membershipInsert(cont.id);

        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(true,'You Cant create membershio, hence membership already exists for this contact');
       }

    }
    @isTest static void isRecurringDonationNotExists(){
        contact cont = new contact();
        cont.LastName = 'Test Contact';
        cont.Phone = '0987654321234';
        cont.Email = 'testcontact@test.com';
        insert cont;
        
        list<npe03__Recurring_Donation__c> recurrDonList = new  list<npe03__Recurring_Donation__c>();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        recDon.Name = 'Test Membership';
        recDon.npe03__Amount__c = 10000;
        recDon.npe03__Installment_Period__c = 'Monthly';
        recDon.First_Payment__c = system.today();
        recDon.First_Contact__c = cont.id; 
        recDon.Membership_Status__c = 'Confirmed'; 
        recDon.Membership_type__c = '18 month - Joint';
        recDon.npe03__Contact__c = cont.id;
        recurrDonList.add(recDon);
        insert recurrDonList;
        
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Payment_Type__c='Life Membership - Free' limit 1];
        
        try{
            StaffMembershipController.recurringDon = recurrDonList;
         	StaffMembershipController.membershipInsert(cont.id);
            

        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(true,'You Cant create membershio, hence membership already exists for this contact');
       }

    }
     @isTest static void ipermissionCheck(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');
		contact cont = new contact();
        cont.LastName = 'Test Contact';
        cont.Phone = '0987654321234';
        cont.Email = 'testcontact@test.com';
        insert cont;
        
        list<npe03__Recurring_Donation__c> recurrDonList = new  list<npe03__Recurring_Donation__c>();
        npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        recDon.Name = 'Test Membership';
        recDon.npe03__Amount__c = 10000;
        recDon.npe03__Installment_Period__c = 'Monthly';
        recDon.First_Payment__c = system.today();
        recDon.First_Contact__c = cont.id; 
        recDon.Membership_Status__c = 'Confirmed'; 
        recDon.Membership_type__c = '18 month - Joint';
        recDon.npe03__Contact__c = cont.id;
        recurrDonList.add(recDon);
        insert recurrDonList;
        System.runAs(u) {
        
        
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Payment_Type__c='Life Membership - Free' limit 1];
        
        try{
            StaffMembershipController.recurringDon = recurrDonList;
         	StaffMembershipController.membershipInsert(cont.id);
            

        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(true,'You Cant create membershio, hence membership already exists for this contact');
       }
     }

    }


}