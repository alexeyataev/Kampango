@isTest
private class ThankYouHelperTest {   
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
                npe03__Contact__c = firstContact[j].id
            ));
        }
        insert recDonation;
    } 
    @isTest static void recurringExists(){
         String membershipNumber;
         Membership_Type__mdt membershipDetails;
        List<npe03__Recurring_Donation__c> recDonation = [Select id,Membership_Status__c, Name from npe03__Recurring_Donation__c where Name = 'NCT Childs'];
        recDonation[0].Membership_Status__c ='Confirmed';
        upsert recDonation;
        List<Contact> firstContact = [Select id, Name from Contact where phone='09876543212'];
        Test.startTest();
        pagereference page = page.NctETMembershipPaymentPage;
        Test.setCurrentPage(page);
        ID contID = ApexPages.currentPage().getParameters().put('contID',String.valueOf(firstContact[0].ID));
        membershipNumber =  ThankYouHelper.membershipNumberCreation(firstContact[0],recDonation[0]); 
        system.assertEquals('Confirmed',recDonation[0].Membership_Status__c);
        Test.stopTest();
     }
     @isTest static void recurringNotExists(){

        List<npe03__Recurring_Donation__c> recDonation = [Select id,Membership_Status__c, Name from npe03__Recurring_Donation__c where Name = 'NCT Childs'];
        recDonation[0].Membership_Status__c ='Confirmed';
        upsert recDonation;
      	List<Contact> firstContact = [Select id, Name from Contact where phone='09876543212'];

        Membership_Type__mdt membershipDetails;
        Test.startTest();
        pagereference page = page.NctETMembershipPaymentPage;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('contID',String.valueOf(firstContact[0].ID));
        
        ThankYouHelper.reccDonList = recDonation;
        ThankYouHelper.membershipNumberCreation(firstContact[0],recDonation[0]);  
        system.assertEquals('Confirmed', recDonation[0].Membership_Status__c);
        Test.stopTest();
    }
    
    @isTest
    private static void isStaffExists(){
           
         npe03__Recurring_Donation__c recDon1 = new npe03__Recurring_Donation__c();
        npe03__Recurring_Donation__c recDonation = new npe03__Recurring_Donation__c();
        List<Contact> firstContact = [Select id, Name from Contact where phone='09876543212'];
        Membership_Type__mdt membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c, No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c,GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt WHERE 
													Payment_Type__c='Life Membership - Free' limit 1];
        
        String membershipNumber;
		Test.startTest();
        ThankYouHelper thankYou = new ThankYouHelper();
        membershipNumber = ThankYouHelper.membershipNumberCreation(firstContact[0],recDon1);  
        system.assertNotEquals('Confirmed', membershipNumber);
        Test.stopTest();
    }
    @isTest static void permissionCheck(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');
        List<Contact> firstContact = [Select id, Name from Contact where phone='09876543212'];
        System.runAs(u) {
            list<npe03__Recurring_Donation__c> recDonation = new list<npe03__Recurring_Donation__c>();
            npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
            
            Membership_Type__mdt membershipDetails;
            Test.startTest();
            pagereference page = page.NctETMembershipPaymentPage;
            Test.setCurrentPage(page);
            ApexPages.currentPage().getParameters().put('contID',String.valueOf(firstContact[0].ID));
            
            ThankYouHelper.reccDonList = recDonation;
            ThankYouHelper.membershipNumberCreation(firstContact[0],recDon); 
            system.assertEquals(null, recDon.Membership_Status__c);
            Test.stopTest();
        }
    }
    @isTest static void recurringExistsNegativeTesting(){
         String membershipNumber;
         Membership_Type__mdt membershipDetails;

        List<npe03__Recurring_Donation__c> recDonation = [Select id,Membership_Status__c, Name from npe03__Recurring_Donation__c where Name = 'NCT Childs'];
        List<Contact> firstContact = [Select id, Name from Contact where phone='09876543212'];
        Test.startTest();
        pagereference page = page.NctETMembershipPaymentPage;
        Test.setCurrentPage(page);
        ID contID = ApexPages.currentPage().getParameters().put('contID',String.valueOf(firstContact[0].ID));
        membershipNumber =  ThankYouHelper.membershipNumberCreation(firstContact[0],recDonation[0]); 
        system.assertEquals('Pending',recDonation[0].Membership_Status__c);
        Test.stopTest();
     }
    
}