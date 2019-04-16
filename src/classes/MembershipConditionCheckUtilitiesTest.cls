@isTest
private class MembershipConditionCheckUtilitiesTest {
    @isTest
	   static void  receiveInputPermission(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        System.runAs(u) {
            Account acc = new Account();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
            acc.Name ='Test Branch';
            insert acc;
            contact con = new contact();
            
            con.Branch__c = acc.id; 
            con.MailingStreet = 'Test address';
            con.MailingState = 'Test State';
            con.MailingCity = 'Test City';
            con.Prefered_First_Name__c = 'Test FirstName';
            con.FirstName = 'Childs';
            con.LastName = 'Test LastName';
            con.Email = 'testemail@test.com';
            con.Phone = '123456789';
            con.MailingPostalCode = 'SW123';
            con.salutation = 'Mr';
            con.Gender__c = 'Male';
            insert con;
            
            
            contact scon = new contact();
            scon.Branch__c = acc.id; 
            scon.MailingStreet = 'Test address1';
            scon.MailingState = 'Test State1';
            scon.MailingCity = 'Test City1';
            scon.Prefered_First_Name__c = 'Test FirstName1';
            scon.FirstName = 'Childs1';
            scon.LastName = 'Test LastName1';
            scon.Email = 'testemaily@test.com';
            scon.Parent_Contact__c = con.Id;
            insert scon;
            
            Boolean twomems = true;
            Id primaryContactId = con.id;
            String secondContactFirstName = 'chintu';
            Boolean isContactExisting = false;
            Contact primaryContact = null;
            Id contId = con.Id;
            String eDate = '';
            Test.startTest();
           pagereference page = page.NctETMembershipPaymentPage;
            Test.setCurrentPage(page);
            ApexPages.currentPage().getParameters().put('contID',String.valueOf(con.ID));
            MembershipConditionCheckUtilities.receiveInputSecondContactPermissionCheck(true, con.Id, secondContactFirstName);
            MembershipConditionCheckUtilities.isNotExistingContactCheck(false, null);
            MembershipConditionCheckUtilities.receiveInputPermissionCheck();   
			MembershipConditionCheckUtilities.isExistingContactCheck(con.Id, true);
            MembershipConditionCheckUtilities.dateFormatCheck(eDate);
            MembershipConditionCheckUtilities.secondContactRequiredCheck(true, con.Id, secondContactFirstName);
            system.assertEquals('Test LastName1', scon.LastName);
            Test.stopTest(); 
                }
       } 
     @isTest
	   static void  contactNotExists(){
           contact con = new contact();
           Boolean twomems = true;
            Id primaryContactId = con.id;
            String secondContactFirstName = 'chintu';
           MembershipConditionCheckUtilities.secondContactRequiredCheck(true, con.Id, secondContactFirstName);
           system.assertEquals('chintu', secondContactFirstName);
           system.assertEquals(null, con.Id);
       } 
     
    
}