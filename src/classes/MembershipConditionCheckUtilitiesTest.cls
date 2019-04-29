@isTest
private class MembershipConditionCheckUtilitiesTest {
    @testSetup static void setup() {
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        acc.Name ='Test Branch';
        insert acc;
        List<Contact> contact = new List<Contact>();
        for(Integer i=0;i<2;i++){
            contact.add(new Contact(
            LastName = 'NCT CHild'+i,
            FirstName = 'Childs'+i,
            Phone = '09876543212',
            Branch__c = acc.Id,
            Email = 'nctchild4555'+i+'@gmail.com'));
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
    @isTest
	   static void  receiveInputPermission(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        List<Contact> contact =[Select id, Name,LastName from Contact where Phone ='09876543212'];
            List<Contact> secondContact =[Select id, Name, LastName from Contact where Phone ='01234567890'];
        System.runAs(u) {
            
            Boolean twomems = true;
            Id primaryContactId = contact[0].id;
                String secondContactFirstName = 'Childs';
            Boolean isContactExisting = false;
            Contact primaryContact = null;
            Id contId = contact[0].Id;
            String eDate = '';
            Test.startTest();
           pagereference page = page.NctETMembershipPaymentPage;
            Test.setCurrentPage(page);
            ApexPages.currentPage().getParameters().put('contID',String.valueOf(contact[0].ID));
                MembershipConditionCheckUtilities.receiveInputSecondContactPermissionCheck(true, contact[0].Id, secondContactFirstName);
            MembershipConditionCheckUtilities.isNotExistingContactCheck(false, null);
            MembershipConditionCheckUtilities.receiveInputPermissionCheck();   
            MembershipConditionCheckUtilities.isExistingContactCheck(contact[0].Id, true);
            MembershipConditionCheckUtilities.dateFormatCheck(eDate);
            MembershipConditionCheckUtilities.secondContactRequiredCheck(true, contact[0].Id, secondContactFirstName);
                system.assertEquals('NCT CHild00', secondContact[0].LastName);
            Test.stopTest(); 
                }
       } 
     @isTest
	   static void  contactNotExists(){
           contact con = new contact();
           Boolean twomems = true;
            Id primaryContactId = con.id;
            String secondContactFirstName = 'NCT Customer';
           MembershipConditionCheckUtilities.secondContactRequiredCheck(true, con.Id, secondContactFirstName);
           system.assertEquals('NCT Customer', secondContactFirstName);
           system.assertEquals(null, con.Id);
       } 
     
    
}