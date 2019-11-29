//@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #28 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class BranchWeightingHelperTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String BRANCH_RECORDTYPE_NAME  = 'Branch';
    private static final String PRACTITIONER_BAND = 'B';
    private static final String STANDARD_BRANCH_WEIGHTING = 'Standard';
    private static final String LONDON_BRANCH_WEIGHTING = 'London';

    private static Integer daysBeforeToday = 3;
    private static Integer daysAfterToday = 15;
    
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
    private static void PractitionerHasExistingSession_BranchWeightingRecordCreated_SessionGetsAssignedToAppropriateFeeRate(){
    
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRate();
        
        List<Account> branches = [SELECT Id FROM Account WHERE RecordType.Name =:BRANCH_RECORDTYPE_NAME];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id FROM Practitioner_Fee_Rate__c];

        List<Branch_Weighting__c> branchWeightings = new List<Branch_Weighting__c>();
        TestBranchWeightingBuilder branchWeightingBuilder = new TestBranchWeightingBuilder();
        for(Account branch : branches) {
            branchWeightings.add(branchWeightingBuilder
                                    .withBranch(branch)
                                    .withWeighting(STANDARD_BRANCH_WEIGHTING)
                                    .withStartDate(Date.today() - daysBeforeToday)
                                    .insertRecord(false)
                                    .build());
        }

        insert branchWeightings;

        Test.startTest();
        BranchWeightingHelper.updateFeesOnAffectedSessions(branchWeightings);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
        System.assertEquals(practitionerFeeRates[0].Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);

    }

    @isTest
    private static void PractitionerHasExistingSession_NewBackDatedBranchWeightingCreated_SessionGetsReassignedToAppropriateFeeRate(){
    
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRateSet();

        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];
        List<Contact> practitioners = [SELECT Id FROM Contact WHERE RecordType.Name =:PRACTITIONER_RECORDTYPE_NAME];
        List<Account> branches = [SELECT Id FROM Account WHERE RecordType.Name =:BRANCH_RECORDTYPE_NAME];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id, Practitioner_Band__c, Geographical_Weighting__c FROM Practitioner_Fee_Rate__c];
        Practitioner_Fee_Rate__c standardARate = practitionerFeeRates[0];
        Practitioner_Fee_Rate__c londonBRate = practitionerFeeRates[9];

        for (Session__c session : sessionsToTest) {
            session.Practitioner_Fee_Rate__c = standardARate.Id;
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
                                    .withWeighting(LONDON_BRANCH_WEIGHTING)
                                    .withStartDate(Date.today() - daysBeforeToday)
                                    .insertRecord(false)
                                    .build());
        }

        insert branchWeightings;
        
        Test.startTest();
        BranchWeightingHelper.updateFeesOnAffectedSessions(branchWeightings);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
        System.assertNotEquals(standardARate.Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
        System.assertEquals(londonBRate.Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);

    }

    @isTest
    private static void PractitionerHasExistingSession_BranchWeightingRecordFutureDatedCreated_SessionFeeRateRemainsInitial(){
    
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildPractitionerFeeRate();
        
        List<Account> branches = [SELECT Id FROM Account WHERE RecordType.Name =:BRANCH_RECORDTYPE_NAME];
        List<Practitioner_Fee_Rate__c> practitionerFeeRates = [SELECT Id, Practitioner_Band__c, Geographical_Weighting__c FROM Practitioner_Fee_Rate__c];
        Practitioner_Fee_Rate__c initialRate = practitionerFeeRates[0];

        List<Branch_Weighting__c> branchWeightings = new List<Branch_Weighting__c>();
        TestBranchWeightingBuilder branchWeightingBuilder = new TestBranchWeightingBuilder();
        for(Account branch : branches) {
            branchWeightings.add(branchWeightingBuilder
                                    .withBranch(branch)
                                    .withWeighting(STANDARD_BRANCH_WEIGHTING)
                                    .withStartDate(Date.today() + daysAfterToday)
                                    .insertRecord(false)
                                    .build());
        }

        insert branchWeightings;

        Test.startTest();
        BranchWeightingHelper.updateFeesOnAffectedSessions(branchWeightings);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
        System.assertEquals(initialRate.Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
    }
}
