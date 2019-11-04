@isTest
public with sharing class SessionFeeHelperTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String BRANCH_RECORDTYPE_NAME  = 'Branch';
    private static final Integer COURSES_TO_BUILD = 2;
    private static final Integer SESSIONS_TO_BUILD_ON_EACH_COURSE = 6;
    private static final String PRACTITIONER_BAND = 'B';
    private static final String BRANCH_WEIGHTING = 'Standard';
    
    @TestSetup
    private static void SetupTestData(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildPractitionerBands()
                    .buildBranchWeighting();
    }

    @isTest
    private static void PassInListOfSessions_WithoutFeesAlreadyAssigned_AppropriateFeesAssigned(){
    
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRate();
        
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id FROM Practitioner_Fee_Rate__c];

        Test.startTest();
        List<Session__c> sessionsTestResult = SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);

        Test.stopTest();

        System.assertEquals(practitionerFeeRates[0].Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
    }
    
    

    @isTest
    private static void FeesAlreadyAssigned_CreateNewBranchWeighting_SessionsCorrectlyReassigned(){

        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRateSet();
        
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];
        List<Contact> practitioners = [SELECT Id FROM Contact WHERE RecordType.Name =:PRACTITIONER_RECORDTYPE_NAME];
        List<Account> branches = [SELECT Id FROM Account WHERE RecordType.Name =:BRANCH_RECORDTYPE_NAME];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id FROM Practitioner_Fee_Rate__c];
        
        for (Session__c session : sessionsToTest) {
            session.Practitioner_Fee_Rate__c = practitionerFeeRates[0].Id;
        }

        update sessionsToTest;
    
        List<Practitioner_Band__c> practitionerBands = new List<Practitioner_Band__c>();

        TestPractitionerBandBuilder practitionerBandBuilder = new TestPractitionerBandBuilder();
        for(Contact practitioner : practitioners){
            practitionerBands.add(practitionerBandBuilder
                                    .withPractitioner(practitioner)
                                    .withBand(PRACTITIONER_BAND)
                                    .withStartDate(Date.today() - 3)
                                    .insertRecord(false)
                                    .build());
        }

        insert practitionerBands;

        List<Branch_Weighting__c> branchWeightings = new List<Branch_Weighting__c>();

        TestBranchWeightingBuilder branchWeightingBuilder = new TestBranchWeightingBuilder();
        for(Account branch : branches) {
            branchWeightings.add(branchWeightingBuilder
                                    .withBranch(branch)
                                    .withWeighting('London')
                                    .withStartDate(Date.today() - 3)
                                    .insertRecord(false)
                                    .build());
        }

        insert branchWeightings;

        Practitioner_Fee_Rate__c standardARate = practitionerFeeRates[0];
        Practitioner_Fee_Rate__c londonBRate = practitionerFeeRates[9];
        
        Test.startTest();
        List<Session__c> sessionsTestResult = SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        System.assertNotEquals(standardARate.Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
        System.assertEquals(londonBRate.Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
    }

    @isTest
    private static void PassInListOfSessions_WithoutFeesAlreadyAssigned_WithoutPractitionerFeeRateCreated(){
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];

        Test.startTest();
        List<Session__c> sessionsTestResult = SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        System.assertEquals(null, sessionsTestResult[0].Practitioner_Fee_Rate__c);

    }

    @isTest
    private static void PassInListOfSessions_WithoutFeesAlreadyAssigned_WithoutPractitionerBand(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRate();
        
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id FROM Practitioner_Fee_Rate__c];
        List<Practitioner_Band__c> practitionerBands = [SELECT Id FROM Practitioner_Band__c];

        delete practitionerBands;

        Test.startTest();
        List<Session__c> sessionsTestResult = SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        System.assertEquals(null, sessionsTestResult[0].Practitioner_Fee_Rate__c);

    }

    @isTest
    private static void PassInListOfSessions_WithoutFeesAlreadyAssigned_WithoutBranchWeighting(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRate();
        
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id FROM Practitioner_Fee_Rate__c];
        List<Branch_Weighting__c> branchWeightings = [SELECT Id FROM Branch_Weighting__c];

        delete branchWeightings;

        Test.startTest();
        List<Session__c> sessionsTestResult = SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        System.assertEquals(null, sessionsTestResult[0].Practitioner_Fee_Rate__c);

    }
}