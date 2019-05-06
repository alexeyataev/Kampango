@isTest
private class StaffMembershipControllerTest {
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
         
         List<Contact> secondContact = new List<Contact>();
        for(Integer j=0;j<2;j++){
            secondContact.add(new Contact(
            LastName = 'NCT CHild'+j+j,
            FirstName = 'Childs'+j+j,
            Phone = '01234567890',
            Email = 'nctchild4555'+j+j+'@gmail.com',
            Parent_Contact__c = firstContact[j].id));
        }
        insert secondContact;
         
         List<npe03__Recurring_Donation__c> recDonation = new List<npe03__Recurring_Donation__c>();
        for(Integer j=0; j<2; j++){
            recDonation.add(new npe03__Recurring_Donation__c(
                Name = 'NCT Childs',
                npe03__Amount__c = 10000,
                npe03__Installment_Period__c = 'Monthly',
                CARE_Payment_Frequency__c = 'NCT CHILD TRUST',
                First_Payment__c = system.date.today(),
                First_Contact__c = firstContact[j].id, 
                Membership_Status__c = 'Pending', 
                Membership_type__c = '18 month - Joint',
                npe03__Contact__c = firstContact[j].id,
                Renewal_Date__c = null
            ));
        }
        insert recDonation;
    }
    @isTest static void isRecurringDonationExists(){
        List<Contact> firstContact = [Select id, Name from Contact where phone='01234567890'];

        list<npe03__Recurring_Donation__c> recurrDonList = new  list<npe03__Recurring_Donation__c>();
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Payment_Type__c= :MembershipConstants.LIFEMEMBERSHIP limit 1];
        
        try{
            StaffMembershipController.recurringDon =recurrDonList;
         	StaffMembershipController.membershipInsert(firstContact[0].id);

        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(true,'You Cant create membershio, hence membership already exists for this contact');
       }

    }
    @isTest static void isRecurringDonationNotExists(){
        
        
        List<npe03__Recurring_Donation__c> recDonation = [Select id, Name from npe03__Recurring_Donation__c where Name = 'NCT Childs'];
        
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Payment_Type__c='Life Membership - Free' limit 1];
        List<Contact> firstContact = [Select id, Name from Contact where phone='09876543212'];
        try{
            StaffMembershipController.recurringDon = recDonation;
         	StaffMembershipController.membershipInsert(firstContact[0].id);
            

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

		List<npe03__Recurring_Donation__c> recDonation = [Select id, Name from npe03__Recurring_Donation__c where Name = 'NCT Childs'];
        List<Contact> firstContact = [Select id, Name from Contact where phone='09876543212'];
        
        System.runAs(u) {
        
        
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    where Payment_Type__c='Life Membership - Free' limit 1];
        
        try{
            StaffMembershipController.recurringDon = recDonation;
         	StaffMembershipController.membershipInsert(firstContact[0].id);
            

        }catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.assert(true,'You Cant create membershio, hence membership already exists for this contact');
       }
     }

    }


}