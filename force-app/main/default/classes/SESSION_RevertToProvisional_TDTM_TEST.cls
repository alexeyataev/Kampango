@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #9 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class SESSION_RevertToProvisional_TDTM_TEST {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PRACTITIONER_LASTNAME_ONE = 'Smith';

    private static Venue__c venue;

    //@TestSetup
    // avoid annotation - Account.AccountAutoNumber is not unique when using @TestSetup
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
    static void ChangeSessionToProvisional_DateUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        SetupTestData();

        CreateTriggerSystemHandlerRecord();

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void ChangeSessionToProvisional_StartTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        SetupTestData();

        CreateTriggerSystemHandlerRecord();

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void ChangeSessionToProvisional_EndTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        SetupTestData();

        CreateTriggerSystemHandlerRecord();

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void ChangeSessionToProvisional_LunchBreakUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        SetupTestData();

        CreateTriggerSystemHandlerRecord();

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

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
    static void ChangeSessionToProvisional_VenueUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        SetupTestData();

        CreateTriggerSystemHandlerRecord();

        TestDataFactory testDataFactory = TestDataFactory.getInstance();

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        testDataFactory.setSessionsToConfirmed(sessions);

        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .InsertRecord(true)
            .Build();

        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Venue__c =  venue.Id;
            aSession.Room__c =  NULL;
        }

        update sessions;

        test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];

        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_BulkUpdatesOnSessions_SessionStatusIsChangedToProvisional() {
        SetupTestData();

        TestDataFactory testDataFactory = TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount('acc5')
            .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCourse()
            .buildEstimatedCosts();

        CreateTriggerSystemHandlerRecord();

        Integer coursesToCreate = 5;
        Integer sessionsToCreate = 10;

        testDataFactory.buildCoursesWithSessions(coursesToCreate, sessionsToCreate);

        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];

        testDataFactory.setSessionsToConfirmed(sessions);

        Set<Id> sessionIds = new Set<Id>();
        test.startTest();

        for(Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c =  11;
            sessionIds.add(aSession.Id);
        }
        update sessions;

        test.stopTest();

        List<Session__c> sessionsWithProvisionalStatus = [SELECT Status__c FROM Session__c WHERE Status__c =: SESSION_PROVISIONAL_STATUS AND Id IN :sessionIds LIMIT 1000];

        System.assertEquals(sessions.size(), sessionsWithProvisionalStatus.size());
    }

    private static void CreateTriggerSystemHandlerRecord() {

        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'SessionTriggerHandler';
        th.npsp__Class__c = 'SESSION_RevertToProvisional_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'BeforeUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 0;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
    }


}