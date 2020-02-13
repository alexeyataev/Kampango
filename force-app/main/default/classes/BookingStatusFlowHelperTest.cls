@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #41 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public  class BookingStatusFlowHelperTest {
    private static final String BOOKING_STATUS_RESERVED = 'Reserved';
    private static final String BOOKING_STATUS_EXPIRED = 'Expired';
    private static final String BOOKING_STATUS_ENQUIRY = 'Enquiry';
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String COURSE_STATUS_DRAFT = 'Draft';
    private static final String CLIENT_RECORDTYPE_NAME  = 'Client';
    
    @TestSetup
    static void setupData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourseWithStatus(COURSE_STATUS_DRAFT)
                    .buildEstimatedCosts()
                    .buildSession();
        
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(acc)
            .withFirstName('Lena')
            .withLastName('Primary')
            .insertRecord(true)
            .build();

        Contact partnerContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(acc)
            .withFirstName('John')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        
        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        List<Booking__c> bookings = new List<Booking__c>{
            bookingBuilder.withCourse(course)
            .withStatus(BOOKING_STATUS_ENQUIRY)
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(-2))
            .insertRecord(false)
            .build(),

            bookingBuilder.withCourse(course)
            .withStatus(BOOKING_STATUS_ENQUIRY)
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(2))
            .insertRecord(false)
            .build()
        };

        insert bookings;
    }

    @IsTest
    private static void updateBookins_bookings_partlyUpdate(){
        List<Booking__c> bookings = [
            SELECT Id, Status__c, Reservation_Expiry_Date__c
            FROM Booking__c
        ];

        for(Integer i = 0; i < bookings.size(); i++) {
            if (Math.mod(i, 2) == 0) {
                bookings.get(i).Reservation_Expiry_Date__c += 1;
            }

            bookings.get(i).Status__c = BOOKING_STATUS_ENQUIRY;
        }
        
        Test.startTest();
        BookingStatusFlowHelper.updateBookings(new List<List<Booking__c>>{bookings});
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Booking__c WHERE Status__c = :BOOKING_STATUS_RESERVED].size());
        System.assertEquals(2, [SELECT Id FROM Booking__c WHERE Status__c = :BOOKING_STATUS_ENQUIRY].size());
    }
}
