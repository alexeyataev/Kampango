@isTest
private class MembershipConditionHelperTest {
    @isTest static void positioveConditionChecks(){
      Boolean twomems = true;
        String email = 'test@examole.com';
        Account acc = new Account();  
        acc.Name ='Test Branch';
        insert acc;
        
        Contact con = new Contact();
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
 
        MembershipConditionHelper.companionCheck(twomems);
        MembershipConditionHelper.contactFinder(con.Id, email);
        system.assertEquals('Childs',con.FirstName);
    }
    @isTest static void negativeConditionChecks(){
        Boolean twomems = false;
        String email = 'testemail@test.com';
        Account acc = new Account();  
        acc.Name ='Test Branch';
        insert acc;
        
        Contact con = new Contact();
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
        
        contact primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,Contact_Prefrence__c,Prefered_First_Name__c,AccountId,Expected_Due_Date__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Branch__r.Name,Branch__c FROM Contact where id=:con.Id];        
        Contact con1 = new Contact();
        con1.Branch__c = acc.id; 
        con1.MailingStreet = 'Test address';
        con1.MailingState = 'Test State';
        con.MailingCity = 'Test City';
        con1.Prefered_First_Name__c = 'Test FirstName';
        con1.FirstName = 'Childs';
        con1.LastName = 'Test LastName';
        con1.Email = 'testemail@test.com';
        con1.Phone = '123456789';
        con1.MailingPostalCode = 'SW123';
        con1.salutation = 'Mr';
        con1.Gender__c = 'Male';
    
        Database.Error duplicateError1;
        MembershipConditionHelper.companionCheck(twomems);
        MembershipConditionHelper.contactFinder(null, email);  
        MembershipConditionHelper.duplicateFinder(duplicateError1);

        MembershipConditionHelper.assignBranchValues(primaryContact.Branch__c);
        system.assertEquals('Test LastName',con1.LastName);
    }
    @isTest static void duplicateCheck(){
        Boolean twomems = false;
        String email = 'testemail@test.com';
        Account acc = new Account();  
        acc.Name ='Test Branch';
        insert acc;
        
        Contact con = new Contact();
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
        
        Contact con1 = new Contact();
        con1.Branch__c = acc.id; 
        con1.MailingStreet = 'Test address';
        con1.MailingState = 'Test State';
        con.MailingCity = 'Test City';
        con1.Prefered_First_Name__c = 'Test FirstName';
        con1.FirstName = 'Childs';
        con1.LastName = 'Test LastName';
        con1.Email = 'testemail@test.com';
        con1.Phone = '123456789';
        con1.MailingPostalCode = 'SW123';
        con1.salutation = 'Mr';
        con1.Gender__c = 'Male';
        Database.Saveresult res = Database.Insert(con1,false);       
        MembershipConditionHelper.saveResultCheck(res);
         for(Database.Error duplicateError : res.getErrors()){
            MembershipConditionHelper.duplicateFinder(duplicateError);
        }
        system.assertEquals('Test LastName',con1.LastName);
    }
    @isTest static void permissionCheck(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');
        String email = 'testemail@test.com';
        System.runAs(u) {
            Account acc = new Account();  
            acc.Name ='Test Branch';
            insert acc;
            contact con = new contact();
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
        MembershipConditionHelper.contactFinder(con.Id, email);
        system.assertEquals('Childs',con.FirstName);
        }
    }
}