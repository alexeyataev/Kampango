@isTest
private class NctETMembershipPaymentPageControllerTest {
    private static PaymentHubApiSettings__c paymentHubApiSettings = PaymentHubApiSettings__c.getInstance();
    Static contact newCont;
    
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
            
        MembershipContactVo.SecondContactVo secondContact = new MembershipContactVo.SecondContactVo();
        secondContact.secondContactFirstName = 'Test Second Name';
        secondContact.secondContactLastName = 'Test Second Last Name';
        secondContact.secondContactEmail = 'test.secondlast@test.com';
        secondContact.secondContactPhone = '12345678901';
        secondContact.salutationSecondary = 'Mr.';
        secondContact.secondContactGenders = 'Male';
        
        MembershipContactVo contactVo = new MembershipContactVo();          
        contactVo.streetValue1 = '';
        contactVo.streetValue2 = '';
                    
        MembershipVo membershipVo = new MembershipVo();
        membershipVo.accountNumber = '12345';
        membershipVo.accountName ='Test';
        membershipVo.sortCode = '';
        membershipVo.acquistion ='';
        membershipVo.eDate = '2050-03-31';
        membershipVo.feeAmount = membershipDetails.Id;
        membershipVo.membershipSource ='';
        
        MembershipBooleanCheckVo.AccountDetails accountDetails = new MembershipBooleanCheckVo.AccountDetails();
        accountDetails.sessionProfile = 'Guest';
      
                   
        MembershipBooleanCheckVo booleanChecking = new MembershipBooleanCheckVo();    
        booleanChecking.isContactExisting = true;
        booleanChecking.isGiftAid = 'true';
                  
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc); 
            controller.secondContact = secondContact;
            controller.primaryContact = primaryContact;
            controller.booleanChecking = booleanChecking;
            controller.contactVo = contactVo;
            controller.membershipVo = membershipVo;
            controller.accountDetails = accountDetails;
            
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
             system.assertEquals('Guest', accountDetails.sessionProfile);
            system.assertEquals('Test', membershipVo.accountName);

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
        
        MembershipContactVo.SecondContactVo secondContact = new MembershipContactVo.SecondContactVo();
        secondContact.secondContactFirstName = 'Test Second Name';
        secondContact.secondContactLastName = 'Test Second Last Name';
        secondContact.secondContactEmail = 'test.secondlast@test.com';
        secondContact.secondContactPhone = '12345678901';
        secondContact.salutationSecondary = 'Mr.';
        secondContact.secondContactGenders = 'Male';
        
        MembershipContactVo contactVo = new MembershipContactVo();          
        contactVo.streetValue1 = '';
        contactVo.streetValue2 = '';
        
        MembershipBooleanCheckVo.AccountDetails accountDetails = new MembershipBooleanCheckVo.AccountDetails();
        accountDetails.sessionProfile = 'guest'; 
            
        MembershipVo membershipVo = new MembershipVo();
        membershipVo.accountNumber = '12345';
        membershipVo.accountName ='Test';
        membershipVo.sortCode = '';
        membershipVo.acquistion ='';
        membershipVo.eDate = '2050-03-31';
        membershipVo.feeAmount = membershipDetails.Id;
        membershipVo.membershipSource ='';            
              
         
        MembershipBooleanCheckVo booleanchecking = new MembershipBooleanCheckVo();        
        booleanchecking.isContactExisting = false;
        booleanchecking.twomems = false;
        booleanChecking.displayMbrNoMessage = true;
        booleanChecking.displaySuccessMessage = false;
        booleanChecking.isContactExisting = false;
        booleanChecking.isMembershipExists = true;
        booleanChecking.isGiftAid = 'true';

            Contact con = new Contact();
                       
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
            controller.secondContact = secondContact;
            controller.booleanChecking = booleanChecking;
            controller.contactVo = contactVo;
            controller.accountDetails = accountDetails;
            controller.membershipVo = membershipVo;
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
            system.assertEquals('Standard', accountDetails.sessionProfile);
            system.assertEquals('Test', membershipVo.accountName);
        }
    }
    @isTest static void etFlowTesting(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Enquiries Team']; 
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
            
            PageReference pageRef = Page.nctETMembershipPaymentPage; 
            Test.setCurrentPage(pageRef); 
        
        MembershipContactVo.SecondContactVo secondContact = new MembershipContactVo.SecondContactVo();
        secondContact.secondContactFirstName = 'Test Second Name';
        secondContact.secondContactLastName = 'Test Second Last Name';
        secondContact.secondContactEmail = 'test.secondlast@test.com';
        secondContact.secondContactPhone = '12345678901';
        secondContact.salutationSecondary = 'Mr.';
        secondContact.secondContactGenders = 'Male';
        
        MembershipContactVo contactVo = new MembershipContactVo();          
        contactVo.streetValue1 = '';
        contactVo.streetValue2 = '';
        
        MembershipBooleanCheckVo.AccountDetails accountDetails = new MembershipBooleanCheckVo.AccountDetails();
        accountDetails.sessionProfile = 'guest'; 
            
        MembershipVo membershipVo = new MembershipVo();
        membershipVo.accountNumber = '12345';
        membershipVo.accountName ='Test';
        membershipVo.sortCode = '';
        membershipVo.acquistion ='';
        membershipVo.eDate = '2050-03-31';
        membershipVo.feeAmount = membershipDetails.Id;
        membershipVo.membershipSource ='';            
              
         
        MembershipBooleanCheckVo booleanchecking = new MembershipBooleanCheckVo();        
        booleanchecking.isContactExisting = false;
        booleanchecking.twomems = false;
        booleanChecking.displayMbrNoMessage = true;
        booleanChecking.displaySuccessMessage = false;
        booleanChecking.isContactExisting = false;
        booleanChecking.isMembershipExists = true;
        booleanChecking.isGiftAid = 'true';

            Contact con = new Contact();
                       
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
            controller.secondContact = secondContact;
            controller.booleanChecking = booleanChecking;
            controller.contactVo = contactVo;
            controller.accountDetails = accountDetails;
            controller.membershipVo = membershipVo;
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
            Test.stopTest();
            system.assertEquals('Standard', accountDetails.sessionProfile);
            system.assertEquals('Test', membershipVo.accountName);
        }
    }
    @isTest static void etNegativeFlowTesting(){
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
            con.MailingPostalCode = 'NR3 3NS';
            con.salutation = 'Mr';
            con.Gender__c = 'Male';
            insert con;
            
            PageReference pageRef = Page.nctETMembershipPaymentPage; 
            Id contId = pageRef.getParameters().put('Id', String.valueOf(con.Id));
            Test.setCurrentPage(pageRef); 
        
        MembershipContactVo.SecondContactVo secondContact = new MembershipContactVo.SecondContactVo();
        secondContact.secondContactFirstName = 'Test Second Name';
        secondContact.secondContactLastName = 'Test Second Last Name';
        secondContact.secondContactEmail = 'test.secondlast@test.com';
        secondContact.secondContactPhone = '12345678901';
        secondContact.salutationSecondary = 'Mr.';
        secondContact.secondContactGenders = 'Male';
        
        MembershipContactVo contactVo = new MembershipContactVo();          
        contactVo.streetValue1 = '';
        contactVo.streetValue2 = '';
        
        MembershipBooleanCheckVo.AccountDetails accountDetails = new MembershipBooleanCheckVo.AccountDetails();
        accountDetails.sessionProfile = 'guest'; 
            
        MembershipVo membershipVo = new MembershipVo();
        membershipVo.accountNumber = '12345';
        membershipVo.accountName ='Test';
        membershipVo.sortCode = '';
        membershipVo.acquistion ='';
        membershipVo.eDate = '2050-03-31';
        membershipVo.feeAmount = membershipDetails.Id;
        membershipVo.membershipSource ='';            
              
         
        MembershipBooleanCheckVo booleanchecking = new MembershipBooleanCheckVo();        
        booleanchecking.isContactExisting = false;
        booleanchecking.twomems = true;
        booleanChecking.displayMbrNoMessage = true;
        booleanChecking.displaySuccessMessage = false;
        booleanChecking.isContactExisting = false;
        booleanChecking.isMembershipExists = true;
        booleanChecking.isGiftAid = 'true';

                       
            PaymentHubApiSettings__c paymentHubApiSettings = new PaymentHubApiSettings__c();
            paymentHubApiSettings.Payment_Status_Root_Url__c = 'https://test.salesforce.com/nctMembershipPaymentPage';
            paymentHubApiSettings.Credit_Card_Payment_API_Token__c = '1234567890123';
            insert paymentHubApiSettings; 
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            nctETMembershipPaymentPageController controller = new nctETMembershipPaymentPageController(sc);
            controller.secondContact = secondContact;
            controller.booleanChecking = booleanChecking;
            controller.contactVo = contactVo;
            controller.accountDetails = accountDetails;
            controller.membershipVo = membershipVo;
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
            Test.stopTest();
            system.assertEquals('Standard', accountDetails.sessionProfile);
            system.assertEquals('Test', membershipVo.accountName);
        }
    }
    
}