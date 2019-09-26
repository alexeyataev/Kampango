@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #9 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class SESSION_InvalidateCAs_TDTM_TEST {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Jones';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String COURSE_ASSIGNMENT_INVALIDATED_STATUS = 'Invalidated';

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildReunion();

        List<Session__c> provisionalNonReunionSessions = [SELECT Id FROM Session__c WHERE Status__c = 'Provisional' AND Type__c <> 'Reunion'];    
        List<Course__c> listDraftCourses = [SELECT Id FROM Course__c WHERE Status__c = 'Draft'];

        dataFactory .SetSessionsToConfirmed(provisionalNonReunionSessions)
                    .SetCoursesToFinal(listDraftCourses)
                    .buildCourseAssignment();

        User practitionerCommunityUser = TestDataFactory.convertPractitionerToPartnerCommunityUser();
        changeOwnerOfCAandRunSession_assignment_flow(practitionerCommunityUser);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_PractitionerChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {
        TestDataFactory.getInstance()
            .buildOrganizationAccount('acc2')
            .buildPractitioner(PRACTITIONER_LASTNAME_TWO, PRACTITIONER_EMAIL_ADDRESS)
            .buildLicenceToPractice();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id, Course_Assignment__c FROM Session__c WHERE Type__c <> 'Reunion' LIMIT 1];

        Contact practitioner2 = [SELECT Id, LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_TWO];
        Licence_To_Practice__c licence2 = [SELECT Id FROM Licence_To_Practice__c WHERE Contact__c =:practitioner2.Id];

        Set<Id> courseAssignmentIds = new Set<Id>();

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Practitioner__c = practitioner2.Id;
            aSession.Practitioner_Licence__c = licence2.Id;
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_DateChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id, Course_Assignment__c FROM Session__c WHERE Type__c <> 'Reunion' LIMIT 1];

        Set<Id> courseAssignmentIds = new Set<Id>();

        test.startTest();

        for (Session__c aSession : sessions) {
            aSession.Date__c = Date.today() + 15;
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_StartTimeChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id, Course_Assignment__c FROM Session__c WHERE Type__c <> 'Reunion' LIMIT 1];

        Set<Id> courseAssignmentIds = new Set<Id>();

        test.startTest();

        for (Session__c aSession : sessions) {
            aSession.Start__c = Time.newInstance(09, 00, 0, 0);
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_EndTimeChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id, Course_Assignment__c FROM Session__c WHERE Type__c <> 'Reunion' LIMIT 1];

        Set<Id> courseAssignmentIds = new Set<Id>();

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.End__c = Time.newInstance(23, 00, 0, 0);
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_LunchbreakMinutesChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {
        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id, Course_Assignment__c FROM Session__c WHERE Type__c <> 'Reunion' LIMIT 1];

        Set<Id> courseAssignmentIds = new Set<Id>();

        test.startTest();

        for (Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c = 45;
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_VenueChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Venue__c venue;
        Room__c room;

        List<Session__c> sessions = [SELECT Id, Course_Assignment__c FROM Session__c WHERE Type__c <> 'Reunion' LIMIT 1];

        Set<Id> courseAssignmentIds = new Set<Id>();

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

        for (Session__c aSession : sessions) {
            aSession.Venue__c = venue.Id;
            aSession.Room__c = room.Id;
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }

        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_StatusChangesFromProvisionalToConfirmedOnReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id, Status__c, Course_Assignment__c FROM Session__c WHERE Type__c = 'Reunion' LIMIT 1];

        Set<Id> courseAssignmentIds = new Set<Id>();

        test.startTest();

        for (Session__c aSession : sessions) {
            aSession.Status__c = 'Confirmed';
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_PractitionerChangesOnReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        TestDataFactory.getInstance()
            .buildOrganizationAccount('acc3')
            .buildPractitioner(PRACTITIONER_LASTNAME_TWO, PRACTITIONER_EMAIL_ADDRESS);

        List<Session__c> sessions = [SELECT Id, Course_Assignment__c FROM Session__c WHERE Type__c = 'Reunion' LIMIT 1];
        Set<Id> courseAssignmentIds = new Set<Id>();

        for (Session__c aSession : sessions) {
            courseAssignmentIds.add(aSession.Course_Assignment__c);
        }

        Contact practitioner2 = [SELECT LastName FROM Contact WHERE LastName = :PRACTITIONER_LASTNAME_TWO];

        test.startTest();

        for (Session__c aSession : sessions) {
            aSession.Practitioner__c = practitioner2.Id;
            aSession.Practitioner_Licence__c = NULL;
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c WHERE Id IN :courseAssignmentIds LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    private static void  ChangeOwnerOfCAandRunSession_assignment_flow(User practitionerCommunityUser) {

        List<Course_Assignment__c> courseAssignments = [SELECT OwnerId, Course__c FROM Course_Assignment__c LIMIT 100];

        for (Course_Assignment__c aCourseAssignment : courseAssignments) {
            aCourseAssignment.OwnerId = practitionerCommunityUser.Id;
        }
        update courseAssignments;
    }

    private static void CreateTriggerSystemHandlerRecord() {

        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SESSION_InvalidateCAs_TDTM';
        th.npsp__Class__c = 'SESSION_InvalidateCAs_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
    }
}