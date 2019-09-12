@IsTest
public with sharing class CourseDetailControllerTest {

    @TestSetup
    static void createTestData(){
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account branchAccount = accountBuilder
            .withRecordType('Branch')
            .insertRecord(true)
            .build();
        Account organizationAccount =  accountBuilder
            .withRecordType('Organization')
            .withName('John Smith')
            .withType('Supplier')
            .withAccountNumber('acc123')
            .withBillingEmail('billingEmail@ncttest.com')
            .withBillingPostalCode('qwerty')
            .insertRecord(true)
            .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact contact = contactBuilder
            .withRecordType('Practitioner')
            .withAccount(organizationAccount)
            .insertRecord(true)
            .build();
        TestLicenceToPracticeBuilder lisenceBuilder = new TestLicenceToPracticeBuilder();
        Licence_To_Practice__c lisence = lisenceBuilder.withContact(contact)
            .withStartDate(System.today())
            .withStatus('Full')
            .withLicence('Signature Antenatal Teacher')
            .insertRecord(true)
            .build();
            TestCourseBuilder courseBuilder = new TestCourseBuilder();
        List<Course__c> courses = new List<Course__c>{
            courseBuilder.withType('Postnatal')
            .withSubType('Baby Massage')
            .withFee(100)
            .withNumberOfPlaces(15)
            .withStatus('Draft')
            .withAccount(branchAccount)
            .withLicenceToPractice(lisence)
            .withPractitioner(contact)
            .insertRecord(false)
            .build(),
            courseBuilder.withType('Antenatal')
            .withSubType('Waterbirth')
            .withFee(120)
            .withNumberOfPlaces(10)
            .withStatus('Draft')
            .withAccount(branchAccount)
            .withLicenceToPractice(lisence)
            .withPractitioner(contact)
            .insertRecord(false)
            .build()
        };
        insert courses;
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
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        Room__c room = roomBuilder.withVenue(venues[0])
            .insertRecord(true)
            .build();
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        List<Session__c> sessions = new List<Session__c>();
        for(Integer i = 0; i < 12; i++){
            sessions.add(
                sessionBuilder.withPractitioner(contact)
                .withName('Test session')
                .withType('Standard')
                .withDate(System.today())
                .withPractitionerLicence(lisence)
                .withVenue(venues[0])
                .withCourse(courses[(Integer)Math.floor(Math.mod(i, 2))])
                .withRoom(room)
                .insertRecord(false)
                .build()
            );
        }
        insert sessions;
    }

    @IsTest
    private static void retrieveRelatedSessions_passValidCourseId_sessionsRetrieved(){
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Postnatal'].Id;
        Test.startTest();
        sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();
        System.assert(sessions.size() > 0);
        System.assert(sessions.size() != 20);
    }

    @IsTest
    private static void retrieveRelatedSessions_passInvalidCourseId_sessionsNotRetrieved(){
        List<Session__c> sessions = new List<Session__c>();
        String courseId = [SELECT Id FROM Course__c WHERE Type__c = 'Postnatal'].Id;
        courseId = courseId.left(10) + '11111111';
        Test.startTest();
        sessions = CourseDetailController.retrieveRelatedSessions(courseId);
        Test.stopTest();
        System.assert(sessions.isEmpty());
    }


}
