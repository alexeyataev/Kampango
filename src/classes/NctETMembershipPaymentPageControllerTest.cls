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
        con.FirstName = 'Childs';
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
        
       MembershipVo membership = new MembershipVo();
        membership.FirstName = con.id;
        membership.LastName = con.id;
        membership.Email = con.Id;
        membership.phone = con.Id;
        membership.postCode = con.Id;
        membership.selectBranch = con.Id; 
        membership.salutation = con.id;
        membership.genderValue = con.id;
        membership.streetValue = con.Id;
        membership.stateValue = con.Id;
        membership.streetValue1 = con.Id;
        membership.streetValue2 = con.Id;
        membership.cityValue = con.Id;
        membership.primaryContact = con;
        membership.accountNumber = '12345';
        membership.accountName ='Test';
        membership.sortCode = '';
        membership.acquistion ='';
        membership.membershipSource ='';
        membership.sessionProfile = 'guest';
        membership.twomem = true;
        membership.expDate = System.Date.today();
        
        
        ApexPages.currentPage().getParameters().put('seltdName',membershipDetails.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
        controller.membership = membership;
        ApexPages.currentPage().getParameters().put('seltdName',membershipDetails.Id);
        ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
        ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

        

        controller.receiveInput();
        controller.onCompleteContactInfo();
        controller.nctBranchs();
        controller.membershipDupeChecker();
        controller.giftAidCreation();
        controller.PaymentSave();      
        Test.stopTest();
       system.assertEquals('guest', membership.sessionProfile);
            system.assertEquals('Test', membership.accountName);
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
        con.FirstName = 'Childs';
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
        
         MembershipVo membership = new MembershipVo();
        membership.FirstName = con.id;
        membership.LastName = con.id;
        membership.Email = con.Id;
        membership.phone = con.Id;
        membership.postCode = con.Id;
        membership.selectBranch = con.Id; 
        membership.salutation = con.id;
        membership.genderValue = con.id;
        membership.streetValue = con.Id;
        membership.stateValue = con.Id;
        membership.streetValue1 = con.Id;
        membership.streetValue2 = con.Id;
        membership.cityValue = con.Id;
        membership.primaryContact = con;
        membership.feeAmount = membershipDetails.Id;
        membership.accountNumber = '12345';
        membership.accountName ='Test';
        membership.sortCode = '';
        membership.acquistion ='';
        membership.membershipSource ='';
        membership.sessionProfile = 'guest';
        membership.twomem = true;
        membership.expDate = System.Date.today();
       
        
        
        PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
        paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert paymentHubApiSettings; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
        controller.membership = membership;
         ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

       

        controller.receiveInput();
        controller.nctBranchs();
        controller.contactInfo();
        controller.giftAidCreation();
        Test.stopTest();
        system.assertEquals('Standard', membership.sessionProfile);
            system.assertEquals('Test', membership.accountName);
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
        con.FirstName = 'Childs';
        con.LastName = 'Test LastName';
        con.Email = 'testemail@test.com';
        con.Phone = '123456789';
        con.MailingPostalCode = 'SW123';
        con.salutation = 'Mr';
        con.Gender__c = 'Male';
        insert con;
        
        Contact secCon = new Contact();
        secCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Companion').getRecordTypeId();

        secCon.Branch__c = acc.id; 
        secCon.MailingStreet = 'Test address';
        secCon.MailingState = 'Test State';
        secCon.MailingCity = 'Test City';
        secCon.Prefered_First_Name__c = 'Test SecFirstName';
        secCon.LastName = 'Test LastNameSec';
        secCon.Email = 'testemailSec@test.com';
        secCon.Phone = '12345678912';
        secCon.MailingPostalCode = 'SW1234';
        secCon.salutation = 'Mr';
        secCon.Gender__c = 'Male';
        secCon.Parent_Contact__c = con.Id;
        insert secCon;

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
 
        MembershipVo membership = new MembershipVo();
         membership.FirstName = con.id;
        membership.LastName = con.id;
        membership.Email = con.Id;
        membership.phone = con.Id;
        membership.postCode = con.Id;
        membership.selectBranch = con.Id; 
        membership.salutation = con.id;
        membership.genderValue = con.id;
        membership.streetValue = con.Id;
        membership.stateValue = con.Id;
        membership.streetValue1 = con.Id;
        membership.streetValue2 = con.Id;
        membership.cityValue = con.Id;
        membership.primaryContact = con;
        membership.feeAmount = membershipDetails.Id;
        membership.secondContactFirstName = secCon.Id;
        membership.secondContactLastName = secCon.Id;
        membership.secondContactEmail = secCon.Id;
        membership.secondContactPhone = secCon.Id;
        membership.salutationSecondary = secCon.Id;
        membership.secondContactGenders = secCon.Id;
        membership.secondaryContact = secCon;
        membership.accountNumber = '12345';
        membership.accountName ='Test';
        membership.sortCode = '';
        membership.acquistion ='';
        membership.membershipSource ='';
        membership.sessionProfile = 'guest';
       
       
              
        PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
        paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert paymentHubApiSettings; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
        controller.membership = membership;
        ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

       
        controller.receiveInput();
        controller.nctBranchs();
        controller.contactInfo();
        controller.onCompleteContactInfo();
        controller.giftAidCreation();     
        Test.stopTest();
        system.assertEquals('Standard', membership.sessionProfile);
            system.assertEquals('Test', membership.accountName);
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
            con.FirstName = 'Childs';
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
            
            MembershipVo membership = new MembershipVo();
             membership.contId = contId;
            membership.FirstName = 'Test FirstName';
            membership.LastName = 'Test Last Nane';
            membership.Email = 'testemail@test.com';
            membership.phone = '12345678901';
            membership.postCode = 'SW123';
            membership.selectBranch = con.Id; 
            membership.salutation = 'Mr.';
            membership.genderValue = 'female';
            membership.streetValue = '';
            membership.stateValue = '';
            membership.streetValue1 = '';
            membership.streetValue2 = '';
            membership.cityValue = '';
            membership.feeAmount = membershipDetails.Id;
            membership.etSpecific = false;
            membership.eDate = '2050-03-31';
            membership.secondContactFirstName = 'Test Second Name';
            membership.secondContactLastName = 'Test Second Last Name';
            membership.secondContactEmail = 'test.secondlast@test.com';
            membership.secondContactPhone = '12345678901';
            membership.salutationSecondary = 'Mr.';
            membership.secondContactGenders = 'Male';
            membership.accountNumber = '12345';
            membership.accountName ='Test';
            membership.sortCode = '';
            membership.acquistion ='';
            membership.membershipSource ='';
            membership.sessionProfile = 'guest';
            membership.isGiftAid = 'true';
            membership.primaryContact = primaryContact;
           
          
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
            controller.membership = membership;
            ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
            ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
           
            controller.receiveInput();
            controller.nctBranchs();
            controller.contactInfo();
            controller.onCompleteContactInfo();
            controller.giftAidCreation();     
            Test.stopTest();
            system.assertEquals('guest', membership.sessionProfile);
            system.assertEquals('Test', membership.accountName);
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
            con.FirstName = 'Childs';
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
            
            MembershipVo membership = new MembershipVo();
            membership.contId = contId;
            membership.FirstName = 'Test FirstName';
            membership.LastName = 'Test Last Nane';
            membership.Email = 'testemail@test.com';
            membership.phone = '12345678901';
            membership.postCode = 'SW123';
            membership.selectBranch = con.Id; 
            membership.salutation = 'Mr.';
            membership.genderValue = 'female';
            membership.streetValue = '';
            membership.stateValue = '';
            membership.streetValue1 = '';
            membership.streetValue2 = '';
            membership.cityValue = '';
            membership.feeAmount = membershipDetails.Id;
            membership.etSpecific = false;
            membership.eDate = '2050-03-31';
            membership.secondContactFirstName = 'Test Second Name';
            membership.secondContactLastName = 'Test Second Last Name';
            membership.secondContactEmail = 'test.secondlast@test.com';
            membership.secondContactPhone = '12345678901';
            membership.salutationSecondary = 'Mr.';
            membership.secondContactGenders = 'Male';
            membership.accountNumber = '12345';
            membership.accountName ='Test';
            membership.sortCode = '';
            membership.acquistion ='';
            membership.membershipSource ='';
            membership.sessionProfile = 'guest';
            membership.isGiftAid = 'true';
            membership.primaryContact = primaryContact;
            
          
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
            controller.membership = membership;
            ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
            ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
            
            controller.nctBranchs();
            controller.contactInfo();
            controller.receiveInput();
            controller.onCompleteContactInfo();
            controller.giftAidCreation();     
            Test.stopTest();
             system.assertEquals('Guest', membership.sessionProfile);
            system.assertEquals('Test', membership.accountName);

        }
    }
    @isTest static void duplicateTesting(){
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
            
              PageReference pageRef = Page.nctETMembershipPaymentPage; 
            Test.setCurrentPage(pageRef); 
            
            MembershipVo membership = new MembershipVo();
            membership.isContactExisting = false;
            membership.primaryContact = null;
            membership.twomem = true;
            membership.twomems = false;
            membership.FirstName = 'Test FirstName';
            membership.LastName = 'Test Last Nane';
            membership.Email = 'testemail@test.com';
            membership.phone = '12345678901';
            membership.postCode = 'SW123';
            membership.selectBranch = acc.Id; 
            membership.salutation = 'Mr.';
            membership.genderValue = 'female';
            membership.streetValue = '';
            membership.stateValue = '';
            membership.streetValue1 = '';
            membership.streetValue2 = '';
            membership.cityValue = '';
            membership.feeAmount = membershipDetails.Id;
            membership.etSpecific = false;
            membership.eDate = '2050-03-31';
            membership.secondContactFirstName = 'Test Second Name';
            membership.secondContactLastName = 'Test Second Last Name';
            membership.secondContactEmail = 'test.secondlast@test.com';
            membership.secondContactPhone = '12345678901';
            membership.salutationSecondary = 'Mr.';
            membership.secondContactGenders = 'Male';
            membership.accountNumber = '12345';
            membership.accountName ='Test';
            membership.sortCode = '';
            membership.acquistion ='';
            membership.membershipSource ='';
            membership.sessionProfile = 'guest';
            membership.isGiftAid = 'true';
           
          
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController();
            controller.membership = membership;
            ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
            ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
           
            controller.receiveInput();
            controller.nctBranchs();
            controller.contactInfo();
            controller.onCompleteContactInfo();
            controller.giftAidCreation();     
            Test.stopTest();
            system.assertEquals('guest', membership.sessionProfile);
            system.assertEquals('Test', membership.accountName);
        }
    }
    
}