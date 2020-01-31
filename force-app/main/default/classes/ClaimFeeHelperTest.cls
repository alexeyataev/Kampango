@isTest
private class ClaimFeeHelperTest {
    @testSetup
    static void createTestData(){
         TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc5')
            .buildPractitioner('Smith')
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCoursesWithSessions(2, 2);
    }

    static void createZumzumSetupRecords() {

        Zumzum__Tax_Rate__c zumzumTaxRate = new Zumzum__Tax_Rate__c(
            Name = 'No VAT',
            Zumzum__Type__c = 'Non-Vatable',
            Zumzum__Active__c = true,
            Zumzum__Tax_Rate__c = 0
        );

        insert zumzumTaxRate;

        Zumzum__Company_Setup__c zumzumCompanySetup = new Zumzum__Company_Setup__c(
            Name = 'NCT',
            Zumzum__Account_Lock_Date__c = Date.today() + 7,
            Zumzum__VAT_Number__c = 'XXXXXXXX'
        );
        insert zumzumCompanySetup;
         
        Zumzum__Currency__c zumzumCurrency = new Zumzum__Currency__c(
            Name = 'GBP',
            Zumzum__Is_Active__c = true,
            Zumzum__Is_Corporate__c = true,
            Zumzum__Symbol__c = '£',
            Zumzum__Company_Setup__c = zumzumCompanySetup.Id
        );
        insert zumzumCurrency;

        Zumzum__Nominal_Account__c zumzumNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Staff Salaries',
            Zumzum__Account_Code__c = 7003
        );

        insert zumzumNominalAccount;

        Zumzum__Company__c zumzumCompany = new Zumzum__Company__c(
            Name = 'NCT',
            Zumzum__Company_Base_Currency__c = zumzumCurrency.Id,
            Zumzum__Corporate_Company__c = zumzumCompanySetup.Id,
            Zumzum__Active__c = true,
            Zumzum__Corporate__c = true
        );

        insert zumzumCompany;

        Zumzum__General_Setup__c zumzumGeneralSetup = new Zumzum__General_Setup__c(
            Name = 'PI',
            Zumzum__Starting_Document_No__c = '00030000',
            Zumzum__Object__c = 'Purchase Invoice',
            Zumzum__Current_Document_Number__c = 30000
        );

        insert zumzumGeneralSetup;

        insert new Financial_Settings__c(
            PI_Nominal_Account_Id__c = zumzumNominalAccount.Id, 
            Practitioner_Registration_Capped_Fees__c = 300, 
            Practitioner_Registration_Fees_Rate__c = 0.03
        );

    }

    static void createCommunityPractitionerUser() {
        User portalAccountOwner = createPortalAccountOwner();
        System.runAs(portalAccountOwner) {

            Account organiztaion = [
                SELECT Id, AccountNumber, OwnerId
                FROM Account
                WHERE AccountNumber = 'acc5'
                LIMIT 1
            ];

            Contact practitioner = [
                SELECT Id, Name, AccountId
                FROM Contact
                WHERE LastName = 'Smith'
                LIMIT 1
            ];

            organiztaion.OwnerId = portalAccountOwner.Id;
            practitioner.AccountId = organiztaion.Id;

            update organiztaion;
            update practitioner;

            Profile p = [SELECT Id FROM Profile WHERE Name = 'Practitioner'];
            String uniqueUserName = 'practitioner' + DateTime.now().getTime() + '@testorg.com';

            User u = new User(
                Alias = 'practu',
                Email='practitioner@testorg.com',
                EmailEncodingKey='UTF-8',
                LastName='practitionerTesting',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_GB',
                ProfileId = p.Id,
                TimeZoneSidKey='Europe/London',
                UserName=uniqueUserName,
                ContactId = practitioner.Id,
                CommunityNickname = 'pract123'
            );
            insert u;
        }
    }

    private static User createPortalAccountOwner() { 
        UserRole portalRole = [
            SELECT Id, Name 
            FROM UserRole 
            WHERE PortalType = 'None' 
            LIMIT 1
        ];  

        Profile sysAdminProfile = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'System Administrator'
        ];  
        User portalAccountOwner = new User(  
            UserRoleId = portalRole.Id,  
            ProfileId = sysAdminProfile.Id,
            Username = 'portalOwner' + System.currentTimeMillis() + '@test.com',  
            Alias = 'Alias',  
            Email='portal.owner@test.com',  
            EmailEncodingKey='UTF-8',  
            Firstname='Portal',  
            Lastname='Owner',  
            LanguageLocaleKey='en_US',  
            LocaleSidKey='en_GB',  
            TimeZoneSidKey = 'Europe/London'  
        );  

        insert portalAccountOwner;  

        return portalAccountOwner;  
   }

    static User getPractitionerUser() {
        return [
            SELECT Id, AccountId, ContactId
            FROM User
            WHERE Email = 'practitioner@testorg.com'
            LIMIT 1
        ];
    }

    @isTest
    static void createPurchaseInvoice() {
        createCommunityPractitionerUser();
        ClaimFeeHelper.ClaimFeeWrapper flowData = new ClaimFeeHelper.ClaimFeeWrapper();
        flowData.sessions = [
            SELECT Id, Name, Practitioner_Fees__c
            FROM Session__c
        ];
        flowData.registrationFee = 5;

        Test.startTest();
            System.runAs(getPractitionerUser()) {
                createZumzumSetupRecords();
                ClaimFeeHelper.createPurchaseInvoice(new List<ClaimFeeHelper.ClaimFeeWrapper> {flowData});
            }
        Test.stopTest();

        System.assertEquals(2, [
            SELECT Id
            FROM Zumzum__Purchase_Invoice__c
        ].size());
    }
}