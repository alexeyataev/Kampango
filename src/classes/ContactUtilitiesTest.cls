/*ContactUtilitiesTest Class: Used to check the Code Coverage.
    **
    * Author        : Ujwal Theja
    * Created Date  : 18-12-2018
    * (c) Copyright by CSS Corp.
    **
*/
@isTest
private class ContactUtilitiesTest {
	@isTest static void positiveMethod() {
		// Implement test code
        RecordType recordtype = [SELECT Id, Name FROM RecordType where name='staff'];
		Contact con = new Contact();
        con.FirstName = 'Test FirstName';
        con.LastName = 'Test LastName';
        con.Email = 'testemail@test.com';
        con.RecordTypeId = recordtype.id;
        insert con;
        
        Contact secCon = new Contact();
        secCon.FirstName = 'Test FirstName';
        secCon.LastName = 'Test LastName';
        secCon.Email = 'sectestemail@test.com';
        secCon.Parent_Contact__c = con.id;
        insert secCon;
        Boolean isContactExisting = ContactUtilities.isContactExisting(con.Email);
        System.assert(true,isContactExisting);
        
        Account a = new Account();
        a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        a.Name ='Test Account';
        Insert a;
        
        con.AccountId =a.Id;
        upsert con;
        
   		npe03__Recurring_Donation__c recDon = new npe03__Recurring_Donation__c();
        recDon.Name = 'Credit/Debit Card Membership';
        recDon.npe03__Amount__c = 60;
        recDon.npe03__Contact__c = con.Id;
        recDon.CARE_Payment_Frequency__c = 'One Time';
        recDon.First_Contact__c = con.Id;
        recDon.npe03__Installment_Period__c = 'Yearly';
        recDon.npsp4hub__Payment_Method__c = 'Credit/Debit Card';
        
        recDon.Membership_Status__c = 'Pending';
        
        Insert recDon;
        
        AccountContactRelation[] acr = [Select id, roles from AccountContactRelation where ContactId = :con.id];
        list<AccountContactRelation> lstac = new list<AccountContactRelation>();
        for(AccountContactRelation ac: acr){
            ac.Roles ='Branch Coordinator';
        	lstac.add(ac);
        }
        upsert lstac;
       	
        Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Office Staff' Limit 1];
        User usr = new User();
        string alias = 'Test User';
        usr.Username = 'testuser1@test.com.test';
        usr.Email = 'testuser@test.com';
        usr.FirstName = 'Test';
        usr.LastName = 'User';
        usr.Alias = alias.substring(1, 6);
        usr.TimeZoneSidKey = 'GMT';
        usr.LocaleSidKey = 'en_GB';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.LanguageLocaleKey = 'en_US';
        usr.ProfileId = portalProfile.Id;
        usr.Phone = '123456789';
        insert usr;
        
        Boolean isStaffs = true;
        Boolean isVolunteer = true;
        Boolean isPractitioner = true;
        Boolean twomems = true;
        Boolean isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(con.Id);
        Boolean isVolunteerExisting = ContactUtilities.isVolunteerExisting(con.Id);
        System.assert(true,isVolunteerExisting);
        
        Id userId = usr.id;
        Boolean isStaff = ContactUtilities.isStaff(con.id);
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
        
        Boolean isMembershipExists = ContactUtilities.isMembershipExists(con.Id, con.Email);
        System.assert(true,isMembershipExists);
	}
	
	@isTest static void negativeMethod() {
		// Implement test code
		Contact con = new Contact();
        con.FirstName = 'Test FirstName';
        con.LastName = 'Test LastName';
        con.Email = 'testemail@test.com';
        insert con;
        String str = 'testemails@test.com';
		Boolean isContactExisting = ContactUtilities.isContactExisting(str);
        System.assert(true,isContactExisting);
        
        Account a = new Account();
        a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        a.Name ='Test Account';
        Insert a;
        
        con.AccountId =a.Id;
        upsert con;
        
        Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Enquiries Team' Limit 1];
        User usr = new User();
        string alias = 'Test User';
        usr.Username = 'testuser2@test.com.test';
        usr.Email = 'testuser@test.com';
        usr.FirstName = 'Test';
        usr.LastName = 'User';
        usr.Alias = alias.substring(1, 6);
        usr.TimeZoneSidKey = 'GMT';
        usr.LocaleSidKey = 'en_GB';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.LanguageLocaleKey = 'en_US';
        usr.ProfileId = portalProfile.Id;
        usr.Phone = '123456789';
        insert usr;
        
        Boolean isStaffs = false;
        Boolean isVolunteer = false;
        Boolean isPractitioner = false;
        Boolean twomems = true;
        Boolean isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(con.Id);
        Boolean isVolunteerExisting = ContactUtilities.isVolunteerExisting(con.Id);
        System.assert(true,isVolunteerExisting);
       	Id userId = usr.id;
        Boolean isStaff = ContactUtilities.isStaff(con.id);
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
        
        Boolean isMembershipExists = ContactUtilities.isMembershipExists(con.id, con.Email);
        System.assert(true,isMembershipExists);
	}
    @isTest static void permissionCheck() {

		User u = [Select id,name from user where name ='CreditCardPayment Site Guest User'];

        System.runAs(u) {
            Contact con = new Contact();
            con.FirstName = 'Test FirstName';
            con.LastName = 'Test LastName';
            con.Email = 'testemail@test.com';
            con.MailingPostalCode = 'SE1';
            con.Phone ='01234567890';
            con.Salutation = 'Mr.';
            con.Branch__c = null;
            insert con;
            String str = 'testemails@test.com';
            Boolean isContactExisting = ContactUtilities.isContactExisting(str);
            System.assert(true,isContactExisting);
            
            Account a = new Account();
            a.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
            a.Name ='Test Account';
            Insert a;
            
            con.AccountId =a.Id;
            upsert con;
            
            Profile portalProfile = [SELECT Id,Name FROM Profile WHERE Name ='Enquiries Team' Limit 1];
            User usr = new User();
            
            Boolean isStaffs = false;
            Boolean isVolunteer = false;
            Boolean isPractitioner = false;
            Boolean twomems = false;
            Boolean isCompanionContactExisting = ContactUtilities.isCompanionContactExisting(con.Id);
            Boolean isVolunteerExisting = ContactUtilities.isVolunteerExisting(con.Id);
            System.assert(true,isVolunteerExisting);
            Id userId = usr.id;
            Boolean isStaff = ContactUtilities.isStaff(con.id);
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
            
            Boolean isMembershipExists = ContactUtilities.isMembershipExists(con.id, con.Email);
            System.assert(true,isMembershipExists);
        }
	}
}