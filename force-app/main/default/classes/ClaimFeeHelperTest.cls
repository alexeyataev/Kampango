@isTest
private class ClaimFeeHelperTest {
    private static final String PRACTITIONER_TAX_RATE = 'Exempt Transactions (0%)';

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

    static void createCommunityPractitionerUser() {
        User portalAccountOwner = createPortalAccountOwner();
        System.runAs(portalAccountOwner) {

            Account organiztaion = [
                SELECT Id, AccountNumber, OwnerId
                FROM Account
                WHERE Name = 'John Smith'
                    AND Type = 'Supplier'
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
            SELECT Id, Name, Practitioner_Fees__c, PSA_Area__c, Course__c
            FROM Session__c
            LIMIT 1
        ];
        flowData.registrationFee = 5;
        System.runAs(getPractitionerUser()) {
            TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
            financeDataFactory.createZumzumData();
        }    
        Test.startTest();
            System.runAs(getPractitionerUser()) {
                ClaimFeeHelper.createPurchaseInvoice(new List<ClaimFeeHelper.ClaimFeeWrapper> {flowData});
            }
        Test.stopTest();

        Zumzum__Tax_Rate__c zumzumExemptTransactions = [
            SELECT Id, Name 
            FROM Zumzum__Tax_Rate__c 
            WHERE Name =: PRACTITIONER_TAX_RATE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        System.assertEquals(2, [
            SELECT Id
            FROM Zumzum__Purchase_Invoice__c
        ].size()); 
        
        System.assertEquals(zumzumExemptTransactions.Id, [
            SELECT Zumzum__Tax_Rate__r.Name
            FROM Zumzum__Purchase_Invoice_Line_Item__c
        ][0].Zumzum__Tax_Rate__r.Id);    
    }
}