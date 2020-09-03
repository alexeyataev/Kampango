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
            .buildCourseWithTypeAndSubType('Antenatal', 'One to One')
            .buildEstimatedCosts()
            .buildSession();
        List<Session__c> sessions = [
            SELECT Id FROM Session__c WHERE Type__c = 'Standard' AND Status__c != 'Confirmed'
        ];
        testDataFactory.setSessionsToConfirmed(sessions)
            .buildReunion()
            .setCourseToFinal()
            .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
            .buildPartnertHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
            .buildBooking('Enquiry');
        List<Session__c> sessionsReunion = [
            SELECT Id FROM Session__c WHERE Type__c = 'Reunion' AND Status__c != 'Confirmed'
        ];
        testDataFactory.setSessionsToConfirmed(sessionsReunion);
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
        String bookingId = [SELECT Id FROM Booking__c][0].Id;

        Test.startTest();
            List<Booking__c> bookingCourseInformationList = CourseDetailController.getCourseDetailsInformation(bookingId);
        Test.stopTest();

        System.assert(bookingCourseInformationList.size() == 1, 'List should have one record');
        System.assert(bookingCourseInformationList[0].Id == bookingId, 'BookingId should be equals');
        System.assert(bookingCourseInformationList[0].Final_Fee__c == 100, 'Final Fee should be equals 100');
        System.assert(bookingCourseInformationList[0].Last_Name__c == HOST_LASTNAME, 'LastName should be equals');
    }

    @IsTest
    private static void retriveCourseDetailsById_passInvalidBookingId_courseDetailsNotRetrieved() {
        String bookingId = [SELECT Id FROM Booking__c][0].Id;
        bookingId = bookingId.left(10) + '11111111';

        Test.startTest();
            List<Booking__c> bookingCourseInformationList = CourseDetailController.getCourseDetailsInformation(bookingId);
        Test.stopTest();

        System.assert(bookingCourseInformationList.isEmpty(), 'Booking list should be empty');
    }
}