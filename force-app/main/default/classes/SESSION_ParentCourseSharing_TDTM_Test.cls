@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #149 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
public class SESSION_ParentCourseSharing_TDTM_Test {
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_LASTNAME_TWO = 'Jones';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String PRACTITIONER_PROFILE_NAME = 'Practitioner';
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
                        .buildPractitioner(PRACTITIONER_LASTNAME_TWO, PRACTITIONER_EMAIL_ADDRESS);
            TestDataFactory.convertPractitionerToPartnerCommunityUser();
            dataFactory .buildPractitionerFeeRate()
                        .buildVenue()
                        .buildVirtualVenue('Virtual')
                        .buildRoom()
                        .buildLicenceToPractice()
                        .buildCoursesWithSessions(COURSES_TO_CREATE, SESSIONS_TO_CREATE);
    }
    
    @isTest
    static void PractitionerHasSessionsOnCourse_SessionInserted_NewCourseShareNotCreated() {
        List<Course__c> courses = [SELECT Id, Main_Practitioner__c FROM Course__c];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :courses[0].Main_Practitioner__c];
        List<Licence_To_Practice__c> licencesToPractice = [SELECT Id FROM Licence_To_Practice__c WHERE Contact__c = :courses[0].Main_Practitioner__c];

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        Session__c session = sessionBuilder
            .withCourse(courses[0])
            .withType(SESSION_TYPE_STANDARD)
            .withStatus(SESSION_STATUS_PROVISIONAL)
            .withPractitioner(contacts[0])
            .withPractitionerLicence(licencesToPractice[0])
            .insertRecord(false)
            .build();

        List<Course__Share> courseSharesBeforeSessionInserted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];

        Test.startTest();
        insert session;
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionInserted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(courseSharesBeforeSessionInserted.size(), courseSharesAfterSessionInserted.size());
    }

    @isTest
    static void PractitionersChangedOnCourseSessions_CourseShares_AssignedNewPractitionersInserted_AssignedOldPractitionersDeleted() {
        List<Course__c> courses = [SELECT Id, Main_Practitioner__c FROM Course__c];
        Contact practitionerTwo = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LastName = :PRACTITIONER_LASTNAME_TWO LIMIT 1];
        Account partnerAccount = [SELECT Id FROM Account WHERE IsPartner = true LIMIT 1];

        practitionerTwo.AccountId = partnerAccount.Id;
        update practitionerTwo;

        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        Licence_To_Practice__c licenceToPractice = licenceToPracticeBuilder
            .withContact(practitionerTwo)
            .insertRecord(true)
            .build();

        TestUserBuilder userBuilder = new TestUserBuilder();
        User user = userBuilder
            .withUsername(practitionerTwo.LastName + practitionerTwo.LastName + '@ncttest.com')
            .withContactId(practitionerTwo.Id)
            .withProfile([SELECT Id FROM Profile WHERE Name = :PRACTITIONER_PROFILE_NAME LIMIT 1].Id)
            .withCommunityNickName(practitionerTwo.LastName + practitionerTwo.LastName)
            .withEmail(practitionerTwo.Email)
            .insertRecord(true)
            .build();
        
        List<Course__Share> courseSharesBeforeSessionsUpdated = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        List<Session__c> sessions = [SELECT Id, Practitioner__c, Practitioner_Licence__c FROM Session__c WHERE Course__c IN :courses];

        Test.startTest();
        for (Session__c session : sessions) {
            session.Practitioner__c = practitionerTwo.Id;
            session.Practitioner_Licence__c = licenceToPractice.id;
        }
        update sessions;
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionsUpdated = [SELECT UserOrGroupId FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(courseSharesBeforeSessionsUpdated.size(), courseSharesAfterSessionsUpdated.size());
        for (Course__Share courseShare : courseSharesAfterSessionsUpdated) {
            System.assertEquals(user.Id, courseShare.UserOrGroupId);            
        }
    }

    @isTest
    static void PractitionerHasSessionsOnCourse_NotLastSessionDeleted_CourseShareNotDeleted() {
        List<Course__c> courses = [SELECT Id, Main_Practitioner__c FROM Course__c];
        List<Course__Share> courseSharesBeforeSessionDeleted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Course__c IN :courses];

        Test.startTest();
        delete sessions[0];
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionDeleted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(courseSharesBeforeSessionDeleted.size(), courseSharesAfterSessionDeleted.size());
    }

    @isTest
    static void PractitionerHasSessionsOnCourse_AllSessionsDeleted_CourseShareDeleted() {
        List<Course__c> courses = [SELECT Id, Main_Practitioner__c FROM Course__c];
        List<Session__c> sessions = [SELECT Id FROM Session__c WHERE Course__c IN :courses];

        Test.startTest();
        delete sessions;
        Test.stopTest();

        List<Course__Share> courseSharesAfterSessionsDeleted = [SELECT Id FROM Course__Share WHERE ParentId IN :courses];
        System.assertEquals(0, courseSharesAfterSessionsDeleted.size());
    }
}
