@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #9 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class SESSION_InvalidateCAs_TDTM_TEST {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Jones';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String HOST_LASTNAME_TWO = 'Brown';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String ACCOUNT_BRANCH_RECORDTYPE = 'Branch';
    private static final String COURSE_ASSIGNMENT_DRAFT_STATUS = 'Draft';
    private static final String COURSE_ASSIGNMENT_INVALIDATED_STATUS = 'Invalidated';
    private static final String COURSE_ASSIGNMENT_WITHDRAWN_STATUS = 'Withdrawn';
    private static final String SESSION_TYPE_PROVISIONAL = 'Provisional';
    private static final String SESSION_TYPE_REUNION = 'Reunion';
    private static final String SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT = 'Virtual Support';
    private static final String VIRTUAL_VENUE = 'Virtual';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'SESSION_InvalidateCAs_TDTM',
        'className' => 'SESSION_InvalidateCAs_TDTM',
        'objectAPIName' => 'Session__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    private static void SetupTestData() {
    TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildOrganizationAccount('acc2')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitioner(PRACTITIONER_LASTNAME_TWO, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildVirtualVenue('Virtual')
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildParentHost(HOST_LASTNAME_TWO, HOST_EMAIL_ADDRESS)
                    .buildSessionWithTypeAndStatus(SESSION_TYPE_REUNION, SESSION_TYPE_PROVISIONAL)
                    .buildSessionWithParentHost()
                    .buildVirtualSupportSession(SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT, 2);

        List<Session__c> provisionalNonReunionSessions = [
            SELECT Id 
            FROM Session__c 
            WHERE Status__c = :SESSION_TYPE_PROVISIONAL 
                AND Type__c <> :SESSION_TYPE_REUNION
        ];    

        List<Course__c> listDraftCourses = [
            SELECT Id 
            FROM Course__c 
            WHERE Status__c = 'Draft'
        ];

        dataFactory .SetSessionsToConfirmed(provisionalNonReunionSessions)
                    .SetCoursesToFinal(listDraftCourses)
                    .buildCourseAssignment();

        User practitionerCommunityUser = TestDataFactory.convertPractitionerToPartnerCommunityUser();
        TestDataFactory.changeOwnerOfAllCourseAssignments(practitionerCommunityUser);

        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @isTest
    static void WithdrawCourseAssignmentStatus_PractitionerChangesOnLastSessionOnCourse_CourseAssignmentStatusWithdrawn() {
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

        TestDataFactory.getInstance().buildLicenceToPractice(practitioner2);
        Licence_To_Practice__c licence2 = [
            SELECT Id 
            FROM Licence_To_Practice__c 
            WHERE Contact__c =:practitioner2.Id
            LIMIT 1
            ];

        Test.startTest();
        for (Session__c session : sessions) {
            session.Practitioner__c = practitioner2.Id;
            session.Practitioner_Licence__c = licence2.Id; 
        }
        update sessions;
        Test.stopTest();

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

        TestDataFactory.getInstance().buildLicenceToPractice(practitioner2);

        Licence_To_Practice__c licence2 = [
            SELECT Id 
            FROM Licence_To_Practice__c 
            WHERE Contact__c =:practitioner2.Id
            LIMIT 1
        ];

        Test.startTest();
        session.Practitioner__c = practitioner2.Id;
        session.Practitioner_Licence__c = licence2.Id;
        update session;
        Test.stopTest();

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
        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            WHERE Delivery_Type__c <> :SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT
            LIMIT 1
        ];

        Test.startTest();
        session.Date__c = Date.today() + 15;
        update session;
        Test.stopTest();

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
        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            WHERE Delivery_Type__c <> :SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT
            LIMIT 1
        ];

        Test.startTest();
        session.Start__c = Time.newInstance(9, 0, 0, 0);
        update session;
        Test.stopTest();

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
        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            WHERE Delivery_Type__c <> :SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT
            LIMIT 1
        ];

        Test.startTest();
        session.End__c = Time.newInstance(23, 00, 0, 0);
        update session;
        Test.stopTest();

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
        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            LIMIT 1
        ];

        Test.startTest();
        session.Lunch_Break_Minutes__c = 45;
        update session;
        Test.stopTest();

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
        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            WHERE Type__c = :SESSION_TYPE_REUNION
            LIMIT 1
        ];

        Test.startTest();
        session.Lunch_Break_Minutes__c = 45;
        session.Status__c = 'Confirmed';
        update session;
        Test.stopTest();

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
        Venue__c venue;
        Room__c room;
        Session__c session = [
            SELECT Id, Course_Assignment__c
            FROM Session__c
            WHERE Delivery_Type__c <> :SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT
            LIMIT 1
        ];

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_BRANCH_RECORDTYPE).getRecordTypeId();
        Account branch = [
           SELECT Id 
           FROM Account 
           WHERE RecordTypeId = :recordTypeId
           LIMIT 1
        ];

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .withBranch(branch)
            .InsertRecord(true)
            .Build();
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        room = roomBuilder
            .WithVenue(venue)
            .InsertRecord(true)
            .Build();

        Test.startTest();
        session.Venue__c = venue.Id;
        session.Room__c = room.Id;
        update session;
        Test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_ParentHostChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {
        Session__c session = [
            SELECT Id, Course_Assignment__c, Parent_Host__c, Venue__c, Room__c
            FROM Session__c
            WHERE Delivery_Type__c <> :SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT
            LIMIT 1
        ];

        Contact newParentHost = [
            SELECT Id
            FROM Contact
            WHERE LastName = :HOST_LASTNAME_TWO
            LIMIT 1
        ];
        
        Test.startTest();
        session.Parent_Host__c = newParentHost.Id;
        session.Venue__c = null;
        session.Room__c = null;
        update session;
        Test.stopTest();

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
        Session__c session = [
            SELECT Id, Status__c, Course_Assignment__c
            FROM Session__c
            WHERE Type__c = :SESSION_TYPE_REUNION
            LIMIT 1
        ];

        Test.startTest();
        session.Status__c = 'Confirmed';
        update session;
        Test.stopTest();

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

        Test.startTest();
        session.Course__c = courseAssignment.Course__c;
        insert session;
        Test.stopTest();

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

        Test.startTest();
        delete courseAssignment.Sessions__r[0];
        Test.stopTest();

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

        Test.startTest();
        delete courseAssignment.Sessions__r;
        Test.stopTest();

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

        Test.startTest();
        session.Course_Assignment__c = courseAssignmentNew.Id;
        update session;
        Test.stopTest();

        Course_Assignment__c courseAssignmentToCheck = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id = :courseAssignment.Id
        ]; 

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToCheck.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_HoursChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {
        Session__c session = [
            SELECT Id, Course_Assignment__c, Delivery_Type__c, Hours__c
            FROM Session__c
            WHERE Delivery_Type__c = :SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT
            LIMIT 1
        ];

        System.debug(session.Delivery_Type__c);

        Test.startTest();
        session.Hours__c = 5;
        update session;
        Test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_DeliveryTypeChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {
        Session__c session = [
            SELECT Id, Course_Assignment__c, Delivery_Type__c, Hours__c
            FROM Session__c
            WHERE Delivery_Type__c <> :SESSION_DELIVERY_TYPE_VIRTUAL_SUPPORT
            LIMIT 1
        ];
        Venue__c virtualVenue = [
            SELECT Id
            FROM Venue__c
            WHERE RecordTypeId = :Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get(VIRTUAL_VENUE).getRecordTypeId()
            LIMIT 1
        ];

        Test.startTest();
        session.Delivery_Type__c = 'Online';
        session.Venue__c = virtualVenue.Id;
        session.Room__c = null;
        update session;
        Test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [
            SELECT Status__c
            FROM Course_Assignment__c
            WHERE Id =:session.Course_Assignment__c
            LIMIT 1
        ];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }
}
