@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #9 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class SESSION_RevertToProvisional_TDTM_TEST {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PRACTITIONER_LASTNAME_ONE = 'Smith';
    private static final String VENUE_NAME = 'Public Venue';
    private static final Integer COURSES_TO_CREATE = 5;
    private static final Integer SESSIONS_TO_CREATE = 10;

    private static Venue__c venue;

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildBranchAccount()
                    .buildOrganizationAccount('acc1')
                    .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildCoursesWithSessions(COURSES_TO_CREATE, SESSIONS_TO_CREATE)
                    .buildVenueWithName(VENUE_NAME);
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];
        dataFactory .setSessionsToConfirmed(sessions);
    }

    @isTest
    static void ChangeSessionToProvisional_DateUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        CreateTriggerSystemHandlerRecord();
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Date__c = Date.today()+10;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_StartTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        CreateTriggerSystemHandlerRecord();
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Start__c =  Time.newInstance(18, 00, 0, 0);
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_EndTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        CreateTriggerSystemHandlerRecord();
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.End__c =  Time.newInstance(21, 00, 0, 0);
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_LunchBreakUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        CreateTriggerSystemHandlerRecord();
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c =  11;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_VenueUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        CreateTriggerSystemHandlerRecord();
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1];
        Venue__c venue = [SELECT Id FROM Venue__c WHERE Name = :VENUE_NAME LIMIT 1];
        
        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Venue__c =  venue.Id;
            aSession.Room__c =  NULL;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_BulkUpdatesOnSessions_SessionStatusIsChangedToProvisional() {
        CreateTriggerSystemHandlerRecord();
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];
        Set<Id> sessionIds = new Set<Id>();

        Test.startTest();
        for(Session__c aSession : sessions) {
            aSession.Lunch_Break_Minutes__c =  11;
            sessionIds.add(aSession.Id);
        }
        update sessions;
        Test.stopTest();

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