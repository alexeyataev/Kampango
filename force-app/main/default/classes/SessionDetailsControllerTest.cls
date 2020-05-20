@isTest
public with sharing class SessionDetailsControllerTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';

    @TestSetup
    private static void setupTestData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                .buildBranchAccount()
                .buildPractitioner(PRACTITIONER_LASTNAME)
                .buildPractitionerFeeRate()
                .buildVenue()
                .buildRoom()
                .buildLicenceToPractice()
                .buildCourse()
                .buildEstimatedCosts()
                .buildSession();
    }

    @IsTest
    public static void generateCourseSummarySessionsDetails() {

        Course__c course = [
                SELECT Id,
                (
                    SELECT Id
                    FROM Sessions__r
                )
                FROM Course__c
                LIMIT 1
        ];

        SessionDetailsController sessionDetailsController = new SessionDetailsController();
        sessionDetailsController.courseRecord = course;
        sessionDetailsController.sessionFieldSetName = 'CourseSummaryFields';

        Test.startTest();

        List<Session__c> sessionsToTest = sessionDetailsController.getSessions();

        Test.stopTest();

        System.assertEquals(sessionsToTest[0].Id, course.Sessions__r[0].Id);
    }
}
