@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #41 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public  class BookingStatusFlowHelperTest {
    private static final String BOOKING_STATUS_RESERVED = 'Reserved';
    private static final String BOOKING_STATUS_EXPIRED = 'Expired';
    private static final String BOOKING_STATUS_ENQUIRY = 'Enquiry';
    private static final String PROFILE_NAME = 'Enquiry PSA';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';
    
    @TestSetup
    static void setupData() {
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account branch =  accountBuilder.withRecordType('Branch')
            .withName('Test Branch')
            .withBillingPostalCode('2344 B234')
            .insertRecord(true)
            .build();
        accountBuilder = new TestAccountBuilder();
        Account organization = accountBuilder.withRecordType('Organization')
            .withName('Test Organization')           
            .withType('Supplier')
            .insertRecord(true)
            .withBillingEmail('test@test.com')
            .withAccountNumber('test acc number')
            .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact contact = contactBuilder.withRecordType('Practitioner')
            .withAccount(organization)
            .withFirstName('Fname')
            .withLastName('Lname')
            .insertRecord(true)
            .build();
        TestPractitionerFeeRateBuilder feeRateBuilder = new TestPractitionerFeeRateBuilder();
        Practitioner_Fee_Rate__c practitionerFeeRate = feeRateBuilder
            .withBand('A')
            .withWeighting('Standard')
            .insertRecord(true)
            .build();
        TestLicenceToPracticeBuilder lisenceBuilder = new TestLicenceToPracticeBuilder();
        Licence_To_Practice__c lisence = lisenceBuilder.withContact(contact)
            .withStartDate(System.today())
            .withStatus('Full')
            .withLicence('Signature Antenatal Teacher')
            .insertRecord(true)
            .build();
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        List<Venue__c> venues = new List<Venue__c>{
            venueBuilder.withName('Venue1')
            .insertRecord(false)
            .build(),
            venueBuilder.withName('Venue2')
            .insertRecord(false)
            .build()
        };
        insert venues;
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        Course__c course = courseBuilder.withType('Postnatal')
            .withSubType('NCT Baby Massage course')
            .withFee(100)
            .withNumberOfPlaces(15)
            .withStatus('Draft')
            .withAccount(branch)
            .withLicenceToPractice(lisence)
            .withPractitioner(contact)
            .withMainVenue(venues[0])
            .insertRecord(false)
            .build();
        insert course;
        Account household = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Test Household'
        );
        insert household;
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(household)
            .withFirstName('Test')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(household)
            .withFirstName('Test')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        Room__c room = roomBuilder.withVenue(venues[0])
            .insertRecord(true)
            .build();
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        List<Session__c> sessions = new List<Session__c>();
        for(Integer i = 0; i < 12; i++){
            sessions.add(
                sessionBuilder.withPractitioner(contact)
                .withType('Standard')
                .withDate(System.today().addDays(11))
                .withPractitionerLicence(lisence)
                .withPractitionerFeeRate(practitionerFeeRate)
                .withVenue(venues[0])
                .withCourse(course)
                .withRoom(room)
                .insertRecord(false)
                .build()
            );
        }
        insert sessions;
        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        List<Booking__c> bookings = new List<Booking__c>{
            bookingBuilder.withCourse(course)
            .withStatus(BOOKING_STATUS_ENQUIRY)
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(-10))
            .insertRecord(false)
            .build(),
            bookingBuilder.withCourse(course)
            .withStatus(BOOKING_STATUS_ENQUIRY)
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(10))
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

        for(Integer i = 0; i < bookings.size(); i++){
            if (Math.mod(i, 2) == 0) {
                bookings.get(i).Reservation_Expiry_Date__c += 1;
                bookings.get(i).Status__c = BOOKING_STATUS_RESERVED;
            }
            bookings.get(i).Status__c = BOOKING_STATUS_EXPIRED;
        }

        User user = [
            SELECT Id 
            FROM User
            WHERE Profile.Name = :PROFILE_NAME
            LIMIT 1
        ];

        System.runAs ( TestDataFactory.assignPermissionSetToUser(PERMISSION_SET_NAME, user) ) {
            update bookings;
        }
        
        Test.startTest();
        BookingStatusFlowHelper.updateBookings(new List<List<Booking__c>>{bookings});
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Booking__c WHERE Status__c = :BOOKING_STATUS_EXPIRED].size());
        System.assertEquals(1, [SELECT Id FROM Booking__c WHERE Status__c = :BOOKING_STATUS_RESERVED].size());
    }
}
