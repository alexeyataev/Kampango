@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #71 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_BookingTest
{

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String PROFILE_NAME = 'Enquiry PSA';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';

    @TestSetup 
    private static void testSetup() {
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
                    .buildBooking('Enquiry');
    }

    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_BookingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
            
        Course__c courseBeforeRecalculations = [
			SELECT Id, Total_Actual_Income__c
			FROM Course__c
			LIMIT 1
		];

		List<Booking__c> bookings = [
			SELECT Id, Status__c
            FROM Booking__c 
            WHERE Course__c = :courseBeforeRecalculations.Id
		];

        User user = [
            SELECT Id 
            FROM User
            WHERE Profile.Name = :PROFILE_NAME
            LIMIT 1
        ];
        
        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            bookings[0].Status__c = 'Confirmed';
            update bookings;
        }

        Test.startTest();
        dlrs.RollupService.testHandler(bookings.get(0));
        Test.stopTest();

        Course__c courseAfterRecalculations = [
			SELECT Id, Total_Actual_Income__c
			FROM Course__c
			LIMIT 1
        ];
        
        System.assertEquals(0, courseBeforeRecalculations.Total_Actual_Income__c);
        System.assertNotEquals(0, courseAfterRecalculations.Total_Actual_Income__c);
    }
}