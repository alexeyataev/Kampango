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
    private static final String ACCOUNT_BRANCH_RECORDTYPE = 'Branch';
    private static final Integer COURSES_TO_CREATE = 5;
    private static final Integer SESSIONS_TO_CREATE = 10;
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'SESSION_RevertCourseToDraft_TDTM',
        'className' => 'SESSION_RevertCourseToDraft_TDTM',
        'objectAPIName' => 'Session__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    private static Venue__c venue;
    private static Room__c room;
    private static Licence_To_Practice__c licenceToPractice;
    private static Session__c session;

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildBranchAccount()
                    .buildOrganizationAccount('acc1')
                    .buildOrganizationAccount('acc2')
                    .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
                    .buildPractitioner(PRACTITIONER_LASTNAME_TWO)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildCoursesWithSessions(COURSES_TO_CREATE, SESSIONS_TO_CREATE)
                    .buildReunion();
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];
        dataFactory .setSessionsToConfirmed(sessions)
                    .setCourseToFinal();
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @isTest
    static void RevertCourseToDraft_NewSessionIsAdded_CourseStatusIsRevertedToDraft() {
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Licence_To_Practice__c practitionerLicence = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];
        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        Contact practitioner = [SELECT Id FROM Contact WHERE RecordType.Name =:PRACTITIONER_RECORDTYPE_NAME LIMIT 1];
        Practitioner_Fee_Rate__c practitionerFeeRate = [SELECT Id FROM Practitioner_Fee_Rate__c LIMIT 1];

        Test.startTest();
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
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_DateUpdatedOnSession_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Test.startTest();
        for(Session__c aSession : sessions){
            aSession.Date__c = Date.today();
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }


    @isTest
    static void RevertCourseToDraft_StartTimeUpdatedOnSession_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Start__c = Time.newInstance(19, 00, 0, 0);
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_EndTimeUpdatedOnSession_CourseStatusIsRevertedToDraft () {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.End__c = Time.newInstance(20, 00, 0, 0);
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_LunchBreakMinutesUpdatedOnSession_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c = 15;
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);

    }

    @isTest
    static void RevertCourseToDraft_PractitionerLicenceUpdatedOnSession_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Contact practitioner = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_ONE LIMIT 1];
        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .withContact(practitioner)
            .insertRecord(true)
            .build();

        Test.startTest();
        for(Session__c aSession :sessions) {
            aSession.Practitioner_Licence__c = licenceToPractice.Id;
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_VenueUpdatedOnSession_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_BRANCH_RECORDTYPE).getRecordTypeId();
        Account branch = [
           SELECT Id 
           FROM Account 
           WHERE RecordTypeId = :recordTypeId
           LIMIT 1
        ];

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .InsertRecord(true)
            .withBranch(branch)
            .Build();
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        room = roomBuilder
            .WithVenue(venue)
            .InsertRecord(true)
            .Build();

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Venue__c = venue.Id;
            aSession.Room__c = room.Id;
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_SessionDeletedOnCourse_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Test.startTest();
        delete sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_PractitionerUpdatedOnSession_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Test.startTest();
        Contact practitioner2 = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_TWO];
        for(Session__c aSession : sessions) {
            aSession.Practitioner__c = practitioner2.Id;
            aSession.Practitioner_Licence__c = NULL;
            aSession.Status__c = SESSION_PROVISIONAL_STATUS;
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_StatusUpdatedOnSession_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Status__c = SESSION_PROVISIONAL_STATUS;
        }
        update sessions;
        Test.stopTest();

        Course__c courseToTest = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];
        System.assertEquals(COURSE_DRAFT_STATUS, courseToTest.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_BulkSessionsChanged_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];
        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];
        Set<Id> courseIds = new Set<Id>();
        for (Course__c aCourse : coursesToTest){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        Test.startTest();
        for(Session__c aSession : sessions){
            aSession.Start__c = Time.newInstance(12, 00, 0, 0);
        }
        update sessions;
        Test.stopTest();

        List<Course__c> draftCoursesAfterUpdate = [SELECT Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_DRAFT_STATUS LIMIT 10];
        System.assertEquals(coursesToTest.size(), draftCoursesAfterUpdate.size());
    }

    @isTest
    static void RevertCourseToDraft_BulkSessionsDeleted_CourseStatusIsRevertedToDraft() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];
        List<Course__c> coursesToTest = [SELECT Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];
        Set<Id> courseIds = new Set<Id>();
        for (Course__c aCourse : coursesToTest){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update coursesToTest;

        Test.startTest();
        delete sessions;
        Test.stopTest();

        List<Course__c> draftCoursesAfterUpdate = [SELECT Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_DRAFT_STATUS LIMIT 10];
        System.assertEquals(coursesToTest.size(), draftCoursesAfterUpdate.size());
    }

    @isTest
    static void RevertCourseToDraft_ReunionSessionsChangeStatusToFinal_CourseStatusUnaffected() {
        List<Session__c> reunions = [SELECT Id FROM Session__c WHERE Type__c = 'Reunion' LIMIT 1000];

        Test.startTest();
        for (Session__c reunion : reunions) {
            reunion.Status__c = 'Provisional';
        }
        Test.stopTest();

        List<Course__c> finalCourses = [SELECT Status__c FROM Course__c  WHERE Status__c =: COURSE_FINAL_STATUS LIMIT 10];
        System.assertEquals(1, finalCourses.size(), 'Reunion session status change should not affect status of the course');
    }
    
    @isTest
    static void RevertCourseToDraft_ReunionSessionsChangeEndTime_CourseStatusUnaffected() {
        List<Session__c> reunions = [SELECT Id, End__c FROM Session__c WHERE Type__c = 'Reunion' LIMIT 1000];

        Test.startTest();
        for (Session__c session : reunions) {
            session.End__c = session.End__c.addHours(1);
        }
        update reunions;
        Test.stopTest();

        List<Course__c> finalCourses = [SELECT Id FROM Course__c WHERE Status__c =: COURSE_FINAL_STATUS];
        System.assertEquals(1, finalCourses.size(), 'Start time change should not affect course status');
    }
}