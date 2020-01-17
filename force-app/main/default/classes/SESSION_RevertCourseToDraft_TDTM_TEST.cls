@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #9 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public class SESSION_RevertCourseToDraft_TDTM_TEST {

    private static final String COURSE_DRAFT_STATUS = 'Draft';
    private static final String COURSE_FINAL_STATUS = 'Final';
    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PRACTITIONER_LASTNAME_ONE = 'Smith';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Jones';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';

    private static Venue__c venue;
    private static Room__c room;
    private static Licence_To_Practice__c licenceToPractice;
    private static Session__c session;

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc1')
            .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourse()
            .buildEstimatedCosts()
            .buildSession();
    }

    @isTest
    static void RevertCourseToDraft_NewSessionIsAdded_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Licence_To_Practice__c practitionerLicence = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        Contact practitioner = [SELECT Id FROM Contact WHERE RecordType.Name =:PRACTITIONER_RECORDTYPE_NAME LIMIT 1];
        Practitioner_Fee_Rate__c practitionerFeeRate = [SELECT Id FROM Practitioner_Fee_Rate__c LIMIT 1];

        test.startTest();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .withCourse(course)
            .withVenue(venue)
            .withRoom(room)
            .withStatus(SESSION_PROVISIONAL_STATUS)
            .withPractitioner(practitioner)
            .withPractitionerFeeRate(practitionerFeeRate)
            .withPractitionerLicence(practitionerLicence)
            .insertRecord(true)
            .build();

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_DateUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void RevertCourseToDraft_StartTimeUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void RevertCourseToDraft_EndTimeUpdatedOnSession_CourseStatusIsRevertedToDraft () {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void RevertCourseToDraft_LunchBreakMinutesUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void RevertCourseToDraft_PractitionerLicenceUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Contact practitioner = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_ONE LIMIT 1];

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
    static void RevertCourseToDraft_VenueUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void RevertCourseToDraft_SessionDeletedOnCourse_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void RevertCourseToDraft_PractitionerUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc2')
            .buildPractitioner(PRACTITIONER_LASTNAME_TWO);

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Contact practitioner2 = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_TWO];
        for(Session__c aSession : sessions) {
            aSession.Practitioner__c = practitioner2.Id;
            aSession.Practitioner_Licence__c = NULL;
            aSession.Status__c = SESSION_PROVISIONAL_STATUS;
        }
        update sessions;

        test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_StatusUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        CreateTriggerSystemHandlerRecord();

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void RevertCourseToDraft_BulkSessionsChanged_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc3')
            .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourse()
            .buildEstimatedCosts()
            .buildSession();

        CreateTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        testDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];

        testDataFactory.setSessionsToConfirmed(sessions);

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

        System.assertEquals(coursesToTest.size(), draftCoursesAfterUpdate.size());
    }

    @isTest
    static void RevertCourseToDraft_BulkSessionsDeleted_CourseStatusIsRevertedToDraft() {

        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc4')
            .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourse()
            .buildEstimatedCosts()
            .buildSession();

        CreateTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        testDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];

        testDataFactory.setSessionsToConfirmed(sessions);

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

    @isTest
    static void runionSessionsChangeStatusToProvisional() {
        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc4')
            .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourse()
            .buildEstimatedCosts()
            .buildSession();

        CreateTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        testDataFactory.buildCoursesWithReunionSessions(coursesToCreate, sessionsToCreate);

        List<Session__c> reunions = [SELECT Id FROM Session__c LIMIT 1000];
        
        testDataFactory.setSessionsToConfirmed(reunions);

        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        for (Course__c aCourse : coursesToTest){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        Test.startTest();

        for (Session__c reunion : reunions) {
            reunion.Status__c = 'Provisional';
        }

        Test.stopTest();

        List<Course__c> draftCoursesAfterUpdate = [SELECT Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_FINAL_STATUS LIMIT 10];

        System.assertEquals(coursesToTest.size(), draftCoursesAfterUpdate.size());
    }
    
    static void runionSessionsChangeStartTime() {
        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc4')
            .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourse()
            .buildEstimatedCosts();

        CreateTriggerSystemHandlerRecord();

        Integer coursesToCreate = 4;
        Integer sessionsToCreate = 8;

        testDataFactory.buildCoursesWithReunionSessions(coursesToCreate, sessionsToCreate);

        List<Session__c> reunions = [SELECT Id FROM Session__c WHERE Type__c = 'Reunion'];

        testDataFactory.setSessionsToConfirmed(reunions);

        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];
        for (Course__c course : coursesToTest) {
            course.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        for (Session__c session : reunions) {
            session.Start__c.addHours(1);
        }

        update reunions;

        List<Course__c> draftCourses = [SELECT Id FROM Course__c WHERE Status__c =: COURSE_DRAFT_STATUS];

        System.assertEquals(0, draftCourses.size());
    }
    
    private static void CreateTriggerSystemHandlerRecord() {

        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertCourseToDraft_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 0;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
    }

}