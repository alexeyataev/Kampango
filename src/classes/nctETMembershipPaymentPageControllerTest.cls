@isTest
private class NctETMembershipPaymentPageControllerTest {
    Static contact newCont;
    static Map<String, List<Membership_Type__mdt>> membershipTypeMap = new Map<String, List<Membership_Type__mdt>>();
    @isTest static void contactIdExists() {
		Account acc = new Account();
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();       
        acc.Name ='Test Branch';
        insert acc;
        Contact con = new Contact();
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        con.Branch__c = acc.id; 
        con.MailingStreet = 'Test address';
        con.MailingState = 'Test State';
        con.MailingCity = 'Test City';
        con.Prefered_First_Name__c = 'Test FirstName';
        con.LastName = 'Test LastName';
        con.Email = 'testemail@test.com';
        con.Phone = '123456789';
        con.MailingPostalCode = 'SW123';
        con.salutation = 'Mr';
        con.Gender__c = 'Male';
        insert con;
        
        PageReference pageRef = Page.nctETMembershipPaymentPage; 
        Id contId = pageRef.getParameters().put('Id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef); 
        
        
        Test.startTest();
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
        
        //controller.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        
        controller.receiveInput();
        controller.nctBranchs();
        controller.ContactInfo();
        controller.PaymentSave();
        
        Test.stopTest();
        
    }
    @isTest static void contactIdNotExists(){
        Contact cons = new Contact();
        
        Account acc = new Account();
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();       
        acc.Name ='Test Branch';
        insert acc;
        Contact con = new Contact();
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        con.Branch__c = acc.id; 
        con.MailingStreet = 'Test address';
        con.MailingState = 'Test State';
        con.MailingCity = 'Test City';
        con.Prefered_First_Name__c = 'Test FirstName';
        con.LastName = 'Test LastName';
        con.Email = 'testemail@test.com';
        con.Phone = '123456789';
        con.MailingPostalCode = 'SW123';
        con.salutation = 'Mr';
        con.Gender__c = 'Male';
        insert con;
        
        PageReference pageRef = Page.nctETMembershipPaymentPage; 
        Id contId = pageRef.getParameters().put('Id', String.valueOf(cons.Id));
        Test.setCurrentPage(pageRef); 
        
        Test.startTest();
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
        
        controller.FirstName = con.id;
        controller.LastName = con.id;
        controller.Email = con.Id;
        controller.phone = con.Id;
        controller.postCode = con.Id;
        
        controller.selectBranch = con.Id; 
        controller.salutation = con.id;
        controller.genderValue = con.id;
        controller.streetValue = con.Id;
        controller.stateValue = con.Id;
        controller.cityValue = con.Id;
        controller.newCont = con;
        
        controller.receiveInput();        
        controller.nctBranchs();
        controller.ContactInfo();
        controller.PaymentSave();
        
        Test.stopTest();
    }
}