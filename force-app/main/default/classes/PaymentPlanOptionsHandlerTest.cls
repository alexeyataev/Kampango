@isTest
public class PaymentPlanOptionsHandlerTest {
    private static final Integer COURSE_FEE = 200;
    private static Integer initialPaymentDayNumber = 5;
    private static Date THIS_MONTH_START_DATE = Date.today().toStartOfMonth();
    private static Integer thisMonthDiff = 0;
    private static final Integer START_DATE_MONTHS_LEFT = 6;
    @testSetup
    static void createPaymentParamRecords() {
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account branch =  accountBuilder.withRecordType('Branch')
            .withName('Test Branch')
            .withBillingPostalCode('AB12 3CD')
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
            .withAccountNumber('123456')
            .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Jane')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        Contact practitioner = contactBuilder.withRecordType('Practitioner')
            .withAccount(organization)
            .withFirstName('Jack')
            .withLastName('Practitioner')
            .insertRecord(true)
            .build();
        TestLicenceToPracticeBuilder lisenceBuilder = new TestLicenceToPracticeBuilder();
        Licence_To_Practice__c lisence = lisenceBuilder.withContact(practitioner)
            .withStartDate(THIS_MONTH_START_DATE)
            .withStatus('Full')
            .withLicence('Signature Antenatal Teacher')
            .insertRecord(true)
            .build();
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        Venue__c venue = venueBuilder.withName('Venue1')
            .insertRecord(true)
            .build();
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        Course__c course = courseBuilder.withType('Postnatal')
            .withSubType('NCT Baby Massage')
            .withFee(COURSE_FEE)
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
            .withBookingExpiryDate(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber))
            .insertRecord(true)
            .build();
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        Room__c room = roomBuilder.withVenue(venue)
            .insertRecord(true)
            .build();
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        sessionBuilder.withPractitioner(practitioner)
            .withType('Standard')
            .withDate(THIS_MONTH_START_DATE.addMonths(START_DATE_MONTHS_LEFT))
            .withPractitionerLicence(lisence)
            .withVenue(venue)
            .withCourse(course)
            .withRoom(room)
            .insertRecord(true)
            .build();
    }
    @isTest
    static void testCourseFeeLessThanMinimum() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 300;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 100;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 0);
        Test.stopTest();
    }
    @isTest
    static void testNextMonthFirstRecurringPayment() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 30;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 10;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addMonths(1)));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(3);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].label, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void testAfterNextMonthFirstRecurringPayment() {
        initialPaymentDayNumber = 25;
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 30;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 10;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber).addMonths(2).toStartOfMonth()));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(4);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].label, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void testDatesOneRecurringPayment() {
        thisMonthDiff = 4;
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 30;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 10;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addMonths(thisMonthDiff);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber).addMonths(thisMonthDiff + 1).toStartOfMonth()));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(5);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        Test.stopTest();
    }
    @isTest
    static void testDatesTwoRecurringPayment() {
        thisMonthDiff = 3;
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 30;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 10;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addMonths(thisMonthDiff);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber).addMonths(thisMonthDiff + 1).toStartOfMonth()));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(5);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        Test.stopTest();
    }
    @isTest
    static void testFeeOneRecurringPayment() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 150;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 49;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addMonths(thisMonthDiff);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber).addMonths(1).toStartOfMonth()));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(1);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '1 payment of £ 150.00 and 1 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void testFeeTwoRecurringPayments() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 100;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 49;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addMonths(thisMonthDiff);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber).addMonths(1).toStartOfMonth()));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(2);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].label, '1 payment of £ 100.00 and 2 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void testFeeThreeRecurringPayments() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 80;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 39;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addMonths(thisMonthDiff);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber).addMonths(1).toStartOfMonth()));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(3);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].label, '1 payment of £ 80.00 and 2 monthly payment of £ 60.00');
        System.assertEquals(options[2].label, '1 payment of £ 80.00 and 3 monthly payment of £ 40.00');
        Test.stopTest();
    }
    @isTest
    static void testFeeThreeEqualRecurringPayments() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimal_First_Amount__c = 50;
        cardPaymentPlanSettings.Minimal_Recurring_Amount__c = 40;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
        PaymentPlanOptionsHandler.firstPaymentDate = THIS_MONTH_START_DATE.addMonths(thisMonthDiff);
        Test.startTest();
        Booking__c booking = [SELECT Id, Course__c, Primary_Contact__c FROM Booking__c LIMIT 1];
        Course__c course = [SELECT Id, Start_Date__c, Fee__c FROM Course__c WHERE Id =: booking.Course__c LIMIT 1];
        PaymentPlanParameters paymentPlanParameters = new PaymentPlanParameters();
        paymentPlanParameters.bookingId = booking.Id;
        paymentPlanParameters.courseFee = course.Fee__c;
        paymentPlanParameters.contactId = booking.Primary_Contact__c;
        paymentPlanParameters.startDate = course.Start_Date__c;
        List<PaymentPlanOption> options = PaymentPlanOptionsHandler.getOptions(new List<PaymentPlanParameters> {paymentPlanParameters})[0];
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, String.valueOf(THIS_MONTH_START_DATE.addDays(initialPaymentDayNumber).addMonths(1).toStartOfMonth()));
        Date lastPaymentDate = THIS_MONTH_START_DATE.addMonths(3);
        System.assertEquals(options[0].endDate, String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1));
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].label, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
}