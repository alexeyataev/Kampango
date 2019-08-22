@isTest
public class SESSION_RevertCourseToDraft_TDTM_TEST {

    private static final String COURSE_DRAFT_STATUS = 'Draft';
    private static final String COURSE_FINAL_STATUS = 'Final';
    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String PRACTITIONER_LASTNAME = 'Practitioner';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Practitioner2';

    private static Account branchAccount;
    private static Contact practitioner;
    private static Venue__c venue;
    private static Room__c room;
    private static Licence_To_Practice__c licenceToPractice;
    private static Course__c course;
    private static Session__c session;

    @TestSetup
    private static void setupTestData() {

        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        branchAccount =  accountBranchBuilder
            .withRecordType('Branch')
            .insertRecord(true)
            .build();

        TestContactBuilder practitionerContactBuilder = new TestContactBuilder();
        practitioner = practitionerContactBuilder
            .withRecordType(PRACTITIONER_RECORDTYPE_NAME)
            .withAccount(branchAccount)
            .withLastName(PRACTITIONER_LASTNAME)
            .insertRecord(true)
            .build();

        practitionerContactBuilder
            .withRecordType(PRACTITIONER_RECORDTYPE_NAME)
            .withAccount(branchAccount)
            .withLastName(PRACTITIONER_LASTNAME_TWO)
            .insertRecord(true)
            .build();

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .insertRecord(true)
            .build();

        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        room = roomBuilder
            .withVenue(venue)
            .insertRecord(true)
            .build();

        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .withContact(practitioner)
            .insertRecord(true)
            .build();

        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .withAccount(branchAccount)
            .withPractitioner(practitioner)
            .withLicenceToPractice(licenceToPractice)
            .insertRecord(true)
            .build();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .withCourse(course)
            .withVenue(venue)
            .withRoom(room)
            .withStatus(SESSION_PROVISIONAL_STATUS)
            .withPractitioner(practitioner)
            .withPractitionerLicence(licenceToPractice)
            .insertRecord(true)
            .build();

        TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
        estimatedCostsBuilder
            .withCourse(course)
            .insertRecord(true)
            .build();
        estimatedCostsBuilder
            .withCourse(course)
            .withType('Venue')
            .insertRecord(true)
            .build();
        estimatedCostsBuilder
            .withCourse(course)
            .withType('Practitioner Fee')
            .insertRecord(true)
            .build();
    }


    @isTest
    static void revertCourseToDraft_NewSessionIsAdded_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Licence_To_Practice__c practitionerLicence = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        Contact practitioner = [SELECT Id FROM Contact WHERE RecordType.Name = 'Practitioner' LIMIT 1];

        test.startTest();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .withCourse(course)
            .withVenue(venue)
            .withRoom(room)
            .withStatus('Provisional')
            .withPractitioner(practitioner)
            .withPractitionerLicence(practitionerLicence)
            .insertRecord(true)
            .build();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_DateUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessions){
            aSession.Date__c = Date.today();
        }
        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }


    @isTest
    static void revertCourseToDraft_StartTimeUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Start__c = Time.newInstance(19, 00, 0, 0);
        }
        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_EndTimeUpdatedOnSession_CourseStatusIsRevertedToDraft () {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.End__c = Time.newInstance(20, 00, 0, 0);
        }

        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_LunchBreakMinutesUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c = 15;
        }

        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);

    }

    @isTest
    static void revertCourseToDraft_PractitionerLicenceUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Contact practitioner = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME LIMIT 1];

        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .withContact(practitioner)
            .insertRecord(true)
            .build();

        for(Session__c aSession :sessions) {
            aSession.Practitioner_Licence__c = licenceToPractice.Id;
        }

        update sessions;


        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_VenueUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .InsertRecord(true)
            .Build();

        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        room = roomBuilder
            .WithVenue(venue)
            .InsertRecord(true)
            .Build();

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Venue__c = venue.Id;
            aSession.Room__c = room.Id;
        }

        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_SessionDeletedOnCourse_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        delete sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_PractitionerUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Contact practitioner2 = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_TWO];
        for(Session__c aSession : sessions) {
            aSession.Practitioner__c = practitioner2.Id;
            aSession.Practitioner_Licence__c = NULL;
            aSession.Status__c = 'Provisional';
        }
        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_StatusUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Status__c = SESSION_PROVISIONAL_STATUS;
        }

        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void changeSessionToProvisional_DateUpdatedOnSession_SessionStatusIsChangedToProvisional() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Date__c = Date.today()+10;
        }

        update sessions;

        test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];

        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void changeSessionToProvisional_StartTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Start__c =  Time.newInstance(18, 00, 0, 0);
        }

        update sessions;

        test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];

        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void changeSessionToProvisional_EndTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.End__c =  Time.newInstance(21, 00, 0, 0);
        }

        update sessions;

        test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];

        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void changeSessionToProvisional_lunchBreakUpdatedOnSession_SessionStatusIsChangedToProvisional() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        TestDataFactory.setSessionsToConfirmed(sessions);

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c =  11;
        }

        update sessions;

        test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];

        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_BulkSessionsChanged_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        TestDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];

        TestDataFactory.setSessionsToConfirmed(sessions);

        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        for (Course__c aCourse : coursesToTest){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        test.startTest();

        for(Session__c aSession : sessions){
            aSession.Start__c = Time.newInstance(12, 00, 0, 0);
        }

        update sessions;

        test.stopTest();

        List<Course__c> draftCoursesAfterUpdate = [SELECT Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_DRAFT_STATUS LIMIT 10];
        List<Session__c> sessionsToTest = [SELECT Status__c FROM Session__c WHERE Status__c =:SESSION_PROVISIONAL_STATUS];

        System.assertEquals(coursesToTest.size(), draftCoursesAfterUpdate.size());
        System.assertEquals(sessionsToCreate + 1, sessionsToTest.size());
    }


    @isTest
    static void revertCourseToDraft_BulkSessionsDeleted_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        TestDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];

        TestDataFactory.setSessionsToConfirmed(sessions);

        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        for (Course__c aCourse : coursesToTest){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        test.startTest();

        delete sessions;

        test.stopTest();

        List<Course__c> draftCoursesAfterUpdate = [SELECT Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_DRAFT_STATUS LIMIT 10];

        System.assertEquals(coursesToTest.size(), draftCoursesAfterUpdate.size());
    }

    private static void createTriggerSystemHandlerRecord() {

        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete;BeforeUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
    }

}