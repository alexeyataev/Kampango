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
               

       MembershipVo.SecondContactVo secondContact = new MembershipVo.SecondContactVo();
        secondContact.streetValue1 = con.Id;
        secondContact.streetValue2 = con.Id;
        
        MembershipVo.AccountInfo accountInfo = new MembershipVo.AccountInfo();
        accountInfo.accountNumber = '12345';
        accountInfo.accountName ='Test';
        accountInfo.sortCode = '';
        accountInfo.sessionProfile = 'guest';
        
        MembershipVo.MembershipInformation membershipInfo = new MembershipVo.MembershipInformation();
        membershipInfo.acquistion ='';
        membershipInfo.membershipSource ='';
        

        
        
        ApexPages.currentPage().getParameters().put('seltdName',membershipDetails.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
        controller.accountInformation = accountInfo;
        controller.membershipDetails = membershipInfo;
        controller.secondContact = secondContact;
        controller.primaryContact = con;
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
       system.assertEquals('guest', accountInfo.sessionProfile);
            system.assertEquals('Test', accountInfo.accountName);
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
        
        MembershipVo.SecondContactVo secondContact = new MembershipVo.SecondContactVo();
        secondContact.streetValue1 = con.Id;
        secondContact.streetValue2 = con.Id;
        
        MembershipVo.AccountInfo accountInfo = new MembershipVo.AccountInfo();
        accountInfo.accountNumber = '12345';
        accountInfo.accountName ='Test';
        accountInfo.sortCode = '';
        accountInfo.sessionProfile = 'guest';
        accountInfo.feeAmount = membershipDetails.Id;
        
        MembershipVo.MembershipInformation membershipInfo = new MembershipVo.MembershipInformation();
        membershipInfo.acquistion ='';
        membershipInfo.membershipSource ='';   
        
        
        PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
        paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert paymentHubApiSettings; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
        controller.accountInformation = accountInfo;
        controller.membershipDetails = membershipInfo;
        controller.secondContact = secondContact;
        controller.primaryContact = con;
        controller.expDate = System.Date.today();
        ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

       

        controller.receiveInput();
        controller.nctBranchs();
        controller.contactInfo();
        controller.giftAidCreation();
        Test.stopTest();
        system.assertEquals('Standard', accountInfo.sessionProfile);
            system.assertEquals('Test', accountInfo.accountName);
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
        secCon.FirstName = 'Test Cities';
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
 
        MembershipVo.SecondContactVo secondContact = new MembershipVo.SecondContactVo();
        secondContact.streetValue1 = con.Id;
        secondContact.streetValue2 = con.Id;
        secondContact.secondContactFirstName = secCon.Id;
        secondContact.secondContactLastName = secCon.Id;
        secondContact.secondContactEmail = secCon.Id;
        secondContact.secondContactPhone = secCon.Id;
        secondContact.salutationSecondary = secCon.Id;
        secondContact.secondContactGenders = secCon.Id;
        
        MembershipVo.AccountInfo accountInfo = new MembershipVo.AccountInfo();
        accountInfo.accountNumber = '12345';
        accountInfo.accountName ='Test';
        accountInfo.sortCode = '';
        accountInfo.sessionProfile = 'guest';
        accountInfo.feeAmount = membershipDetails.Id;
        
        MembershipVo.MembershipInformation membershipInfo = new MembershipVo.MembershipInformation();
        membershipInfo.acquistion ='';
        membershipInfo.membershipSource ='';   
              
              
        PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
        paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
        paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
        insert paymentHubApiSettings; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
        controller.accountInformation = accountInfo;
        controller.membershipDetails = membershipInfo;
        controller.secondContact = secondContact;
        controller.primaryContact = con;
        controller.secondaryContact = secCon;
        ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
        ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
        ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');

       
        controller.receiveInput();
        controller.nctBranchs();
        controller.contactInfo();
        controller.giftAidCreation();     
        Test.stopTest();
        system.assertEquals('Standard', accountInfo.sessionProfile);
            system.assertEquals('Test', accountInfo.accountName);
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
            Id contId = pageRef.getParameters().put('Id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef); 
            
            MembershipVo.SecondContactVo secondContact = new MembershipVo.SecondContactVo();
        secondContact.streetValue1 = '';
        secondContact.streetValue2 = '';
        secondContact.secondContactFirstName = 'Test Second Name';
        secondContact.secondContactLastName = 'Test Second Last Name';
        secondContact.secondContactEmail = 'test.secondlast@test.com';
        secondContact.secondContactPhone = '12345678901';
        secondContact.salutationSecondary = 'Mr.';
        secondContact.secondContactGenders = 'Male';
        secondContact.eDate = '2050-03-31';
        
        MembershipVo.AccountInfo accountInfo = new MembershipVo.AccountInfo();
        accountInfo.accountNumber = '12345';
        accountInfo.accountName ='Test';
        accountInfo.sortCode = '';
        accountInfo.sessionProfile = 'guest';
        accountInfo.feeAmount = membershipDetails.Id;
        accountInfo.isGiftAid = 'true';
        
        MembershipVo.MembershipInformation membershipInfo = new MembershipVo.MembershipInformation();
        membershipInfo.acquistion ='';
        membershipInfo.membershipSource =''; 
                     
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
            controller.accountInformation = accountInfo;
            controller.membershipDetails = membershipInfo;
            controller.secondContact = secondContact;
            controller.primaryContact = primaryContact;
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
            system.assertEquals('guest', accountInfo.sessionProfile);
            system.assertEquals('Test', accountInfo.accountName);
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
            Id contId = pageRef.getParameters().put('Id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef); 
            
        MembershipVo.SecondContactVo secondContact = new MembershipVo.SecondContactVo();
        secondContact.streetValue1 = '';
        secondContact.streetValue2 = '';
        secondContact.secondContactFirstName = 'Test Second Name';
        secondContact.secondContactLastName = 'Test Second Last Name';
        secondContact.secondContactEmail = 'test.secondlast@test.com';
        secondContact.secondContactPhone = '12345678901';
        secondContact.salutationSecondary = 'Mr.';
        secondContact.secondContactGenders = 'Male';
        secondContact.eDate = '2050-03-31';
        
        MembershipVo.AccountInfo accountInfo = new MembershipVo.AccountInfo();
        accountInfo.accountNumber = '12345';
        accountInfo.accountName ='Test';
        accountInfo.sortCode = '';
        accountInfo.sessionProfile = 'guest';
        accountInfo.feeAmount = membershipDetails.Id;
        accountInfo.isGiftAid = 'true';
        
        MembershipVo.MembershipInformation membershipInfo = new MembershipVo.MembershipInformation();
        membershipInfo.acquistion ='';
        membershipInfo.membershipSource =''; 
                   
        MembershipVo.BooleanCheck booleanChecking = new MembershipVo.BooleanCheck();    
        booleanChecking.isContactExisting = true;
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
            controller.accountInformation = accountInfo;
            controller.membershipDetails = membershipInfo;
            controller.secondContact = secondContact;
            controller.primaryContact = primaryContact;
            ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
            ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
            
            controller.nctBranchs();
            controller.contactInfo();
            controller.receiveInput();
            controller.secondaryContactCreation();
            controller.membershipDupeChecker();
            controller.onCompleteContactInfo();
            controller.giftAidCreation();
            
            Test.stopTest();
             system.assertEquals('Guest', accountInfo.sessionProfile);
            system.assertEquals('Test', accountInfo.accountName);

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
            
        MembershipVo.SecondContactVo secondContact = new MembershipVo.SecondContactVo();
        secondContact.streetValue1 = '';
        secondContact.streetValue2 = '';
        secondContact.secondContactFirstName = 'Test Second Name';
        secondContact.secondContactLastName = 'Test Second Last Name';
        secondContact.secondContactEmail = 'test.secondlast@test.com';
        secondContact.secondContactPhone = '12345678901';
        secondContact.salutationSecondary = 'Mr.';
        secondContact.secondContactGenders = 'Male';
        secondContact.eDate = '2050-03-31';
        
        MembershipVo.AccountInfo accountInfo = new MembershipVo.AccountInfo();
        accountInfo.accountNumber = '12345';
        accountInfo.accountName ='Test';
        accountInfo.sortCode = '';
        accountInfo.sessionProfile = 'guest';
        accountInfo.feeAmount = membershipDetails.Id;
        accountInfo.isGiftAid = 'true';
        
        MembershipVo.MembershipInformation membershipInfo = new MembershipVo.MembershipInformation();
        membershipInfo.acquistion ='';
        membershipInfo.membershipSource ='';
         
        MembershipVo.BooleanCheck booleanchecking = new MembershipVo.BooleanCheck();        
        booleanchecking.isContactExisting = false;
        booleanchecking.twomems = false;
        booleanChecking.displayMbrNoMessage = true;
        booleanChecking.displaySuccessMessage = false;
        booleanChecking.isContactExisting = false;
        booleanChecking.isMembershipExists = true;

            Contact con = new Contact();
                       
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
            controller.accountInformation = accountInfo;
            controller.membershipDetails = membershipInfo;
            controller.secondContact = secondContact;
            controller.booleanChecking = booleanchecking;
            controller.primaryContact = null;

            ApexPages.currentPage().getParameters().put('emailsVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('postVal','SE1 3XF');
            ApexPages.currentPage().getParameters().put('emailDupeVal','testemail@test.com');
            ApexPages.currentPage().getParameters().put('seltAmountdName',membershipDetails.Id);
           
            controller.receiveInput();
            controller.membershipDupeChecker();
            controller.nctBranchs();
            controller.contactInfo();
            controller.onCompleteContactInfo();
            controller.giftAidCreation();  
            controller.paymentSave();
            Test.stopTest();
            system.assertEquals('Standard', accountInfo.sessionProfile);
            system.assertEquals('Test', accountInfo.accountName);
        }
    }
    
}