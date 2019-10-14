@isTest
public without sharing class TestDataFactory {

    private static final String SESSION_PROVISIONAL_STATUS = 'Provisional';
    private static final String PRACTITIONER_RECORDTYPE_NAME  = 'Practitioner';
    private static final String PRACTITIONER_PROFILE_NAME = 'Practitioner';
    private static final String PRACTITIONER_USERNAME = 'ncttest@test.com';
    private static final String PORTAL_ACCOUNT_OWNER_USERNAME = 'portalAccountOwner@ncttest.com';
    private static final String SYSTEM_ADMIN_USERNAME = 'NCTtest.sysAdmin.username@ncttest.com';
    private static final String PORTAL_ACCOUNT_USER_EMAIL = 'portalAccountUserNCT@ncttest.com';
    private static final String PARTNER_COMMUNITY_USER_EMAIL = 'partnerCommunityUser@ncttest.com';
    private static final String TEST_BILLING_EMAIL = 'billingEmail@ncttest.com';
    private static final String COMMUNITY_NICKNAME_ONE = 'NICKNAME_ONE';
    private static final String COMMUNITY_NICKNAME_TWO = 'NICKNAME_TWO';
    private static final String ACCOUNT_BRANCH_RECORDTYPE = 'Branch';
    private static final String ACCOUNT_ORGANIZATION_RECORDTYPE = 'Organization';

    public static List<Course__c> courses = new List<Course__c>();
    public static List<Session__c> sessions = new List<Session__c>();
    public static List<User> users = new List<User>();
    private List<Contact> practitioners = new List<Contact>();
    private Account branchAccount;
    private static Account organizationAccount;
    private Course_Assignment__c courseAssignment;
    private Venue__c venue;
    private Venue__c mainVenue;
    private Room__c room;
    private Licence_To_Practice__c licenceToPractice;
    private Course__c course;
    private Session__c session;
    private Session__c reunion;

    private static TestDataFactory instance;

    public static TestDataFactory getInstance() {
        if (instance == NULL) {
            instance = new TestDataFactory();
        }
        return instance;
    }

    public TestDataFactory buildBranchAccount() {
        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        branchAccount =  accountBranchBuilder
            .withRecordType(ACCOUNT_BRANCH_RECORDTYPE)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildOrganizationAccount(String accountNumber) {
        TestAccountBuilder accountBranchBuilder = new TestAccountBuilder();
        organizationAccount = accountBranchBuilder
            .withRecordType(ACCOUNT_ORGANIZATION_RECORDTYPE)
            .withName('John Smith')
            .withType('Supplier')
            .withAccountNumber(accountNumber)
            .withBillingEmail(TEST_BILLING_EMAIL)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildPractitioner(String lastName) {
        return buildPractitioner(lastName, null);
    }

    public TestDataFactory buildPractitioner(String lastName, String email) {
        TestContactBuilder practitionerContactBuilder = new TestContactBuilder();
        practitioners.add(practitionerContactBuilder
            .withRecordType(PRACTITIONER_RECORDTYPE_NAME)
            .withAccount(organizationAccount)
            .withLastName(lastName)
            .withEmail(email)
            .insertRecord(true)
            .build());
        return this;
    }

    public TestDataFactory buildVenue() {
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        venue = venueBuilder
            .insertRecord(true)
            .build();
        return this;
    }
    
    public TestDataFactory buildMainVenue() {
        TestVenueBuilder venueBuilder = new TestVenueBuilder();
        mainVenue = venueBuilder
            .insertRecord(true)
            .build();
        return this;
    }
    public TestDataFactory buildRoom() {
        TestRoomBuilder roomBuilder = new TestRoomBuilder();
        room = roomBuilder
            .withVenue(venue)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildLicenceToPractice() {
        TestLicenceToPracticeBuilder licenceToPracticeBuilder = new TestLicenceToPracticeBuilder();
        licenceToPractice = licenceToPracticeBuilder
            .withContact(practitioners[0])
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildCourse() {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .withAccount(branchAccount)
            .withPractitioner(practitioners[0])
            .withLicenceToPractice(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildCourseAssignment() {
        TestCourseAssignmentBuilder courseAssignmentBuilder = new TestCourseAssignmentBuilder();
        courseAssignment = courseAssignmentBuilder
            .withCourse(course)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildCourseWithTypeAndSubType(String type, String subtype) {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        course = courseBuilder
            .withAccount(branchAccount)
            .withPractitioner(practitioners[0])
            .withLicenceToPractice(licenceToPractice)
            .withType(type)
            .withSubType(subtype)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildSession() {
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        session = sessionBuilder
            .withCourse(course)
            .withVenue(venue)
            .withRoom(room)
            .withStatus(SESSION_PROVISIONAL_STATUS)
            .withPractitioner(practitioners[0])
            .withPractitionerLicence(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

public TestDataFactory buildReunion() {
        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        reunion = sessionBuilder
            .withCourse(course)
            .withType('Reunion')
            .withVenue(venue)
            .withRoom(room)
            .withStatus(SESSION_PROVISIONAL_STATUS)
            .withPractitioner(practitioners[0])
            .withPractitionerLicence(licenceToPractice)
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildEstimatedCosts() {
        TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
        estimatedCostsBuilder
            .withCourse(course)
            .insertRecord(true)
            .build();
        estimatedCostsBuilder
            .withCourse(course)
            .withType('Venue')
            .insertRecord(true)
            .build();
        estimatedCostsBuilder
            .withCourse(course)
            .withType('Practitioner Fee')
            .insertRecord(true)
            .build();
        return this;
    }

    public TestDataFactory buildCoursesWithSessions(Integer numberOfCourses, Integer numberOfSessions) {
        TestCourseBuilder courseBuilder = new TestCourseBuilder();
        for(Integer i = 0; i < numberOfCourses; i++) {
            courses.add(courseBuilder
                .withAccount(branchAccount)
                .withPractitioner(practitioners[0])
                .withLicenceToPractice(licenceToPractice)
                .withMainVenue()
                .insertRecord(true)
                .build());
        }

        for(Integer i = 0; i < numberOfCourses; i++) {
            TestEstimatedCostsBuilder estimatedCostsBuilder = new TestEstimatedCostsBuilder();
            estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Travel')
                .insertRecord(true)
                .build();
            estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Venue')
                .insertRecord(true)
                .build();
            estimatedCostsBuilder
                .withCourse(courses[i])
                .withType('Practitioner Fee')
                .insertRecord(true)
                .build();
        }

        TestSessionBuilder sessionBuilder = new TestSessionBuilder();
        for(Integer i = 0; i < numberOfSessions; i++) {
            sessions.add(sessionBuilder
                .withCourse(courses[i / 2])
                .withVenue(venue)
                .withRoom(room)
                .withStatus('Confirmed')
                .withPractitioner(practitioners[0])
                .withPractitionerLicence(licenceToPractice)
                .insertRecord(true)
                .build());
        }
        return this;
    }

    public static User createSysAdminUser() {
        TestUserBuilder userBuilder = new TestUserBuilder();
        users.add(userBuilder
            .withProfile([SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id)
            .withUsername(SYSTEM_ADMIN_USERNAME)
            .insertRecord(true)
            .build());
        return users[0];
    }

    public static User convertPractitionerToPartnerCommunityUser() {

        System.runAs(createSysAdminUser()) {
            UserRole testRole = new UserRole(Name = 'testRole');
            insert testRole;

            TestUserBuilder userBuilder = new TestUserBuilder();
            users.add((userBuilder
                .withUsername(PORTAL_ACCOUNT_OWNER_USERNAME)
                .withUserRoleId(testRole.Id)
                .withProfile([SELECT Id FROM Profile WHERE Name = 'Finance'].Id)
                .withEmail(PORTAL_ACCOUNT_USER_EMAIL)
                .withCommunityNickName(COMMUNITY_NICKNAME_ONE)
                .withAlias('AcOwner')
                .insertRecord(true)
                .build()));
        }

        TestDataFactory testDataFactory = TestDataFactory.getInstance();
        testDataFactory.buildOrganizationAccount('acc5');
        organizationAccount.IsPartner = true;
        organizationAccount.OwnerId = users[1].Id;
        update organizationAccount;

        Contact practitioner = [SELECT Id, Name FROM Contact WHERE Name = 'John Smith' LIMIT 1];
        practitioner.AccountId = organizationAccount.Id;
        update practitioner;

        TestUserBuilder userBuilder = new TestUserBuilder();
        users.add((userBuilder
            .withUsername(PRACTITIONER_USERNAME)
            .withContactId(practitioner.Id)
            .withProfile([SELECT Id FROM Profile WHERE Name =:PRACTITIONER_PROFILE_NAME LIMIT 1].Id)
            .withCommunityNickName(COMMUNITY_NICKNAME_TWO)
            .withEmail(PARTNER_COMMUNITY_USER_EMAIL)
            .insertRecord(true)
            .build()));

        return users[2];
    }

    public TestDataFactory setSessionsToConfirmed(List<Session__c> sessions){
        for(Session__c aSession : sessions){
            aSession.Status__c = 'Confirmed';
        }
        update sessions;
        return this;
    }

    public TestDataFactory SetCoursesToFinal(List<Course__c> courses){
        for(Course__c course : courses){
            course.Status__c = 'Final';
        }
        update courses;
        return this;
    }
}