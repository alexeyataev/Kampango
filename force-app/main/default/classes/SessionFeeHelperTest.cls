@isTest
public with sharing class SessionFeeHelperTest {

    private static final String PRACTITIONER_LASTNAME_ONE = 'Smith';
    private static final Integer COURSES_TO_BUILD = 2;
    private static final Integer SESSIONS_TO_BUILD_ON_EACH_COURSE = 6;
    
    @TestSetup
    private static void SetupTestData(){
        TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc1')
            .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCoursesWithSessions(COURSES_TO_BUILD, SESSIONS_TO_BUILD_ON_EACH_COURSE);     
    }

    @isTest
    static void PassInListOfSessions_WithoutFeesAlreadyAssigned_AppropriateFeesAssigned(){

    }
}
