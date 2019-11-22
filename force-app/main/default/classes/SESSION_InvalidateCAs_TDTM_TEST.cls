@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #9 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class SESSION_InvalidateCAs_TDTM_TEST {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Jones';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String COURSE_ASSIGNMENT_INVALIDATED_STATUS = 'Invalidated';
    private static final String COURSE_ASSIGNMENT_WITHDRAWN_STATUS = 'Withdrawn';

    @TestSetup
    private static void SetupTestData() {
    TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildReunion();

        List<Session__c> provisionalNonReunionSessions = [
            SELECT Id 
            FROM Session__c 
            WHERE Status__c = 'Provisional' 
                AND Type__c <> 'Reunion'
            ];    

        List<Course__c> listDraftCourses = [
            SELECT Id 
            FROM Course__c 
            WHERE Status__c = 'Draft'];

        dataFactory .SetSessionsToConfirmed(provisionalNonReunionSessions)
                    .SetCoursesToFinal(listDraftCourses)
                    .buildCourseAssignment();

        User practitionerCommunityUser = TestDataFactory.convertPractitionerToPartnerCommunityUser();
        changeOwnerOfCAandRunSession_assignment_flow(practitionerCommunityUser);
    }

    @isTest
    static void WithdrawCourseAssignmentStatus_PractitionerChangesOnLastSessionOnCourse_CourseAssignmentStatusWithdrawn() {
        TestDataFactory.getInstance()
            .buildOrganizationAccount('acc2')
            .buildPractitioner(PRACTITIONER_LASTNAME_TWO, PRACTITIONER_EMAIL_ADDRESS)
            .buildLicenceToPractice();

        CreateTriggerSystemHandlerRecord();

        List<Session__c> sessions = [
            SELECT Id, Course__c, Practitioner__c, Course_Assignment__c
            FROM Session__c
        ];

        User partnerCommunityUser = [
            SELECT Id
            FROM User
            WHERE ContactId = :sessions[0].Practitioner__c
            LIMIT 1
        ];

        Id oldPractitionerId = sessions[0].Practitioner__c;

        Contact practitioner2 = [
            SELECT Id, LastName
            FROM Contact
            WHERE LastName =:PRACTITIONER_LASTNAME_TWO
            LIMIT 1
        ];

        Licence_To_Practice__c licence2 = [
            SELECT Id 
            FROM Licence_To_Practice__c 
            WHERE Contact__c =:practitioner2.Id
            LIMIT 1
            ];

        test.startTest();

        for (Session__c session : sessions) {
            session.Practitioner__c = practitioner2.Id;
            session.Practitioner_Licence__c = licence2.Id; 
        }

        update sessions;

        test.stopTest();

        Course__c coursesSessionsAndCourseAssignmentsToWithdrawn = [
            SELECT Id,
                (
                    SELECT Status__c
                    FROM Course_Assignments__r
                    WHERE OwnerId =:partnerCommunityUser.Id
                        AND Id =:sessions[0].Course_Assignment__c
                ),
                (
                    SELECT Id
                    FROM Sessions__r
                    WHERE Practitioner__c =:oldPractitionerId
                )
            FROM Course__c
            WHERE Id =:sessions[0].Course__c
        ];

        System.assertEquals(COURSE_ASSIGNMENT_WITHDRAWN_STATUS, coursesSessionsAndCourseAssignmentsToWithdrawn.Course_Assignments__r[0].Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_PractitionerChangesOnNotLastSessionOnCourse_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        TestDataFactory.getInstance()
            .buildOrganizationAccount('acc3')
            .buildPractitioner(PRACTITIONER_LASTNAME_TWO, PRACTITIONER_EMAIL_ADDRESS)
            .buildLicenceToPractice();

        Session__c session = [
            SELECT  Date__c, End__c, Start__c,Course__c, Practitioner__c, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        User partnerCommunityUser = [
            SELECT Id
            FROM User
            WHERE ContactId = :session.Practitioner__c
        ];

        Id oldPractitionerId = session.Practitioner__c;


        Contact practitioner2 = [
            SELECT Id, LastName
            FROM Contact
            WHERE LastName =:PRACTITIONER_LASTNAME_TWO
            LIMIT 1
        ];

        Licence_To_Practice__c licence2 = [
            SELECT Id 
            FROM Licence_To_Practice__c 
            WHERE Contact__c =:practitioner2.Id
            LIMIT 1
        ];

        test.startTest();

        session.Practitioner__c = practitioner2.Id;
        session.Practitioner_Licence__c = licence2.Id;

        update session;

        test.stopTest();

        Course__c coursesSessionsAndCourseAssignmentsToWithdrawn = [
            SELECT Id,
                (
                    SELECT Status__c
                    FROM Course_Assignments__r
                    WHERE OwnerId =:partnerCommunityUser.Id
                        AND Id =:session.Course_Assignment__c
                ),
                (
                    SELECT Id
                    FROM Sessions__r
                    WHERE Practitioner__c =:oldPractitionerId
                )
            FROM Course__c
            WHERE Id =:session.Course__c
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, coursesSessionsAndCourseAssignmentsToWithdrawn.Course_Assignments__r[0].Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_DateChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        test.startTest();

        session.Date__c = Date.today() + 15;

        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_StartTimeChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        test.startTest();

        session.Start__c = Time.newInstance(09, 00, 0, 0);

        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_EndTimeChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        test.startTest();

        session.End__c = Time.newInstance(23, 00, 0, 0);

        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_LunchbreakMinutesChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        test.startTest();

        session.Lunch_Break_Minutes__c = 45;

        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_LunchbreakMinutesChangesOnReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            WHERE Type__c = 'Reunion'
            LIMIT 1
        ];

        test.startTest();

        session.Lunch_Break_Minutes__c = 45;
        session.Status__c = 'Confirmed';

        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }


    @isTest
    static void InvalidateCourseAssignmentStatus_VenueChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Venue__c venue;
        Room__c room;

        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

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

        session.Venue__c = venue.Id;
        session.Room__c = room.Id;

        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_StatusChangesFromProvisionalToConfirmedOnReunionSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Session__c session = [
            SELECT Id, Status__c, Course_Assignment__c
            FROM Session__c
            WHERE Type__c = 'Reunion'
            LIMIT 1
        ];

        test.startTest();

        session.Status__c = 'Confirmed';

        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_InsertNewSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Course_Assignment__c courseAssignment = [
            SELECT Status__c, Course__c, OwnerId
            FROM Course_Assignment__c
            WHERE Status__c != :COURSE_ASSIGNMENT_INVALIDATED_STATUS
            LIMIT 1
        ];

        List<Session__c> existingSessions = [
            SELECT Date__c, End__c, Start__c, Practitioner__c
            FROM Session__c
        ];

        Session__c session  = existingSessions[0].clone();

        test.startTest();

        session.Course__c = courseAssignment.Course__c;
        insert session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:courseAssignment.Id
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_DeleteNotLastSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Course_Assignment__c courseAssignment = [
            SELECT Status__c, Course__c, OwnerId,
                (
                    SELECT Id, Practitioner__c
                    FROM Sessions__r
                )
            FROM Course_Assignment__c
            WHERE Status__c != :COURSE_ASSIGNMENT_INVALIDATED_STATUS
            LIMIT 1
        ];

        Approval.lock(courseAssignment.Id, false);

        Session__c session = [
            SELECT  Date__c, End__c, Start__c,Course__c, Practitioner__c, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        User partnerCommunityUser =[
            SELECT Id
            FROM User
            WHERE ContactId = :session.Practitioner__c
        ];

        test.startTest();

        delete courseAssignment.Sessions__r[0];

        test.stopTest();

        Course__c coursesSessionsAndCourseAssignmentsToWithdrawn = [
            SELECT Id,
                (
                    SELECT Status__c
                    FROM Course_Assignments__r
                    WHERE OwnerId =:partnerCommunityUser.Id
                        AND Id =:session.Course_Assignment__c
                ),
                (
                    SELECT Id
                    FROM Sessions__r
                    WHERE Practitioner__c =:session.Practitioner__c
                )
            FROM Course__c
            WHERE Id =:session.Course__c
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, coursesSessionsAndCourseAssignmentsToWithdrawn.Course_Assignments__r[0].Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_DeleteLastSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Course_Assignment__c courseAssignment = [
            SELECT Status__c, Course__c, OwnerId,
                (
                    SELECT Id, Practitioner__c, Course__c, Course_Assignment__c
                    FROM Sessions__r
                )
            FROM Course_Assignment__c
            WHERE Status__c != :COURSE_ASSIGNMENT_INVALIDATED_STATUS
            LIMIT 1
        ];

        User partnerCommunityUser =[
            SELECT Id
            FROM User
            WHERE ContactId = :courseAssignment.Sessions__r[0].Practitioner__c
        ];

        test.startTest();
        
        delete courseAssignment.Sessions__r;

        test.stopTest();

        Course__c coursesSessionsAndCourseAssignmentsToWithdrawn = [
            SELECT Id,
                (
                    SELECT Status__c
                    FROM Course_Assignments__r
                    WHERE OwnerId =:partnerCommunityUser.Id
                        AND Id =:courseAssignment.Sessions__r[0].Course_Assignment__c
                ),
                (
                    SELECT Id
                    FROM Sessions__r
                    WHERE Practitioner__c =:courseAssignment.Sessions__r[0].Course_Assignment__c
                )
            FROM Course__c
            WHERE Id =:courseAssignment.Sessions__r[0].Course__c
        ];

        System.assertEquals(COURSE_ASSIGNMENT_WITHDRAWN_STATUS, coursesSessionsAndCourseAssignmentsToWithdrawn.Course_Assignments__r[0].Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_ReassignSession_CourseAssignmentStatusInvalidated() {

        CreateTriggerSystemHandlerRecord();

        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        Course_Assignment__c courseAssignment = [
            SELECT Status__c, Course__c, OwnerId,
                (
                    SELECT Id, Practitioner__c, Course__c, Course_Assignment__c
                    FROM Sessions__r
                    WHERE Id = :session.Id
                )
            FROM Course_Assignment__c
            WHERE Status__c != :COURSE_ASSIGNMENT_INVALIDATED_STATUS
            LIMIT 1
        ];

        Course_Assignment__c courseAssignmentNew = courseAssignment.Clone();
        insert courseAssignmentNew;

        User partnerCommunityUser =[
            SELECT Id
            FROM User
            WHERE ContactId = :courseAssignment.Sessions__r[0].Practitioner__c
        ];

        test.startTest();
        
        session.Course_Assignment__c = courseAssignmentNew.Id;
        update session;

        test.stopTest();

        Course_Assignment__c courseAssignmentToCheck = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id = :courseAssignment.Id
        ]; 

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToCheck.Status__c);
    }

    private static void  ChangeOwnerOfCAandRunSession_assignment_flow(User practitionerCommunityUser) {

        List<Course_Assignment__c> courseAssignments = [
            SELECT OwnerId, Course__c
            FROM Course_Assignment__c
            LIMIT 100
        ];

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
        th.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
    }
}