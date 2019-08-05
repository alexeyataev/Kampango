@isTest
public class SESSION_RevertCourseToDraft_TDTM_TEST {

    private static final String COURSE_DRAFT_STATUS = 'Draft';
    private static final String COURSE_FINAL_STATUS = 'Final';
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
            .WithRecordType('Practitioner')
            .WithAccount(branchAccount)
            .InsertRecord(true)
            .Build();

         practitionerContactBuilder
            .WithRecordType('Practitioner')
            .WithAccount(branchAccount)
             .WithLastName('Practitioner2')
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
            .WithLicenceToPractice(licenceToPractice)
            .InsertRecord(true)
            .Build();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .WithCourse(course)
            .WithVenue(venue)
            .WithPractitionerLicence(licenceToPractice)
            .WithRoom(room)
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
    static void RevertCourseToDraft_NewSessionIsAdded_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Licence_To_Practice__c practitionerLicence = [SELECT Id FROM Licence_To_Practice__c LIMIT 1];

        Venue__c venue = [SELECT Id FROM Venue__c LIMIT 1];
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];

        test.startTest();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .WithCourse(course)
            .WithVenue(venue)
            .WithPractitionerLicence(practitionerLicence)
            .WithRoom(room)
            .InsertRecord(true)
            .Build();

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_DateUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        session.Date__c = Date.today();
        update session;

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);
    }


    @isTest
    static void RevertCourseToDraft_StartTimeUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        session.Start__c = Time.newInstance(19, 00, 0, 0);
        update session;

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_EndTimeUpdatedOnSession_CourseStatusIsRevertedToDraft () {

        createTriggerSystemHandlerRecord();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        session.End__c = Time.newInstance(02, 00, 0, 0);
        update session;

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_LunchBreakMinutesUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        session.Lunch_Break_Minutes__c = 15;
        update session;

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);

    }

    @isTest
    static void RevertCourseToDraft_PractitionerLicenceUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        test.startTest();

        Contact practitioner = [SELECT Id, LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME LIMIT 1];

        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .WithContact(practitioner)
            .InsertRecord(true)
            .Build();

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        session.Practitioner_Licence__c = licenceToPractice.Id;
        update session;

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_VenueUpdatedOnSession_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

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

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        session.Venue__c = venue.Id;
        session.Room__c = room.Id;
        update session;

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);
    }

    @isTest
    static void RevertCourseToDraft_SessionDeletedOnCourse_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        test.startTest();

        Course__c course = [SELECT Type__c FROM Course__c LIMIT 1];
        course.Status__c = COURSE_FINAL_STATUS;
        update course;

        Session__c session = [SELECT Id FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        delete session;

        test.stopTest();

        Course__c courseToCheck = [SELECT Status__c FROM Course__c WHERE Id = :course.Id LIMIT 1];

        System.assertEquals(COURSE_DRAFT_STATUS, courseToCheck.Status__c);
    }


    @isTest
    static void RevertCourseToDraft_BulkSessionsChanged_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        TestDataFactory.createCourses();
        TestDataFactory.createSessions();
        TestDataFactory.createEstimatedCosts();


        List<Course__c> courses = [SELECT Id, Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        test.startTest();

        for (Course__c aCourse : courses){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update courses;

        List<Session__c> session = [SELECT Id, Start__c FROM Session__c WHERE Course__c IN : courseIds];
        for(Session__c aSession : session){
            aSession.Start__c = Time.newInstance(12, 00, 0, 0);
        }
        update session;

        List<Course__c> coursesAfterUpdate = [SELECT Id, Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_DRAFT_STATUS LIMIT 10];

        test.stopTest();

        System.assertEquals(5, coursesAfterUpdate.size());
    }

    @isTest
    static void RevertCourseToDraft_BulkSessionsDeleted_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();

        TestDataFactory.createCourses();
        TestDataFactory.createSessions();
        TestDataFactory.createEstimatedCosts();

        List<Course__c> courses = [SELECT Id, Status__c FROM Course__c WHERE Status__c =:COURSE_DRAFT_STATUS LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        test.startTest();

        for (Course__c aCourse : courses){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update courses;

        List<Session__c> session = [SELECT Id, Start__c FROM Session__c WHERE Course__c IN : courseIds];
        delete session;

        List<Course__c> coursesAfterUpdate = [SELECT Id, Status__c FROM Course__c  WHERE Id IN : courseIds AND Status__c =: COURSE_DRAFT_STATUS LIMIT 10];
        test.stopTest();

        System.assertEquals(5, coursesAfterUpdate.size());
    }

    private static void createTriggerSystemHandlerRecord(){

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