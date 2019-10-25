@isTest
public with sharing class SessionFeeHelperTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final Integer COURSES_TO_BUILD = 2;
    private static final Integer SESSIONS_TO_BUILD_ON_EACH_COURSE = 6;
    
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
                    .buildPractitionerFeeRate()
                    .buildPractitionerBands()
                    .buildBranchWeighting();

    }

    @isTest
    private static void PassInListOfSessions_WithoutFeesAlreadyAssigned_AppropriateFeesAssigned(){
        List<Session__c> sessionsToTest = [SELECT Id FROM Session__c];

        List<Practitioner_Fee_Rate__c> feeRates = [SELECT Id FROM Practitioner_Fee_Rate__c];

        Test.startTest();
        List<Session__c> sessionsTestResult = SessionFeeHelper.assignFeeRatesToSessions(sessionsToTest);
        Test.stopTest();

        System.assertEquals(feeRates[0].Id, sessionsTestResult[0].Practitioner_Fee_Rate__c);
    }
    
    @isTest
    private static void FeesAlreadyAssigned_CreateNewPractitionerBand_SessionsCorrectlyReassigned(){

    }

    @isTest
    private static void FeesAlreadyAssigned_CreateNewBranchWeighting_SessionsCorrectlyReassigned(){

    }

    @isTest
    private static void FeesAlreadyAssigned_CreateNewPractitionerFeeRate_SessionsCorrectlyReassigned(){

    }
}
