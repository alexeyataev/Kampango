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
    private static final Integer FEE = 300;

    @TestSetup 
    private static void testSetup() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory.buildOrganizationAccount('acc1')
            .createEnquiryPSA()
            .buildBranchAccountWithEnquiryPSA()
            .buildPractitioner(PRACTITIONER_LASTNAME)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourseWithFee(FEE)
            .buildEstimatedCosts()
            .buildSession();
        List<Session__c> sessions = [
            SELECT Id FROM Session__c WHERE Type__c = 'Standard' AND Status__c != 'Confirmed'
        ];
        dataFactory.setSessionsToConfirmed(sessions)
            .buildReunion()
            .setCourseToFinal()
            .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
            .buildPartnertHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
            .buildBooking('Enquiry');
        List<Session__c> sessionsReunion = [
            SELECT Id FROM Session__c WHERE Type__c = 'Reunion' AND Status__c != 'Confirmed'
        ];
        dataFactory.setSessionsToConfirmed(sessionsReunion);
    }

    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_BookingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        Course__c courseBeforeRecalculations = [
            SELECT Id, Total_Actual_Income__c, Fee__c
            FROM Course__c
            LIMIT 1
        ];

        List<Booking__c> bookings = [
            SELECT Id, Status__c
            FROM Booking__c 
            WHERE Course__c = :courseBeforeRecalculations.Id
        ];

        User user = TestDataFactory.getActiveTestUserByProfileName(PROFILE_NAME);

        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            for (Booking__c booking : bookings) {
                booking.Status__c = 'Confirmed';
            }
            update bookings;
        }

        Test.startTest();
            for (Booking__c booking : bookings) {
                dlrs.RollupService.testHandler(booking);
            }
        Test.stopTest();

        Course__c courseAfterRecalculations = [
            SELECT Id, Total_Actual_Income__c
            FROM Course__c
            LIMIT 1
        ];

        System.assertEquals(0, courseBeforeRecalculations.Total_Actual_Income__c);
        System.assertEquals(courseBeforeRecalculations.Fee__c * bookings.size(), courseAfterRecalculations.Total_Actual_Income__c);
    }
}