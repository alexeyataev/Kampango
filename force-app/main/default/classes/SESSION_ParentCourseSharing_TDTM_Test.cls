@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #149 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public class SESSION_ParentCourseSharing_TDTM_Test {
    private static final String ACCOUNT_BRANCH_RECORDTYPE = 'Branch';
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Jones';
    private static final String PRACTITIONER_LASTNAME_THREE = 'White';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String PRACTITIONER_PROFILE_NAME = 'Practitioner';
    private static final String PRACTITIONER_RECORDTYPE_NAME = 'Practitioner';
    private static final String SESSION_STATUS_PROVISIONAL = 'Provisional';
    private static final String SESSION_TYPE_STANDARD = 'Standard';
    private static final Integer COURSES_TO_CREATE = 1;
    private static final Integer SESSIONS_TO_CREATE = 3;
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'SESSION_ParentCourseSharing_TDTM',
        'className' => 'SESSION_ParentCourseSharing_TDTM',
        'objectAPIName' => 'Session__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup
    private static void SetupTestData() {
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
        TestDataFactory dataFactory = TestDataFactory.getInstance();
            dataFactory .buildOrganizationAccount('acc1')
                        .buildBranchAccount()
                        .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                        .buildPractitioner(PRACTITIONER_LASTNAME_TWO, PRACTITIONER_EMAIL_ADDRESS)
                        .buildPractitioner(PRACTITIONER_LASTNAME_THREE, PRACTITIONER_EMAIL_ADDRESS);
            TestDataFactory.convertPractitionerToPartnerCommunityUser();
            dataFactory .buildPractitionerFeeRate()
                        .buildVenue()
                        .buildVirtualVenue('Virtual')
                        .buildRoom()
                        .buildLicenceToPractice()
                        .buildLicenceToPracticeForAllPractitioners()
                        .buildCoursesWithSessionsWithNotMainPractitioner(COURSES_TO_CREATE, SESSIONS_TO_CREATE, false);
    }

    @isTest
    static void CourseDoesNotHaveSessions_SessionAssignedMainPractitionerInserted_CourseShareNotCreated() {
        List<Account> branchAccounts = [SELECT Id FROM Account WHERE RecordType.Name = :ACCOUNT_BRANCH_RECORDTYPE];
        List<Contact> practitioners = [SELECT Id FROM Contact WHERE RecordType.Name = :PRACTITIONER_RECORDTYPE_NAME];
        List<Venue__c> venues = [SELECT Id FROM Venue__c];
        List<Licence_To_Practice__c> licencesToPractice = [SELECT Id FROM Licence_To_Practice__c WHERE Contact__c = :practitioners[0].Id];

        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        Course__c course = courseBuilder
            .withAccount(branchAccounts[0])
            .withPractitioner(practitioners[0])
            .withMainVenue(venues[0])
            .withLicenceToPractice(licencesToPractice[0])
            .insertRecord(true)
            .build();

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        Session__c session = sessionBuilder
            .withCourse(course)
            .withType(SESSION_TYPE_STANDARD)
            .withStatus(SESSION_STATUS_PROVISIONAL)
            .withPractitioner(practitioners[0])
            .withPractitionerLicence(licencesToPractice[0])
            .insertRecord(false)
            .build();

        List<Course__Share> courseSharesBeforeSessionInserted = [SELECT Id FROM Course__Share WHERE ParentId = :course.Id];

        Test.startTest();
        insert session;
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionInserted = [SELECT Id FROM Course__Share WHERE ParentId = :course.Id];
        System.assertEquals(0, courseSharesBeforeSessionInserted.size());
        System.assertEquals(0, courseSharesAfterSessionInserted.size());
    }
    
    @isTest
    static void PractitionerHasSessionsOnCourse_SessionAssignedPractitionerInserted_CourseShareNotCreated() {
        List<Course__c> courses = [SELECT Id FROM Course__c];
        List<Contact> practitioners = [SELECT Id FROM Contact WHERE LastName = :PRACTITIONER_LASTNAME_TWO AND recordType.Name = :PRACTITIONER_RECORDTYPE_NAME];
        List<Licence_To_Practice__c> licencesToPractice = [SELECT Id FROM Licence_To_Practice__c WHERE Contact__c = :practitioners[0].Id];

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        Session__c session = sessionBuilder
            .withCourse(courses[0])
            .withType(SESSION_TYPE_STANDARD)
            .withStatus(SESSION_STATUS_PROVISIONAL)
            .withPractitioner(practitioners[0])
            .withPractitionerLicence(licencesToPractice[0])
            .insertRecord(false)
            .build();

        List<Course__Share> courseSharesBeforeSessionInserted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];

        Test.startTest();
        insert session;
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionInserted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(1, courseSharesBeforeSessionInserted.size());
        System.assertEquals(1, courseSharesAfterSessionInserted.size());
        
    }

    @isTest
    static void PractitionersChangedOnCourseSessions_CourseShares_AssignedNewPractitionersInserted_AssignedOldPractitionersDeleted() {
        List<Course__c> courses = [SELECT Id, Main_Practitioner__c FROM Course__c];
        Contact practitionerThree = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LastName = :PRACTITIONER_LASTNAME_THREE LIMIT 1];
        User user = [SELECT Id FROM User WHERE ContactId = :practitionerThree.Id LIMIT 1];
        Account partnerAccount = [SELECT Id FROM Account WHERE IsPartner = true LIMIT 1];
        List<Licence_To_Practice__c> licencesToPractice = [SELECT Id FROM Licence_To_Practice__c WHERE Contact__c = :practitionerThree.Id];

        practitionerThree.AccountId = partnerAccount.Id;
        update practitionerThree;

        List<Course__Share> courseSharesBeforeSessionsUpdated = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        List<Session__c> sessions = [SELECT Id, Practitioner__c, Practitioner_Licence__c FROM Session__c WHERE Course__c IN :courses];

        Test.startTest();
        for (Session__c session : sessions) {
            session.Practitioner__c = practitionerThree.Id;
            session.Practitioner_Licence__c = licencesToPractice[0].Id;
        }
        update sessions;
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionsUpdated = [SELECT UserOrGroupId FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(1, courseSharesBeforeSessionsUpdated.size());
        System.assertEquals(1, courseSharesAfterSessionsUpdated.size());
        for (Course__Share courseShare : courseSharesAfterSessionsUpdated) {
            System.assertEquals(user.Id, courseShare.UserOrGroupId);            
        }
    }

    @isTest
    static void PractitionerHasSessionsOnCourse_NotLastSessionDeleted_CourseShareNotDeleted() {
        List<Course__c> courses = [SELECT Id FROM Course__c];
        List<Course__Share> courseSharesBeforeSessionDeleted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Course__c IN :courses];

        Test.startTest();
        delete sessions[0];
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionDeleted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(1, courseSharesBeforeSessionDeleted.size());
        System.assertEquals(1, courseSharesAfterSessionDeleted.size());
    }

    @isTest
    static void PractitionerHasSessionsOnCourse_AllSessionsDeleted_CourseShareDeleted() {
        List<Course__c> courses = [SELECT Id FROM Course__c];
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Course__c IN :courses];

        Test.startTest();
        delete sessions;
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionsDeleted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(0, courseSharesAfterSessionsDeleted.size());
    }
}
