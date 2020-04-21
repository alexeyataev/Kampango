@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #74 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class SetBookingReservationExpiryDateTest {
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';

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
    private static void SetBookingReservationExpiryDate_SolidsCourseStartsIn5Days_ExpirationDateCourseStartDateMinus1(){

        Course__c course = [
			SELECT Type__c, Start_Date__c, Sub_Type__c
			FROM Course__c
			LIMIT 1
        ];

        course.Type__c = 'Postnatal';
        course.Sub_Type__c = 'NCT Introducing Solid Foods workshop';
        update course;

		List<Booking__c> bookingsBeforeRecalculations = [
			SELECT Reservation_Expiry_Date__c, Status__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];

        Test.startTest();
        for (Booking__c booking : bookingsBeforeRecalculations) {
            booking.Status__c = 'Reserved';
        }
        update bookingsBeforeRecalculations;
        Test.stopTest();

        List<Booking__c> bookingsAfterRecalculations = [
			SELECT Reservation_Expiry_Date__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];
        
        System.assertEquals(null, bookingsBeforeRecalculations[0].Reservation_Expiry_Date__c);
        System.assertEquals(course.Start_Date__c - 1, bookingsAfterRecalculations[0].Reservation_Expiry_Date__c);
    }

    @IsTest
    private static void SetBookingReservationExpiryDate_SolidsCourseStartsIn7Days_ExpirationDateIn5Days(){

        Course__c course = [
			SELECT Type__c, Sub_Type__c
			FROM Course__c
			LIMIT 1
        ];

        course.Type__c = 'Postnatal';
        course.Sub_Type__c = 'NCT Introducing Solid Foods workshop';
        update course;

        List<Session__c> sessions = [
            SELECT Date__c 
            FROM Session__c 
            WHERE Course__c = :course.Id
            ];
        
        for (Session__c session : sessions) {
            session.Date__c = Date.today().addDays(7);                        
        }
        update sessions;

		List<Booking__c> bookingsBeforeRecalculations = [
			SELECT Reservation_Expiry_Date__c, Status__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];

        Test.startTest();
        for (Booking__c booking : bookingsBeforeRecalculations) {
            booking.Status__c = 'Reserved';
        }
        update bookingsBeforeRecalculations;
        Test.stopTest();

        List<Booking__c> bookingsAfterRecalculations = [
			SELECT Reservation_Expiry_Date__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];
        
        System.assertEquals(null, bookingsBeforeRecalculations[0].Reservation_Expiry_Date__c);
        System.assertEquals(Date.today().addDays(5), bookingsAfterRecalculations[0].Reservation_Expiry_Date__c);
    }

    @IsTest
    private static void SetBookingReservationExpiryDate_NonSolidsCourseStartsIn5Days_ExpirationDateCourseStartDateMinus1(){

        Course__c course = [
			SELECT Type__c, Start_Date__c, Sub_Type__c
			FROM Course__c
			LIMIT 1
        ];

		List<Booking__c> bookingsBeforeRecalculations = [
			SELECT Reservation_Expiry_Date__c, Status__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];

        Test.startTest();
        for (Booking__c booking : bookingsBeforeRecalculations) {
            booking.Status__c = 'Reserved';
        }
        update bookingsBeforeRecalculations;
        Test.stopTest();

        List<Booking__c> bookingsAfterRecalculations = [
			SELECT Reservation_Expiry_Date__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];
        
        System.assertEquals(null, bookingsBeforeRecalculations[0].Reservation_Expiry_Date__c);
        System.assertEquals(course.Start_Date__c - 1, bookingsAfterRecalculations[0].Reservation_Expiry_Date__c);
    }

    @IsTest
    private static void SetBookingReservationExpiryDate_NonSolidsCourseStartsIn12Days_ExpirationDateIn10Days(){

        Course__c course = [
			SELECT Type__c, Sub_Type__c
			FROM Course__c
			LIMIT 1
        ];

        List<Session__c> sessions = [
            SELECT Date__c 
            FROM Session__c 
            WHERE Course__c = :course.Id
            ];
        
        for (Session__c session : sessions) {
            session.Date__c = Date.today().addDays(12);                        
        }
        update sessions;

		List<Booking__c> bookingsBeforeRecalculations = [
			SELECT Reservation_Expiry_Date__c, Status__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];

        Test.startTest();
        for (Booking__c booking : bookingsBeforeRecalculations) {
            booking.Status__c = 'Reserved';
        }
        update bookingsBeforeRecalculations;
        Test.stopTest();

        List<Booking__c> bookingsAfterRecalculations = [
			SELECT Reservation_Expiry_Date__c
            FROM Booking__c 
            WHERE Course__c = :course.Id
		];
        
        System.assertEquals(null, bookingsBeforeRecalculations[0].Reservation_Expiry_Date__c);
        System.assertEquals(Date.today().addDays(10), bookingsAfterRecalculations[0].Reservation_Expiry_Date__c);
    }
}
