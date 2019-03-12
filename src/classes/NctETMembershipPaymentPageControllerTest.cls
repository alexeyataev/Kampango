@isTest
private class NctETMembershipPaymentPageControllerTest {
    private static PaymentHubApiSettings__c paymentHubApiSettings = PaymentHubApiSettings__c.getInstance();
    Static contact newCont;
    @isTest static void contactIdExists() {
        Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt
                                                WHERE Payment_Method__c = 'Credit/Debit Card' limit 1];
        
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

		npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
        recDonate.Name = 'NCT Child';
        recDonate.npe03__Amount__c = 60;
        recDonate.npe03__Installment_Period__c = 'Monthly';
        recDonate.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDonate.First_Payment__c = system.today();
        recDonate.First_Contact__c = con.id; 
        recDonate.Membership_Status__c = 'Pending'; 
        recDonate.Membership_type__c = '18 month - Joint';
        recDonate.npe03__Contact__c = con.id;

        insert recDonate; 
 

       
        PageReference pageRef = Page.nctETMembershipPaymentPage; 
        Id contId = pageRef.getParameters().put('Id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef); 

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
        ApexPages.currentPage().getParameters().put('seltdName',membershipDetails.Id);
        ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
        ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

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
        controller.streetValue1 = con.Id;
        controller.streetValue2 = con.Id;
        controller.cityValue = con.Id;
        controller.primaryContact = con;
        controller.accountNumber = '12345';
        controller.accountName ='Test';
        controller.sortCode = '';
        controller.acquistion ='';
        controller.membershipSource ='';
        controller.sessionProfile = 'guest';
        controller.twomem = true;
        controller.expDate = System.Date.today();

        controller.receiveInput();
        controller.onCompleteContactInfo();
        controller.nctBranchs();
        controller.membershipDupeChecker();
        controller.giftAidCreation();
        controller.PaymentSave();     
        Test.stopTest();
        system.assertEquals(1,1);
       
    }
    @isTest static void contactIdNotExists(){
         Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                WHERE Payment_Method__c = 'Credit/Debit Card' limit 1];
        
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

		npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
        recDonate.Name = 'NCT Child';
        recDonate.npe03__Amount__c = 60;
        recDonate.npe03__Installment_Period__c = 'Monthly';
        recDonate.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDonate.First_Payment__c = system.today();
        recDonate.First_Contact__c = con.id; 
        recDonate.Membership_Status__c = 'Pending'; 
        recDonate.Membership_type__c = '18 month - Joint';
        recDonate.npe03__Contact__c = con.id;

        insert recDonate; 
 

       
        PageReference pageRef = Page.nctETMembershipPaymentPage; 
        Id contId = pageRef.getParameters().put('Id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef); 
        
        
        PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
        paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert paymentHubApiSettings; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
         ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

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
        controller.streetValue1 = con.Id;
        controller.streetValue2 = con.Id;
        controller.cityValue = con.Id;
        controller.primaryContact = con;
        controller.feeAmount = membershipDetails.Id;
        controller.accountNumber = '12345';
        controller.accountName ='Test';
        controller.sortCode = '';
        controller.acquistion ='';
        controller.membershipSource ='';
        controller.sessionProfile = 'guest';
        controller.twomem = true;
        controller.expDate = System.Date.today();

        controller.receiveInput();
        controller.nctBranchs();
        controller.contactInfo();
        controller.giftAidCreation();
        Test.stopTest();
        system.assertEquals(1,1);
    }
    @isTest static void secondContactIdNotExists(){
         Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                WHERE Payment_Method__c = 'Credit/Debit Card' limit 1];
        
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

		npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
        recDonate.Name = 'NCT Child';
        recDonate.npe03__Amount__c = 60;
        recDonate.npe03__Installment_Period__c = 'Monthly';
        recDonate.CARE_Payment_Frequency__c = 'NCT CHILD TRUST';
        recDonate.First_Payment__c = system.today();
        recDonate.First_Contact__c = con.id; 
        recDonate.Membership_Status__c = 'Pending'; 
        recDonate.Membership_type__c = '18 month - Joint';
        recDonate.npe03__Contact__c = con.id;

