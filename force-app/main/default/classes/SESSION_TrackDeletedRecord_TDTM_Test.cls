@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #31 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public with sharing class SESSION_TrackDeletedRecord_TDTM_Test {
    
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    
    @TestSetup
    private static void SetupTestData(){
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession();

        List<Session__c> provisionalNonReunionSessions = [
            SELECT Id 
            FROM Session__c 
            WHERE Status__c = 'Provisional'];    

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
    private static void PostDeletedSessionDetailsToChatter(){

        CreateTriggerSystemHandlerRecord();
            
        List<Session__c> sessions = [SELECT Id, Course__c, Practitioner__c, Course_Assignment__c FROM Session__c];
        List<FeedItem> feedsBeforeSessionDeletion = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :sessions[0].Course__c];

        Test.startTest();
        delete sessions[0];
        Test.stopTest();

        List<FeedItem> feedsAfterSessionDeletion = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :sessions[0].Course__c];
        System.assertEquals(0, feedsBeforeSessionDeletion.size());
        System.assertEquals(1, feedsAfterSessionDeletion.size());

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
        th.Name = 'SESSION_TrackDeletedRecord_TDTM';
        th.npsp__Class__c = 'SESSION_TrackDeletedRecord_TDTM';
        th.npsp__Object__c = 'Session__c';
        th.npsp__Trigger_Action__c = 'AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);
    }
    
}
