@IsTest
public  class BookingStatusFlowHelperTest {
    
    @TestSetup
    static void makeData(){
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account branch =  accountBuilder.withRecordType('Branch')
            .withName('Test Branch')
            .withBillingPostalCode('qwerty')
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
        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        List<Booking__c> bookings = new List<Booking__c>{
            bookingBuilder.withCourse(course)
            .withStatus('Reserved')
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(-10))
            .insertRecord(false)
            .build(),
            bookingBuilder.withCourse(course)
            .withStatus('Reserved')
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(10))
            .insertRecord(false)
            .build()
        };
        insert bookings;
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
                .withDate(System.today())
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
    }

    @IsTest
    private static void updateBookinsBookingsPartlyUpdate(){
        List<Booking__c> bookings = [
            SELECT Id, Status__c, Reservation_Expiry_Date__c
            FROM Booking__c
        ];
        for(Booking__c booking :bookings){
            booking.Status__c = 'Expired';
        }
        Test.startTest();
        BookingStatusFlowHelper.updateBookings(new List<List<Booking__c>>{bookings});
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Booking__c WHERE Status__c = 'Expired'].size());
        System.assertEquals(1, [SELECT Id FROM Booking__c WHERE Status__c = 'Reserved'].size());
    }
}
