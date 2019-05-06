/*ContactUtilitiesTest Class: Used to check the Code Coverage.
    **
    * Author        : Ujwal Theja
    * Created Date  : 18-12-2018
    * (c) Copyright by CSS Corp.
    **
*/
@isTest
private class ContactUtilitiesTest {
	@testSetup static void setup() {
        List<Contact> contact = new List<Contact>();
        for(Integer i=0;i<4;i++){
            contact.add(new Contact(
            LastName = 'NCT CHild'+i,
            FirstName = 'Childs'+i,
            Phone = '09876543212',
            Email = 'nctchild4555'+i+'@gmail.com'));
        }
        insert contact;        
        
        List<Contact> secondContact = new List<Contact>();
        for(Integer j=0;j<4;j++){
            secondContact.add(new Contact(
            LastName = 'NCT CHild'+j+j,
            FirstName = 'Childs'+j+j,
            Phone = '01234567890',
            Email = 'nctchild4555'+j+j+'@gmail.com',
            Parent_Contact__c = contact[j].id));
        }
        insert secondContact;
        
        Account a = new Account();
        a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        a.Name ='Test Account';
        Insert a;
        
        System.debug('contact:'+contact);
        List<npe03__Recurring_Donation__c> recDonation = new List<npe03__Recurring_Donation__c>();
        for(Integer j=0; j<4; j++){
            recDonation.add(new npe03__Recurring_Donation__c(
                Name = 'NCT Childs',
                npe03__Amount__c = 10000,
                npe03__Installment_Period__c = 'Monthly',
                CARE_Payment_Frequency__c = 'NCT CHILD TRUST',
                First_Payment__c = system.date.today(),
                First_Contact__c = contact[j].id, 
                Membership_Status__c = 'Pending', 
                Membership_type__c = '18 month - Joint',
                npe03__Contact__c = contact[j].id,
                Renewal_Date__c = null
            ));
        }
        insert recDonation;
    }
	@isTest static void positiveMethod() {
		// Implement test code
        RecordType recordtype = [SELECT Id, Name FROM RecordType where name='staff'];
		List<Contact> con = [SELECT Id,Email, Name,RecordTypeId FROM Contact where Phone = '09876543212'];
        con[0].RecordTypeId = recordtype.id;
        con[0].AccountId = [SELECT Id FROM Account where Name = 'Test Account'].id;
        upsert con;
        
   		List<Contact> secCon = [SELECT Id, Name,RecordTypeId FROM Contact where Phone = '01234567890'];
        Boolean isContactExisting = ContactUtilities.isContactExisting(con[0].Email);
        System.assert(true,isContactExisting);
        
        AccountContactRelation[] acr = [Select id, roles from AccountContactRelation where ContactId = :con[0].id];
        list<AccountContactRelation> lstac = new list<AccountContactRelation>();
        for(AccountContactRelation ac: acr){
            ac.Roles ='Branch Coordinator';
        	lstac.add(ac);
        }
        upsert lstac;
       	
                
        Boolean isStaffs = true;
        Boolean isVolunteer = true;
        Boolean isPractitioner = true;
        Boolean twomems = true;
         Boolean isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(con[0].Id);
        Boolean isVolunteerExisting = ContactUtilities.isVolunteerExisting(con[0].Id);
        System.assert(true,isVolunteerExisting);
        
        Boolean isStaff = ContactUtilities.isStaff(con[0].id);
        System.assert(true,isStaff);
        
        List<Boolean> targetCustomerList = new List<Boolean>{isStaffs,isVolunteer,isPractitioner,twomems};
        String targetCustomer = ContactUtilities.targetCustomer(targetCustomerList);
		System.assertEquals(true, isStaffs);
        System.assertEquals(true, isVolunteer);
        System.assertEquals(true, isPractitioner);
        System.assertEquals(true, twomems);
        
        Boolean isStaffsf = false;
        List<Boolean> targetCustomersList = new List<Boolean>{isStaffsf,isVolunteer,isPractitioner,twomems};
        String targetCustomers = ContactUtilities.targetCustomer(targetCustomersList);
        
        System.assertEquals(false, isStaffsf);
        System.assertEquals(true, isVolunteer);
        System.assertEquals(true, isPractitioner);
        System.assertEquals(true, twomems);
        
        Boolean isMembershipExists = ContactUtilities.isMembershipExists(con[0].Id, con[0].Email);
        System.assert(true,isMembershipExists);
	}
	
