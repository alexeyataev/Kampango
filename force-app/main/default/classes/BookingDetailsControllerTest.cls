@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #35 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class BookingDetailsControllerTest {
    
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String PROFILE_NAME = 'Enquiry PSA';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';
    private static final String BOOKING_STATUS_CONFIRMED = 'Confirmed';

    @TestSetup
    private static void SetupTestData() {
    TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourseWithStatus('Final')
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildSessionWithTypeAndStatus('Reunion', 'Confirmed')
                    .buildBooking('Enquiry');
    }

    @IsTest
    public static void getBookings_oneBookingCreated_componentShowOneBooking() {

        Course__c course = [
            SELECT Id
            FROM Course__c
            LIMIT 1
        ];

        List<Booking__c> bookings = [
            SELECT Id, Status__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
        ];

        User user = TestDataFactory.getActiveTestUserByProfileName(PROFILE_NAME);

        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            bookings[0].Status__c = BOOKING_STATUS_CONFIRMED;
            update bookings;
        }

        BookingDetailsController bookingDetailsController = new BookingDetailsController();
        bookingDetailsController.courseRecord = course;
        bookingDetailsController.bookingFieldSetName= 'CourseSummaryBookingFields';
        bookingDetailsController.bookingContactFieldSetName = 'CourseSummaryBookingPrimaryContactFields';

        Test.startTest();
            List<Booking__c> bookingsToTest = bookingDetailsController.getBookings();
        Test.stopTest();

        System.assertEquals(1, bookingsToTest.size(), 'List should not be empty');
        System.assertEquals(bookings[0].Id, bookingsToTest[0].Id, 'Ids should be equals');

    }

    @IsTest
    public static void getBookings_componentLoadsOneBooking_correctBookingContactLoaded() {
        Course__c course = [
            SELECT Id
            FROM Course__c
            LIMIT 1
        ];

    List<Booking__c> bookings = [
        SELECT Id, Status__c, Primary_Contact__c, Partner_Contact__c
        FROM Booking__c 
        WHERE Course__c = :course.Id
        ];

        User user = TestDataFactory.getActiveTestUserByProfileName(PROFILE_NAME);

        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            bookings[0].Status__c = BOOKING_STATUS_CONFIRMED;
            update bookings;
        }

        BookingDetailsController bookingDetailsController = new BookingDetailsController();
        bookingDetailsController.courseRecord = course;
        bookingDetailsController.bookingFieldSetName= 'CourseSummaryBookingFields';
        bookingDetailsController.bookingContactFieldSetName = 'CourseSummaryBookingPrimaryContactFields';

        Test.startTest();
            bookingDetailsController.getBookings();
        Test.stopTest();

        System.assertNotEquals(null, bookingDetailsController.bookingContacts.get(bookings[0].Primary_Contact__c));

    }
}