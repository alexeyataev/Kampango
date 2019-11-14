@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #29 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class SessionFeeHelperTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String BRANCH_RECORDTYPE_NAME  = 'Branch';
    private static final String PRACTITIONER_BAND = 'B';
    private static final String BRANCH_WEIGHTING = 'London';

    private static Integer daysBeforeToday = 3;
    
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
                    .buildSession();
    }

    @isTest
    private static void PassInListOfSessions_WithoutFeesAlreadyAssigned_AppropriateFeesAssigned(){
    
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRate();
        
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id FROM Practitioner_Fee_Rate__c];

        Test.startTest();
        SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
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
        Practitioner_Fee_Rate__c standardARate = practitionerFeeRates[0];
        Practitioner_Fee_Rate__c londonBRate = practitionerFeeRates[9];
        
        for (Session__c session : sessionsToTest) {
            session.Practitioner_Fee_Rate__c = practitionerFeeRates[0].Id;
        }

        update sessionsToTest;
    
        List<Practitioner_Band__c> practitionerBands = new List<Practitioner_Band__c>();

        TestPractitionerBandBuilder practitionerBandBuilder = new TestPractitionerBandBuilder();
        for(Contact practitioner : practitioners){
            practitionerBands.add(practitionerBandBuilder
                                    .withPractitionerContact(practitioner)
                                    .withBand(PRACTITIONER_BAND)
                                    .withStartDate(Date.today() - daysBeforeToday)
                                    .insertRecord(false)
                                    .build());
        }

        insert practitionerBands;

        List<Branch_Weighting__c> branchWeightings = new List<Branch_Weighting__c>();

        TestBranchWeightingBuilder branchWeightingBuilder = new TestBranchWeightingBuilder();
        for(Account branch : branches) {
            branchWeightings.add(branchWeightingBuilder
                                    .withBranch(branch)
                                    .withWeighting(BRANCH_WEIGHTING)
                                    .withStartDate(Date.today() - daysBeforeToday)
                                    .insertRecord(false)
                                    .build());
        }

        insert branchWeightings;
        
        Test.startTest();
        SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
        System.assertNotEquals(standardARate.Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
        System.assertEquals(londonBRate.Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
    }

    @isTest
    private static void PassInListOfSessions_WithoutFeesAlreadyAssigned_WithoutPractitionerFeeRateCreated(){
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];

        Test.startTest();
        SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
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
        SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
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
        SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
        System.assertEquals(null, sessionsTestResult[0].Practitioner_Fee_Rate__c);

    }
}