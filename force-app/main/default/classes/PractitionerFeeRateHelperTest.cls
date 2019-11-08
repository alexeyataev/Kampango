@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #28 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class PractitionerFeeRateHelperTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_BAND = 'A';
    private static final String STANDARD_BRANCH_WEIGHTING = 'Standard';

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
    private static void NewPractitionerFeeRateCreated_SessionFallsIntoDateRange_SessionReassignedToNewFeeRate(){
    
        List<Practitioner_Fee_Rate__c> practitionerFeeRatesToInsert = new List<Practitioner_Fee_Rate__c>();
        TestPractitionerFeeRateBuilder feeRateBuilder = new TestPractitionerFeeRateBuilder();
        practitionerFeeRatesToInsert.add(feeRateBuilder
                                            .withBand(PRACTITIONER_BAND)
                                            .withWeighting(STANDARD_BRANCH_WEIGHTING)
                                            .withStartDate(Date.today())
                                            .insertRecord(true)
                                            .build());

        Test.startTest();
        PractitionerFeeRateHelper.updateFeesOnAffectedSessions(practitionerFeeRatesToInsert);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
        System.assertEquals(practitionerFeeRatesToInsert[0].Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);

    }

    @isTest
    private static void NewPractitionerFeeRateCreated_SessionDoesNotFallIntoDateRange_SessionNotReassignedToNewFeeRate(){

        List<Practitioner_Fee_Rate__c> practitionerFeeRatesToInsert = new List<Practitioner_Fee_Rate__c>();
        TestPractitionerFeeRateBuilder feeRateBuilder = new TestPractitionerFeeRateBuilder();
        practitionerFeeRatesToInsert.add(feeRateBuilder
                                            .withBand(PRACTITIONER_BAND)
                                            .withWeighting(STANDARD_BRANCH_WEIGHTING)
                                            .withStartDate(Date.today() + daysAfterToday)
                                            .insertRecord(true)
                                            .build());
        

        Test.startTest();
        PractitionerFeeRateHelper.updateFeesOnAffectedSessions(practitionerFeeRatesToInsert);
        Test.stopTest();

        List<Session__c> sessionsTestResult = [SELECT Id, Practitioner_Fee_Rate__c FROM Session__c];
        System.assertEquals(null, sessionsTestResult[0].Practitioner_Fee_Rate__c);
    }
}