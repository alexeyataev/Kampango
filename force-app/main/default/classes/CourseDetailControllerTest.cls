@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #39 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public with sharing class CourseDetailControllerTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';

    @TestSetup
    static void createTestData(){

        Integer coursesToCreate = 4;
        Integer provisionSessionsToCreate = 5;
        Integer confirmedSessionsToCreate = 5;

        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc1')
            .buildPractitioner(PRACTITIONER_LASTNAME)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCoursesWithChoseNumberAndStatusSessions(coursesToCreate, provisionSessionsToCreate,confirmedSessionsToCreate)
            .buildCourse()
            .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
            .buildPartnertHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
            .buildSessionWithTypeAndStatus('Reunion', 'Confirmed')
            .buildBooking('Enquiry');
    }

    @IsTest
    private static void retrieveRelatedSessions_passValidCourseId_sessionsRetrieved() {
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Antenatal' LIMIT 1].Id;

        Test.startTest();
            sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();

        System.assert(sessions.size() > 0, 'Session list should not be empty');
    }

    @IsTest
    private static void retrieveRelatedSessions_passInvalidCourseId_sessionsNotRetrieved() {
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Antenatal' LIMIT 1].Id;
        courseId = courseId.left(10) + '11111111';

        Test.startTest();
            sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();

        System.assert(sessions.isEmpty(), 'Session list should be empty');
    }

    @IsTest
    private static void retriveCourseDetailsById_passValidBookingId_courseDetailsRetrieved() {
        String bookignId = [SELECT Id FROM Booking__c][0].Id;

        Test.startTest();
            List<Booking__c> bookingCourseInformationList = CourseDetailController.getCourseDetailsInformation(bookignId);
        Test.stopTest();

        System.assert(bookingCourseInformationList.size() > 0, 'Booking list should not be empty');
    }

    @IsTest
    private static void retriveCourseDetailsById_passInvalidBookingId_courseDetailsNotRetrieved() {
        String bookignId = [SELECT Id FROM Booking__c][0].Id;
        bookignId = bookignId.left(10) + '11111111';

        Test.startTest();
            List<Booking__c> bookingCourseInformationList = CourseDetailController.getCourseDetailsInformation(bookignId);
        Test.stopTest();

        System.assert(bookingCourseInformationList.isEmpty(), 'Booking list should be empty');
    }
}