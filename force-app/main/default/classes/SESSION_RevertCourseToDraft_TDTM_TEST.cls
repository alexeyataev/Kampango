@isTest
public class SESSION_RevertCourseToDraft_TDTM_TEST {

    private static final String COURSE_DRAFT_STATUS = 'Draft';
    private static final String COURSE_FINAL_STATUS = 'Final';
    private static final String PRACTITIONER_LASTNAME = 'Practitioner2';

    @TestSetup
    private static void setupTestData() {
        TestDataFactory.createAccountBranch();
        TestDataFactory.createContactPractitioner();
        TestDataFactory.createVenues();
        TestDataFactory.createRooms();
        TestDataFactory.createLicenceToPractices();
        TestDataFactory.createCourses();
        TestDataFactory.createSessions();
        TestDataFactory.createEstimatedCosts();
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

        Session__c session2 = new Session__c(
            Name = 'testSession2',
            Type__c = 'Standard',
            Date__c = Date.today() + 5,
            Start__c = Time.newInstance(18, 30, 0, 0),
            End__c = Time.newInstance(18, 30, 2, 20),
            Specific_Attendee_Type__c = 'Women only',
            Practitioner_Licence__c = practitionerLicence.Id,
            Venue__c = venue.Id,
            Course__c = course.Id,
            Room__c = room.Id,
            Status__c = 'Confirmed'
        );
        insert session2;

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

        List<Contact> practitioners = [SELECT Id, LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME LIMIT 1];
        Licence_To_Practice__c licenceToPractice2 = new Licence_To_Practice__c(
            Contact__c = practitioners[0].Id,
            Start_Date__c = Date.Today(),
            Status__c = 'Full',
            Licence__c = 'Postnatal Practitioner'
        );
        insert licenceToPractice2;

        Session__c session = [SELECT Date__c FROM Session__c WHERE Course__c =:course.Id LIMIT 1];
        session.Practitioner_Licence__c = licenceToPractice2.Id;
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

        Venue__c venue = new Venue__c(
            Name = 'TestVenue2',
            Street_Address__c = '123 Secret Street',
            Town__c = 'London',
            Postcode__c = '20745',
            Type__c = 'Commercial',
            Subtype__c = 'Primary'
        );
        insert venue;

        Room__c room = new Room__c(
            Venue__c = venue.Id
        );
        insert room;

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
        List<Course__c> courses = [SELECT Id, Status__c FROM Course__c WHERE Status__c = 'Draft' LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        test.startTest();

        for(Course__c aCourse : courses){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update courses;


        List<Session__c> session = [SELECT Id, Start__c FROM Session__c WHERE Course__c IN : courseIds];
        for(Session__c aSession : session){
            aSession.Start__c = Time.newInstance(12, 00, 0, 0);
        }
        update session;

        List<Course__c> coursesAfterUpdate = [SELECT Id, Status__c FROM Course__c  WHERE Id IN : courseIds LIMIT 10];

        Integer countCoursesWithDraftStatus = 0;

        for(Course__c aCourse : coursesAfterUpdate){
            if(aCourse.Status__c == 'Draft'){
                countCoursesWithDraftStatus++;
            }
        }
        test.stopTest();

        System.assertEquals(5, countCoursesWithDraftStatus);
    }

    @isTest
    static void RevertCourseToDraft_BulkSessionsDeleted_CourseStatusIsRevertedToDraft() {

        createTriggerSystemHandlerRecord();
        List<Course__c> courses = [SELECT Id, Status__c FROM Course__c WHERE Status__c = 'Draft' LIMIT 10];

        Set<Id> courseIds = new Set<Id>();

        test.startTest();

        for(Course__c aCourse : courses){
            courseIds.add(aCourse.Id);
            aCourse.Status__c = COURSE_FINAL_STATUS;
        }
        update courses;

        List<Session__c> session = [SELECT Id, Start__c FROM Session__c WHERE Course__c IN : courseIds];
        delete session;

        List<Course__c> coursesAfterUpdate = [SELECT Id, Status__c FROM Course__c  WHERE Id IN : courseIds LIMIT 10];
        Integer countCoursesWithDraftStatus = 0;
        for(Course__c aCourse : coursesAfterUpdate){
            if(aCourse.Status__c == 'Draft'){
                countCoursesWithDraftStatus++;
            }
        }
        test.stopTest();

        System.assertEquals(5, countCoursesWithDraftStatus);
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