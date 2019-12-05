@isTest
public class PaymentPlanOptionsHandlerTest {

    @testSetup
    static void createPaymentParamRecords() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 30;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 10;
        insert cardPaymentPlanSettings;
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account branch =  accountBuilder.withRecordType('Branch')
            .withName('Test Branch')
            .withBillingPostalCode('qwerty')
            .insertRecord(true)
            .build();
        Account account =  accountBuilder
            .withRecordType('Household Account')
            .insertRecord(true)
            .build();
        Account organization = accountBuilder.withRecordType('Organization')
            .withName('Test Organization')           
            .withType('Supplier')
            .insertRecord(true)
            .withBillingEmail('test@test.com')
            .withAccountNumber('test acc number')
            .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        Contact practitioner = contactBuilder.withRecordType('Practitioner')
            .withAccount(organization)
            .withFirstName('Fname')
            .withLastName('Lname')
            .insertRecord(true)
            .build();
        TestLicenceToPracticeBuilder lisenceBuilder = new TestLicenceToPracticeBuilder();
        Licence_To_Practice__c lisence = lisenceBuilder.withContact(practitioner)
            .withStartDate(System.today())
            .withStatus('Full')
            .withLicence('Signature Antenatal Teacher')
            .insertRecord(true)
            .build();
            TestCourseBuilder courseBuilder = new TestCourseBuilder();
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        Venue__c venue = venueBuilder.withName('Venue1')
            .insertRecord(true)
            .build();
        Course__c course = courseBuilder.withType('Postnatal')
            .withSubType('NCT Baby Massage')
            .withFee(200)
            .withNumberOfPlaces(15)
            .withStatus('Draft')
            .withAccount(branch)
            .withLicenceToPractice(lisence)
            .withPractitioner(practitioner)
            .withMainVenue(venue)
            .insertRecord(true)
            .build();
        TestBookingBuilder bookingBuilder = new TestBookingBuilder();
        Booking__c bookings = bookingBuilder.withCourse(course)
            .withStatus('Reserved')
            .withPrimaryContact(primaryContact)
            .withPartnerContact(partnerContact)
            .withBookingExpiryDate(System.today().addDays(-10))
            .insertRecord(true)
            .build();
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        Room__c room = roomBuilder.withVenue(venue)
            .insertRecord(true)
            .build();
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        sessionBuilder.withPractitioner(practitioner)
            .withType('Standard')
            .withDate(System.today().addDays(200))
            .withPractitionerLicence(lisence)
            .withVenue(venue)
            .withCourse(course)
            .withRoom(room)
            .insertRecord(true)
            .build();
    }
    @isTest
    static void testGetOptions() {
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParam paymentPlanParam = new PaymentPlanParam();
        paymentPlanParam.bookingId = booking.Id;
        paymentPlanParam.courseFee = course.Fee__c;
        paymentPlanParam.contactId = booking.Primary_Contact__c;
        paymentPlanParam.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParam> {paymentPlanParam})[0];
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].label, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
}