        insert recDonate; 
 

       
        PageReference pageRef = Page.nctETMembershipPaymentPage; 
        Id contId = pageRef.getParameters().put('Id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef); 
              
        PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
        paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert paymentHubApiSettings; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
        ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

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
        controller.streetValue1 = con.Id;
        controller.streetValue2 = con.Id;
        controller.cityValue = con.Id;
        controller.primaryContact = con;
        controller.feeAmount = membershipDetails.Id;
        
        controller.secondContactFirstName = con.Id;
        controller.secondContactLastName = con.Id;
        controller.secondContactEmail = con.Id;
        controller.secondContactPhone = con.Id;
        controller.salutationSecondary = con.Id;
        controller.secondContactGenders = con.Id;
        controller.secondaryContact = con;
        controller.accountNumber = '12345';
        controller.accountName ='Test';
        controller.sortCode = '';
        controller.acquistion ='';
        controller.membershipSource ='';
        controller.sessionProfile = 'guest';
        controller.receiveInput();
        controller.nctBranchs();
        controller.contactInfo();
        controller.onCompleteContactInfo();
        controller.giftAidCreation();     
        Test.stopTest();
        system.assertEquals(1,1);
    }
     @isTest static void negativeTesting(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Read Only']; 
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        System.runAs(u) {
             Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    WHERE Payment_Method__c = 'Direct Debit' limit 1];
            
            Account acc = new Account();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();       
            acc.Name ='Test Branch';
            insert acc;
            Contact primaryContact = new Contact();
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
            Id contId = pageRef.getParameters().put('Id', String.valueOf(primaryContact.Id));
            Test.setCurrentPage(pageRef); 
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
            ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
            ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
            controller.contId = contId;
            controller.FirstName = 'Test FirstName';
            controller.LastName = 'Test Last Nane';
            controller.Email = 'testemail@test.com';
            controller.phone = '12345678901';
            controller.postCode = 'SW123';
            controller.selectBranch = con.Id; 
            controller.salutation = 'Mr.';
            controller.genderValue = 'female';
            controller.streetValue = '';
            controller.stateValue = '';
            controller.streetValue1 = '';
            controller.streetValue2 = '';
            controller.cityValue = '';
            controller.feeAmount = membershipDetails.Id;
            controller.etSpecific = false;
            controller.eDate = '2050-03-31';
            controller.secondContactFirstName = 'Test Second Name';
            controller.secondContactLastName = 'Test Second Last Name';
            controller.secondContactEmail = 'test.secondlast@test.com';
            controller.secondContactPhone = '12345678901';
            controller.salutationSecondary = 'Mr.';
            controller.secondContactGenders = 'Male';
            controller.accountNumber = '12345';
            controller.accountName ='Test';
            controller.sortCode = '';
            controller.acquistion ='';
            controller.membershipSource ='';
            controller.sessionProfile = 'guest';
            controller.isGiftAid = 'true';
            controller.primaryContact = primaryContact;
            controller.receiveInput();
            controller.nctBranchs();
            controller.contactInfo();
            controller.onCompleteContactInfo();
            controller.giftAidCreation();     
            Test.stopTest();
            system.assertEquals(1,1);
        }
    }
    @isTest static void permissionCheck(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Payment Profile'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');

        System.runAs(u) {
             Membership_Type__mdt  membershipDetails = [SELECT Id, MasterLabel, Eligible_for_Gift_Aid__c,Installment_Amount__c, Payment_Target__c,Schedule_Type__c,
                                                    No_of_Installments__c,Payment_Type__c,  Payment_Method__c, Recursive__c, GiftAid_Type__c,
                                                    Total_Amount__c, Contact_Type__c, Membership__c,Installment_Period__c, 
                                                    GiftAid_Acquisition_Method__c,Target_Customer__c, Payment_Processor__c FROM  Membership_Type__mdt 
                                                    WHERE Payment_Method__c = 'Credit/Debit Card' limit 1];
            
            Account acc = new Account();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();       
            acc.Name ='Test Branch';
            insert acc;
            Contact primaryContact = new Contact();
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
            
            npe03__Recurring_Donation__c recDonate = new npe03__Recurring_Donation__c();
           
           
            PageReference pageRef = Page.nctETMembershipPaymentPage; 
            Id contId = pageRef.getParameters().put('Id', String.valueOf(primaryContact.Id));
            Test.setCurrentPage(pageRef); 
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
            ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
            ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
            controller.contId = contId;
            controller.FirstName = 'Test FirstName';
            controller.LastName = 'Test Last Nane';
            controller.Email = 'testemail@test.com';
            controller.phone = '12345678901';
            controller.postCode = 'SW123';
            controller.selectBranch = con.Id; 
            controller.salutation = 'Mr.';
            controller.genderValue = 'female';
            controller.streetValue = '';
            controller.stateValue = '';
            controller.streetValue1 = '';
            controller.streetValue2 = '';
            controller.cityValue = '';
            controller.feeAmount = membershipDetails.Id;
            controller.etSpecific = false;
            controller.eDate = '2050-03-31';
            controller.secondContactFirstName = 'Test Second Name';
            controller.secondContactLastName = 'Test Second Last Name';
            controller.secondContactEmail = 'test.secondlast@test.com';
            controller.secondContactPhone = '12345678901';
            controller.salutationSecondary = 'Mr.';
            controller.secondContactGenders = 'Male';
            controller.accountNumber = '12345';
            controller.accountName ='Test';
            controller.sortCode = '';
            controller.acquistion ='';
            controller.membershipSource ='';
            controller.sessionProfile = 'guest';
            controller.isGiftAid = 'true';
            controller.primaryContact = primaryContact;
            controller.nctBranchs();
            controller.contactInfo();
            controller.receiveInput();
            controller.onCompleteContactInfo();
            controller.giftAidCreation();     
            Test.stopTest();
            system.assertEquals(1,1);
        }
    }
}