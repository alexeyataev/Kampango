@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #9 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class SESSION_RevertToProvisional_TDTM_TEST {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String SESSION_REUNION_TYPE = 'Reunion';
    private static final String PRACTITIONER_LASTNAME_ONE = 'Smith';
    private static final String PARENT_HOST_LASTNAME = 'Jameson';
    private static final String PARENT_HOST_LASTNAME_TWO = 'White';
    private static final String PARENT_HOST_EMAIL = 'test@test.com';
    private static final String VENUE_NAME = 'Public Venue';
    private static final String CLIENT_RECORDTYPE_NAME = 'Clients';
    private static final Integer COURSES_TO_CREATE = 5;
    private static final Integer SESSIONS_TO_CREATE = 10;
    private static final String VIRTUAL_VENUE = 'Virtual';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'SESSION_RevertToProvisional_TDTM',
        'className' => 'SESSION_RevertToProvisional_TDTM',
        'objectAPIName' => 'Session__c',
        'triggerActions' => 'BeforeUpdate',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildBranchAccount()
                    .buildOrganizationAccount('acc1')
                    .buildPractitioner(PRACTITIONER_LASTNAME_ONE)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildVirtualVenue('Virtual')
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildCoursesWithSessions(COURSES_TO_CREATE, SESSIONS_TO_CREATE)
                    .buildVenueWithName(VENUE_NAME)
                    .buildParentHost(PARENT_HOST_LASTNAME, PARENT_HOST_EMAIL)
                    .buildSessionWithParentHost()
                    .buildParentHost(PARENT_HOST_LASTNAME_TWO, PARENT_HOST_EMAIL);
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];
        dataFactory .setSessionsToConfirmed(sessions);
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @isTest
    static void ChangeSessionToProvisional_DateUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c];

        Test.startTest();
        for(Session__c session : sessions) {
            session.Date__c = Date.today()+10;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_StartTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c];

        Test.startTest();
        for(Session__c session : sessions) {
            session.Start__c =  Time.newInstance(18, 00, 0, 0);
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_EndTimeUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c];

        Test.startTest();
        for(Session__c session : sessions) {
            session.End__c =  Time.newInstance(21, 00, 0, 0);
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_LunchBreakUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c];

        Test.startTest();
        for(Session__c session : sessions) {
            session.Lunch_Break_Minutes__c =  11;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_VenueUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Parent_Host__c = null];
        Venue__c venue = [SELECT Id FROM Venue__c WHERE Name = :VENUE_NAME LIMIT 1];
        
        Test.startTest();
        for(Session__c session : sessions) {
            session.Venue__c =  venue.Id;
            session.Room__c =  NULL;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_ParentHostUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Parent_Host__c <> null];
        Contact parentHost = [SELECT Id FROM Contact WHERE RecordTypeId = :SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORDTYPE_NAME).getRecordTypeId() AND LastName = :PARENT_HOST_LASTNAME_TWO LIMIT 1];
        
        Test.startTest();
        for(Session__c session : sessions) {
            session.Parent_Host__c = parentHost.Id;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_ParentHostUpdatedOnOnlineReunionSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Parent_Host__c <> null];
        Contact parentHost = [SELECT Id FROM Contact WHERE RecordTypeId = :SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORDTYPE_NAME).getRecordTypeId() AND LastName = :PARENT_HOST_LASTNAME_TWO LIMIT 1];
        for(Session__c session : sessions) {
            session.Delivery_Type__c = 'Online';
            session.Type__c = SESSION_REUNION_TYPE;
        }
        update sessions;
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory.setSessionsToConfirmed(sessions);
        
        Test.startTest();
        for(Session__c session : sessions) {
            session.Parent_Host__c = parentHost.Id;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }


    @isTest
    static void ChangeSessionToProvisional_DeliveryTypeUpdatedOnSession_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Parent_Host__c = null];
        Venue__c virtualVenue = [SELECT Id FROM Venue__c WHERE RecordTypeId = :Schema.SObjectType.Venue__c.getRecordTypeInfosByDeveloperName().get(VIRTUAL_VENUE).getRecordTypeId() LIMIT 1];

        Test.startTest();
        for(Session__c session : sessions) {
            session.Delivery_Type__c = 'Online';
            session.Venue__c = virtualVenue.Id;
            session.Room__c= null;
        }
        update sessions;
        Test.stopTest();

        Session__c sessionToTest = [SELECT Status__c FROM Session__c WHERE Id = :sessions LIMIT 1];
        System.assertEquals(SESSION_PROVISIONAL_STATUS, sessionToTest.Status__c);
    }

    @isTest
    static void ChangeSessionToProvisional_BulkUpdatesOnSessions_SessionStatusIsChangedToProvisional() {
        List<Session__c> sessions = [SELECT Id FROM Session__c LIMIT 1000];
        Set<Id> sessionIds = new Set<Id>();
    
        Test.startTest();
        for(Session__c session : sessions) {
            session.Lunch_Break_Minutes__c =  11;
            sessionIds.add(session.Id);
        }
        update sessions;
        Test.stopTest();

        List<Session__c> sessionsWithProvisionalStatus = [SELECT Status__c FROM Session__c WHERE Status__c =: SESSION_PROVISIONAL_STATUS AND Id IN :sessionIds LIMIT 1000];
        System.assertEquals(sessions.size(), sessionsWithProvisionalStatus.size());
    }
}