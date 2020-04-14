@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #36 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public class BookingJourneyHelperTest {
    private static final String HOUSEHOLD_ACCOUNT = 'HH_Account';
    private static final String NCT_PRIMARY_FIRSTNAME = 'Test';
    private static final String NCT_NEW_PRIMARY_FIRSTNAME = 'Test1';
    private static final String NCT_PRIMARY_LASTNAME = 'Primary';
    private static final String NCT_PARTNER_FIRSTNAME = 'Test';
    private static final String NCT_NEW_PARTNER_FIRSTNAME = 'Test2';
    private static final String NCT_PARTNER_LASTNAME = 'Partner';
    private static final String NCT_NEW_PARTNER_LASTNAME = 'PartnerNew';
    private static final String CLIENT_RECORDTYPE_NAME  = 'Client';
    private static final String PREFERRED_PHONE_MOBILE  = 'Mobile';
    private static final String PREFERRED_PHONE_HOME  = 'Home';
    private static final Id HOUSEHOLD_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_ACCOUNT).getRecordTypeId();

    @TestSetup
    static void setupTestData(){
        List<Account> accounts = new List<Account>{
            new Account(
                RecordTypeId = HOUSEHOLD_ACCOUNT_RECORD_TYPE_ID,
                Name = 'Test Household'
            ),
            new Account(
                RecordTypeId = HOUSEHOLD_ACCOUNT_RECORD_TYPE_ID,
                Name = 'Test Household2'
            )
        };
        insert accounts;

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(accounts[0])
            .withFirstName(NCT_PRIMARY_FIRSTNAME)
            .withLastName(NCT_PRIMARY_LASTNAME)
            .insertRecord(true)
            .build();
        Contact partnerContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(accounts[1])
            .withFirstName(NCT_PARTNER_FIRSTNAME)
            .withLastName(NCT_PARTNER_LASTNAME)
            .insertRecord(true)
            .build();
        TestIndividualBuilder individualBuilder = new TestIndividualBuilder();
        Individual individual = individualBuilder.withFirstName('FirstName')
            .withLastName('LastName')
            .withSalutation('Mr.')
            .insertRecord(true)
            .build();
    }

    @IsTest
    static void updateContact_primaryContact_contactUpdated(){
        List<Contact> primaryContact = [
            SELECT Id, npe01__PreferredPhone__c, FirstName, LastName, Salutation
            FROM Contact
            WHERE LastName = :NCT_PRIMARY_LASTNAME
        ];
        for(Contact contact :primaryContact){
            contact.npe01__PreferredPhone__c = PREFERRED_PHONE_MOBILE;
            contact.FirstName = NCT_NEW_PRIMARY_FIRSTNAME;
        }
        Test.startTest();
        BookingJourneyHelper.updateContact(primaryContact);
        Test.stopTest();

        List<Contact> contactsToTest = [SELECT Id FROM Contact WHERE FirstName = :NCT_NEW_PRIMARY_FIRSTNAME AND npe01__PreferredPhone__c = :PREFERRED_PHONE_MOBILE];
        System.assertEquals(1, contactsToTest.size());
    }

    @IsTest
    static void updateContact_partnerContactWithId_contactUpdated(){
        List<Contact> partnerContact = [
            SELECT Id, npe01__PreferredPhone__c, FirstName, LastName, Salutation
            FROM Contact
            WHERE LastName = :NCT_PARTNER_LASTNAME
        ];
        for(Contact contact :partnerContact){
            contact.npe01__PreferredPhone__c = PREFERRED_PHONE_HOME;
            contact.FirstName = NCT_NEW_PARTNER_FIRSTNAME;
        }
        Test.startTest();
        BookingJourneyHelper.updateContact(partnerContact);
        Test.stopTest();

        List<Contact> contactsToTest = [SELECT Id FROM Contact WHERE FirstName = :NCT_NEW_PARTNER_FIRSTNAME AND npe01__PreferredPhone__c = :PREFERRED_PHONE_HOME];
        System.assertEquals(1, contactsToTest.size());
    }

    @IsTest
    static void updateContact_partnerContactNoId_contactCreated(){
        TestContactBuilder contactBuilder = new TestContactBuilder();
        List<Contact> partnerContact = new List<Contact>{
            contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
                .withAccount([SELECT Id FROM Account LIMIT 1])
                .withFirstName(NCT_NEW_PARTNER_FIRSTNAME)
                .withLastName(NCT_NEW_PARTNER_LASTNAME)
                .withEmail('partner@nct.com')
                .insertRecord(false)
                .build()
        };
        Test.startTest();
        BookingJourneyHelper.updateContact(partnerContact);
        Test.stopTest();

        List<Contact> contactsToTest = [SELECT Id FROM Contact WHERE FirstName = :NCT_NEW_PARTNER_FIRSTNAME AND LastName = :NCT_NEW_PARTNER_LASTNAME];
        System.assertEquals(1, contactsToTest.size());
    }

    @IsTest
    static void updateContact_emptyList_noUpdate(){
        Datetime timeStamp = System.now();
        Test.startTest();
        BookingJourneyHelper.updateContact(new List<Contact>());
        Test.stopTest();
        System.assert([SELECT Id FROM Contact WHERE LastModifiedDate > :timeStamp].isEmpty());
    }

    @IsTest
    static void retrieveIndividual_individualId_individualRetrieved(){
        Id individualId = [SELECT Id FROM Individual LIMIT 1].Id;
        Test.startTest();
        Individual individualToTest = BookingJourneyHelper.retrieveMarketingPreferences(individualId);
        Test.stopTest();
        System.assertEquals(individualId, individualToTest.Id);
    }

    @IsTest
    static void retrieveIndividual_null_nullReturned(){
        Test.startTest();
        Individual individualToTest = BookingJourneyHelper.retrieveMarketingPreferences(null);
        Test.stopTest();
        System.assertEquals(null, individualToTest);
    }
}