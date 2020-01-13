@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #35 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class BookingDetailsControllerTest {
    
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String PROFILE_NAME = 'Enquiry PSA';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';

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
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildReunion()
                    .buildBooking('Enquiry');
    }

    @IsTest
	public static void generateCourseSummaryBookingDetails() {

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

        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, PROFILE_NAME) ) {
            bookings[0].Status__c = 'Confirmed';
            update bookings;
        }

		BookingDetailsController bookingDetailsController = new BookingDetailsController();
		bookingDetailsController.courseRecord = course;
        bookingDetailsController.bookingFieldSetName= 'CourseSummaryBookingFields';

		Test.startTest();

		List<BookingDetailsController.BookingResult> bookingsToTest = bookingDetailsController.getBookings();

		Test.stopTest();

		System.assertEquals(bookingsToTest[0].booking.Id, bookings[0].Id);

	}
}