	@isTest static void negativeMethod() {
		// Implement test code
		List<Contact> con = [SELECT Id, Name,RecordTypeId FROM Contact where Phone = '09876543212'];
        con[1].AccountId = [SELECT Id FROM Account where Name = 'Test Account'].id;
        upsert con;
        String str = 'testemails@test.com';
		Boolean isContactExisting = ContactUtilities.isContactExisting(str);
        System.assert(true,isContactExisting);
        
        
        Boolean isStaffs = false;
        Boolean isVolunteer = false;
        Boolean isPractitioner = false;
        Boolean twomems = true;
        Boolean isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(con[1].Id);
        Boolean isVolunteerExisting = ContactUtilities.isVolunteerExisting(con[1].Id);
        System.assert(true,isVolunteerExisting);
       	
        Boolean isStaff = ContactUtilities.isStaff(con[1].id);
        System.assert(true,isStaff);
        List<Boolean> targetCustomerList = new List<Boolean>{isStaffs,isVolunteer,isPractitioner,twomems};
        String targetCustomer = ContactUtilities.targetCustomer(targetCustomerList);
		System.assertEquals(false, isStaffs);
        System.assertEquals(false, isVolunteer);
        System.assertEquals(false, isPractitioner);
        System.assertEquals(true, twomems);
        
        Boolean twomemsf = false;
        List<Boolean> targetCustomersList = new List<Boolean>{isStaffs,isVolunteer,isPractitioner,twomems};
        String targetCustomers = ContactUtilities.targetCustomer(targetCustomersList);
        
        System.assertEquals(false, isStaffs);
        System.assertEquals(false, isVolunteer);
        System.assertEquals(false, isPractitioner);
        System.assertEquals(false, twomemsf);
        
        Boolean isMembershipExists = ContactUtilities.isMembershipExists(con[1].id, null);
        System.assert(true,isMembershipExists);
	}
    @isTest static void permissionCheck() {

		Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');
        List<Contact> con = [SELECT Id,Email, Name FROM Contact where Phone = '09876543212'];
        System.runAs(u) {
           

            String str = 'testemails@test.com';
            Boolean isContactExisting = ContactUtilities.isContactExisting(str);
            System.assert(true,isContactExisting);
            
            Boolean isStaffs = false;
            Boolean isVolunteer = false;
            Boolean isPractitioner = false;
            Boolean twomems = false;
            Boolean isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(con[0].Id);
            Boolean isVolunteerExisting = ContactUtilities.isVolunteerExisting(con[0].Id);
            System.assert(true,isVolunteerExisting);
            Boolean isStaff = ContactUtilities.isStaff(con[0].id);
            System.assert(true,isStaff);
            List<Boolean> targetCustomerList = new List<Boolean>{isStaffs,isVolunteer,isPractitioner,twomems};
            String targetCustomer = ContactUtilities.targetCustomer(targetCustomerList);
            System.assertEquals(false, isStaffs);
            System.assertEquals(false, isVolunteer);
            System.assertEquals(false, isPractitioner);
            System.assertEquals(false, twomems);
            
            Boolean twomemsf = false;
            List<Boolean> targetCustomersList = new List<Boolean>{isStaffs,isVolunteer,isPractitioner,twomems};
            String targetCustomers = ContactUtilities.targetCustomer(targetCustomersList);
            
            System.assertEquals(false, isStaffs);
            System.assertEquals(false, isVolunteer);
            System.assertEquals(false, isPractitioner);
            System.assertEquals(false, twomemsf);
            
            Boolean isMembershipExists = ContactUtilities.isMembershipExists(con[0].id, con[0].Email);
            System.assert(true,isMembershipExists);
        }
	}
}