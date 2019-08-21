@isTest
public class SESSION_RevertCourseToDraft_TDTM_TEST {

    private static final String COURSE_DRAFT_STATUS = 'Draft';
    private static final String COURSE_FINAL_STATUS = 'Final';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String PRACTITIONER_LASTNAME = 'Practitioner2';

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
            .WithRecordType('Branch')
            .InsertRecord(true)
            .Build();

        TestContactBuilder practitionerContactBuilder = new TestContactBuilder();
        practitioner = practitionerContactBuilder
            .WithRecordType(PRACTITIONER_RECORDTYPE_NAME)
            .WithAccount(branchAccount)
            .WithLastName(PRACTITIONER_LASTNAME)
            .InsertRecord(true)
            .Build();

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .InsertRecord(true)
            .Build();

        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        room = roomBuilder
            .WithVenue(venue)
            .InsertRecord(true)
            .Build();

        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .WithContact(practitioner)
            .InsertRecord(true)
            .Build();

        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .WithAccount(branchAccount)
            .WithPractitioner(practitioner)
            .WithLicenceToPractice(licenceToPractice)
            .InsertRecord(true)
            .Build();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .WithCourse(course)
            .WithVenue(venue)
            .WithRoom(room)
            .withStatus('Provisional')
            .withPractitioner(practitioner)
            .withPractitionerLicence(licenceToPractice)
            .InsertRecord(true)
            .Build();

        TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
        estimatedCostsBuilder
            .WithCourse(course)
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course)
            .WithType('Venue')
            .InsertRecord(true)
            .Build();
        estimatedCostsBuilder
            .WithCourse(course)
            .WithType('Practitioner Fee')
            .InsertRecord(true)
            .Build();
    }


    @isTest
    static void revertCourseToDraft_NewSessionIsAdded_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Licence_To_Practice__c practitionerLicence = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        Contact practitioner = [SELECT LastName FROM Contact WHERE RecordType.Name = 'Practitioner' LIMIT 1];

        test.startTest();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .WithCourse(course)
            .WithVenue(venue)
            .WithRoom(room)
            .withStatus('Provisional')
            .withPractitioner(practitioner)
            .withPractitionerLicence(practitionerLicence)
            .InsertRecord(true)
            .Build();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_DateUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessionsMap.values()){
            aSession.Date__c = Date.today();
        }
        update sessionsMap.values();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }


    @isTest
    static void revertCourseToDraft_StartTimeUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessionsMap.values()){
            aSession.Start__c = Time.newInstance(19, 00, 0, 0);
        }
        update sessionsMap.values();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_EndTimeUpdatedOnSession_CourseStatusIsRevertedToDraft () {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessionsMap.values()) {
            aSession.End__c = Time.newInstance(20, 00, 0, 0);
        }

        update sessionsMap.values();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_LunchBreakMinutesUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        for(Session__c aSession : sessionsMap.values()) {
            aSession.Lunch_Break_Minutes__c = 15;
        }

        update sessionsMap.values();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);

    }

    @isTest
    static void revertCourseToDraft_PractitionerLicenceUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Contact practitioner = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME LIMIT 1];

        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .WithContact(practitioner)
            .InsertRecord(true)
            .Build();

        for(Session__c aSession : sessionsMap.values()) {
            aSession.Practitioner_Licence__c = licenceToPractice.Id;
        }

        update sessionsMap.values();


        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_VenueUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
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

        for(Session__c aSession : sessionsMap.values()) {
            aSession.Venue__c = venue.Id;
            aSession.Room__c = room.Id;
        }

        update sessionsMap.values();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void revertCourseToDraft_SessionDeletedOnCourse_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        delete sessionsMap.values();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }


    @isTest
    static void revertCourseToDraft_BulkSessionsChanged_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        TestDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1000]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        for (Course__c aCourse : coursesToTest){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        test.startTest();

        for(Session__c aSession : sessionsMap.values()){
            aSession.Start__c = Time.newInstance(12, 00, 0, 0);
        }

        update sessionsMap.values();

        test.stopTest();

        List<Course__c> draftCoursesAfterUpdate = [SELECT Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_DRAFT_STATUS LIMIT 10];

        System.assertEquals(coursesToTest.size(), draftCoursesAfterUpdate.size());
    }

    @isTest
    static void revertCourseToDraft_BulkSessionsDeleted_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        TestDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);

        Map<Id,Session__c> sessionsMap = new Map<Id, Session__c>([SELECT Status__c FROM Session__c LIMIT 1000]);

        TestDataFactory.setSessionsToConfirmed(sessionsMap.keySet());

        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        for (Course__c aCourse : coursesToTest){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        test.startTest();

        delete sessionsMap.values();

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
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
    }

}