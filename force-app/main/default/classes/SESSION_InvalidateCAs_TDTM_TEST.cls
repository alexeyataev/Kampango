@isTest
public class SESSION_InvalidateCAs_TDTM_TEST {

    private static final String PRACTITIONER_LASTNAME = 'Practitioner';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Practitioner2';
    private static final String COURSE_ASSIGNMENT_INVALIDATED_STATUS = 'Invalidated';

    @TestSetup
    private static void setupTestData() {
      TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildPractitioner()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourse()
            .buildEstimatedCosts()
            .buildSession()
            .buildCourseAssignment();

        User practitionerCommunityUser = convertPractitionerToPartnerCommunityUser(PRACTITIONER_LASTNAME);
        changeOwnerOfCAandRunSession_assignment_flow(practitionerCommunityUser);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_PractitionerChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {
        TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildPractitionerTwo();

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        Contact practitioner2 = [SELECT Id, LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_TWO];

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Practitioner__c = practitioner2.Id;
            aSession.Practitioner_Licence__c = NULL;
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);

    }

    @isTest
    static void InvalidateCourseAssignmentStatus_DateChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Date__c = Date.today() + 15;
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_StartTimeChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Start__c = Time.newInstance(09, 00, 0, 0);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_EndTimeChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {


        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.End__c = Time.newInstance(23, 00, 0, 0);
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_LunchbreakMinutesChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c = 45;
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_VenueChangesOnNonReunionSession_CourseAssignmentStatusInvalidated() {

        createTriggerSystemHandlerRecord();

        Venue__c venue;
        Room__c room;

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

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

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_StatusChangesFromProvisionalToConfirmedOnReunionSession_CourseAssignmentStatusInvalidated() {

        createTriggerSystemHandlerRecord();

        List<Session__c> sessions = [SELECT Id, Status__c FROM Session__c LIMIT 1];

        for(Session__c aSession : sessions) {
            aSession.Type__c = 'Reunion';
        }
        update sessions;

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Status__c = 'Confirmed';
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    @isTest
    static void InvalidateCourseAssignmentStatus_PractitionerChangesOnReunionSession_CourseAssignmentStatusInvalidated() {

        createTriggerSystemHandlerRecord();

        TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildBranchAccount()
            .buildPractitionerTwo();

        List<Session__c> sessions = [SELECT Id, Practitioner__c FROM Session__c LIMIT 1];
        for(Session__c aSession : sessions) {
            aSession.Type__c = 'Reunion';
        }
        update sessions;

        Contact practitioner2 = [SELECT LastName FROM Contact WHERE LastName =:PRACTITIONER_LASTNAME_TWO];

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Practitioner__c = practitioner2.Id;
            aSession.Practitioner_Licence__c = NULL;
        }
        update sessions;

        test.stopTest();

        Course_Assignment__c courseAssignmentToTest = [SELECT Status__c FROM Course_Assignment__c LIMIT 1];

        System.assertEquals(COURSE_ASSIGNMENT_INVALIDATED_STATUS, courseAssignmentToTest.Status__c);
    }

    private static User convertPractitionerToPartnerCommunityUser(String practitionerLastName) {

        Account partnerAccount = [SELECT IsPartner FROM Account LIMIT 1];
        partnerAccount.IsPartner = true;
        update partnerAccount;

        TestContactBuilder contact = new TestContactBuilder();
        contact.withRecordType(practitionerLastName).withAccount(partnerAccount);
        Contact practitioner = [SELECT Id FROM Contact WHERE LastName =:practitionerLastName];

        UserRole role;
        User userToCreateRole = createSysAdminUser();
        System.runAs(userToCreateRole){
            role = new UserRole();
            role.portalType = 'Partner';
            role.PortalAccountId = partnerAccount.Id;
            insert role;
        }

        Profile practitionerProfile = [SELECT Id FROM Profile WHERE Name =: practitionerLastName];

        User practitionerCommunityUser = new User(
            Username = 'nct123@test.com',
            ContactId = practitioner.Id,
            ProfileId = practitionerProfile.Id,
            Alias = 'test123',
            Email = 'test123@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test123',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            PortalRole = role.PortalRole
        );
        insert practitionerCommunityUser;
        return practitionerCommunityUser;
    }

    private static void  changeOwnerOfCAandRunSession_assignment_flow(User practitionerCommunityUser) {

        List<Course_Assignment__c> courseAssignments = [SELECT OwnerId, Course__c FROM Course_Assignment__c LIMIT 1];

        for (Course_Assignment__c aCourseAssignment : courseAssignments) {
            aCourseAssignment.OwnerId = practitionerCommunityUser.Id;
        }
        update courseAssignments;

        Map<String, Object> params = new Map<String, Object>();
        params.put('CA_Id_from_PB', courseAssignments[0].Id);
        params.put('Course_Id_From_PB', courseAssignments[0].Course__c);
        params.put('Owner_Id_From_PB', courseAssignments[0].OwnerId);
        Flow.Interview.Session_assignment_flow flow = new Flow.Interview.Session_assignment_flow(params);
        flow.start();
    }

    private static User createSysAdminUser() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User sysAdminUser = new User(
            alias = 'sysAdmin',
            email = 'sysAdmin.email@fakemail.com',
            emailencodingkey = 'UTF-8',
            lastname = 'NCTtest',
            languagelocalekey = Userinfo.getLanguage(),
            localesidkey = Userinfo.getLocale(),
            profileid = sysAdminProfile.Id,
            timezonesidkey = Userinfo.getTimeZone().getID(),
            username = 'NCTtest.sysAdmin.username@nct.com'
        );

        insert sysAdminUser;
        return sysAdminUser;
    }
    private static void createTriggerSystemHandlerRecord() {

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