//@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #xxx - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class ExistingBookingLocatorTest {
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String HOST_LASTNAME_TWO = 'Brown';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String BOOKING_STATUS = 'Enquiry';

    @TestSetup
    private static void SetupTestData() {
    TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME_TWO, HOST_EMAIL_ADDRESS)
                    .buildBooking(BOOKING_STATUS);
    }

    @IsTest
    public static void BookingRecordDoesNotExist_BookingIdIsNull() {
        List<Booking__c> bookings = [
            SELECT Id
            FROM Booking__c 
        ];
        delete bookings;

        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE LastName = :HOST_LASTNAME
        ];

        List<Course__c> courses = [
            SELECT Id
            FROM Course__c 
        ];

        ExistingBookingLocator.Request testRequest = new ExistingBookingLocator.Request();
        testRequest.contactId = contacts[0].Id;
        testRequest.courseId = courses[0].Id;
        List<ExistingBookingLocator.Request> requestList = new List<ExistingBookingLocator.Request>();
        requestList.add(testRequest);
        
        Test.startTest();
        List<ExistingBookingLocator.Response> testResponseList = ExistingBookingLocator.findExistingBooking(requestList); 
        Test.stopTest();

        System.assertEquals(null, testResponseList[0].bookingId);
    }

    @IsTest
    public static void OneBookingRecordExists_BookingIdReturned() {
        List<Booking__c> bookings = [
            SELECT Id
            FROM Booking__c 
        ];

        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE LastName = :HOST_LASTNAME
        ];

        List<Course__c> courses = [
            SELECT Id
            FROM Course__c 
        ];

        ExistingBookingLocator.Request testRequest = new ExistingBookingLocator.Request();
        testRequest.contactId = contacts[0].Id;
        testRequest.courseId = courses[0].Id;
        List<ExistingBookingLocator.Request> requestList = new List<ExistingBookingLocator.Request>();
        requestList.add(testRequest);
        
        Test.startTest();
        List<ExistingBookingLocator.Response> testResponseList = ExistingBookingLocator.findExistingBooking(requestList); 
        Test.stopTest();

        System.assertEquals(bookings[0].Id, testResponseList[0].bookingId, 'Existing Booking record hasn\'t found');
    }

    @IsTest
    public static void EnquiryQuickBookBookingRecordsExist_QuickBookBookingIdReturned() {
        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE LastName = :HOST_LASTNAME 
        ];

        List<Course__c> courses = [
            SELECT Id
            FROM Course__c 
        ];

        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        Booking__c quickBookBooking = bookingBuilder.withCourse(courses[0])
            .withStatus(BOOKING_STATUS)
            .withPrimaryContact(contacts[0])
            .withPartnerContact(contacts[0])
            .withBookingExpiryDate(System.today().addDays(3))
            .withSource('Quick Book')
            .ignoreDuplicateRules(true)
            .insertRecord(true)
            .build();

        ExistingBookingLocator.Request testRequest = new ExistingBookingLocator.Request();
        testRequest.contactId = contacts[0].Id;
        testRequest.courseId = courses[0].Id;
        List<ExistingBookingLocator.Request> requestList = new List<ExistingBookingLocator.Request>();
        requestList.add(testRequest);
        
        Test.startTest();
        List<ExistingBookingLocator.Response> testResponseList = ExistingBookingLocator.findExistingBooking(requestList); 
        Test.stopTest();

        System.assertEquals(quickBookBooking.Id, testResponseList[0].bookingId);
    }

    @IsTest
    public static void SeveralBookingRecordsExist_BookingIdIsNull() {
        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE LastName = :HOST_LASTNAME 
        ];

        List<Course__c> courses = [
            SELECT Id
            FROM Course__c 
        ];

        List<Booking__c> bookingToInsert = new List<Booking__c>();
        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        for (Integer i = 0; i < 5; i++) {
            bookingToInsert.add(bookingBuilder.withCourse(courses[0])
                .withStatus(BOOKING_STATUS)
                .withPrimaryContact(contacts[0])
                .withPartnerContact(contacts[0])
                .withBookingExpiryDate(System.today().addDays(3))
                .withSource('Quick Book')
                .ignoreDuplicateRules(true)
                .insertRecord(false)
                .build());            
        }
        insert bookingToInsert;
    
        ExistingBookingLocator.Request testRequest = new ExistingBookingLocator.Request();
        testRequest.contactId = contacts[0].Id;
        testRequest.courseId = courses[0].Id;
        List<ExistingBookingLocator.Request> requestList = new List<ExistingBookingLocator.Request>();
        requestList.add(testRequest);
        
        Test.startTest();
        List<ExistingBookingLocator.Response> testResponseList = ExistingBookingLocator.findExistingBooking(requestList); 
        Test.stopTest();

        System.assertEquals(null, testResponseList[0].bookingId);
    }
}