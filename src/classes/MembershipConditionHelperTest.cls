@isTest
private class MembershipConditionHelperTest {
    @testSetup static void setup() {
        
        Account acc = new Account();  
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        acc.Name ='Test Branch';
        insert acc;
        List<Contact> contact = new List<Contact>();
        for(Integer i=0;i<2;i++){
            contact.add(new Contact(
           	Branch__c = acc.id, 
            MailingStreet = 'Test address',
            MailingState = 'Test State',
            MailingCity = 'Test City',
            Prefered_First_Name__c = 'Test FirstName',
            FirstName = 'Childs',
            LastName = 'Test LastName',
            Email = 'testemail@test.com',
            Phone = '123456789',
            MailingPostalCode = 'SW123',
            salutation = 'Mr',
            Gender__c = 'Male'));
        }
        insert contact;
        System.debug('contact:'+contact);
        List<Contact> secondContact = new List<Contact>();
        for(Integer j=0;j<2;j++){
            secondContact.add(new Contact(
            LastName = 'NCT CHild'+j+j,
            FirstName = 'Childs'+j+j,
            Phone = '01234567890',
            Email = 'nctchild4555'+j+j+'@gmail.com',
            Parent_Contact__c = contact[j].id));
        }
        insert secondContact;
    }
    @isTest static void positioveConditionChecks(){
      	Boolean twomems = true;
        String email = 'test@examole.com';
        List<Contact> con = [Select id, Name,FirstName, Email from Contact where FirstName = 'Childs'];
        MembershipConditionHelper.companionCheck(twomems);
        MembershipConditionHelper.contactFinder(con[0].Id, email);
        system.assertEquals('Childs',con[0].FirstName);
    }
    @isTest static void negativeConditionChecks(){
        Boolean twomems = false;
        String email = 'testemail@test.com';
    
        List<Contact> primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,Contact_Prefrence__c,Prefered_First_Name__c,AccountId,Expected_Due_Date__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Branch__r.Name,Branch__c FROM Contact where FirstName = 'Childs'];        
        Database.Error duplicateError1;
        MembershipConditionHelper.companionCheck(twomems);
        MembershipConditionHelper.contactFinder(null, email);  
        MembershipConditionHelper.duplicateFinder(duplicateError1);

        MembershipConditionHelper.assignBranchValues(primaryContact[0].Branch__c);
        system.assertEquals('Test LastName',primaryContact[0].LastName);
    }
    @isTest static void duplicateCheck(){
        Boolean twomems = false;
        String email = 'testemail@test.com';
    
        List<Contact> primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,Contact_Prefrence__c,Prefered_First_Name__c,AccountId,Expected_Due_Date__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Branch__r.Name,Branch__c FROM Contact where FirstName = 'Childs'];        
        Contact con1 = new Contact();
        con1.Branch__c = primaryContact[0].AccountId; 
        con1.MailingStreet = 'Test address';
        con1.MailingState = 'Test State';
        con1.MailingCity = 'Test City';
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
        
         List<Contact> primaryContact = [SELECT Id,Salutation,DoNotCall, SMS_Opt_In__c, Post_Opt_In__c, HasOptedOutOfEmail,Gender__c, LastName, FirstName, Email, Phone,Contact_Prefrence__c,Prefered_First_Name__c,AccountId,Expected_Due_Date__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Branch__r.Name,Branch__c FROM Contact where FirstName = 'Childs'];
        System.runAs(u) {
                
        MembershipConditionHelper.contactFinder(primaryContact[0].Id, email);
        system.assertEquals('Childs',primaryContact[0].FirstName);
        }
    }
}