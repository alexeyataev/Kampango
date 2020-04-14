@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #82 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class SetBookingExpirationStatusFlowTest {
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String RESERVED_STATUS = 'Reserved';
    private static final String EXPIRED_STATUS = 'Expired';

    @TestSetup 
    private static void TestSetup() {
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
                    .buildSessionWithTypeAndStatus('Reunion', 'Confirmed')
                    .buildBookingWithoutExpiryDate('Enquiry');
        List<Session__c> provisionalNonReunionSessions = [
            SELECT Id 
            FROM Session__c 
            WHERE Status__c = 'Provisional' 
                AND Type__c <> 'Reunion'
            ];    

        List<Course__c> listDraftCourses = [
            SELECT Id 
            FROM Course__c 
            WHERE Status__c = 'Draft'];

        dataFactory .SetSessionsToConfirmed(provisionalNonReunionSessions)
                    .SetCoursesToFinal(listDraftCourses);
    }

    @IsTest
    private static void SetBookingStatus_ReservationExpiryDateOverdue_BookingStatusExpired(){

        Course__c course = [
			SELECT Id
			FROM Course__c
			LIMIT 1
        ];

		List<Booking__c> bookings = [
			SELECT Reservation_Expiry_Date__c, Status__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];
        
        bookings[0].Status__c = RESERVED_STATUS;
        bookings[0].Reservation_Expiry_Date__c = System.today().addDays(-5);
        update bookings;

        Test.startTest();
        Map<String, Object> params = new Map<String, Object>();
        Flow.Interview.Set_Booking_Expiration_Status setBookingStatus = new Flow.Interview.Set_Booking_Expiration_Status(params);
        setBookingStatus.start();
        Test.stopTest();

        List<Booking__c> bookingsToTest = [
			SELECT Reservation_Expiry_Date__c, Status__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
        ];

        System.assertEquals(RESERVED_STATUS, bookings[0].Status__c);
        System.assertEquals(EXPIRED_STATUS, bookingsToTest[0].Status__c);
    }
}