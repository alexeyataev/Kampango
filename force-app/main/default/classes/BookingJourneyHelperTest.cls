@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #36 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public class BookingJourneyHelperTest {
    private static final String HOUSEHOLD_ACCOUNT = 'HH_Account';
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
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(accounts[0])
            .withFirstName('Test')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(accounts[1])
            .withFirstName('Test')
            .withLastName('Partner')
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
            WHERE LastName = 'Primary'
        ];
        for(Contact contact :primaryContact){
            contact.npe01__PreferredPhone__c = 'Mobile';
            contact.FirstName = 'Test1';
        }
        Test.startTest();
        BookingJourneyHelper.updateContact(primaryContact);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Contact WHERE FirstName = 'Test1' AND npe01__PreferredPhone__c = 'Mobile'].size());
    }

    @IsTest
    static void updateContact_partnerContactWithId_contactUpdated(){
        List<Contact> partnerContact = [
            SELECT Id, npe01__PreferredPhone__c, FirstName, LastName, Salutation
            FROM Contact
            WHERE LastName = 'Partner'
        ];
        for(Contact contact :partnerContact){
            contact.npe01__PreferredPhone__c = 'Home';
            contact.FirstName = 'Test2';
        }
        Test.startTest();
        BookingJourneyHelper.updateContact(partnerContact);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Contact WHERE FirstName = 'Test2' AND npe01__PreferredPhone__c = 'Home'].size());
    }

    @IsTest
    static void updateContact_partnerContactNoId_contactCreated(){
        TestContactBuilder contactBuilder = new TestContactBuilder();
        List<Contact> partnerContact = new List<Contact>{
            contactBuilder.withRecordType('Client')
                .withAccount([SELECT Id FROM Account LIMIT 1])
                .withFirstName('Test')
                .withLastName('PartnerNew')
                .withEmail('partner@nct.com')
                .insertRecord(false)
                .build()
        };
        Test.startTest();
        BookingJourneyHelper.updateContact(partnerContact);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Contact WHERE FirstName = 'Test' AND LastName = 'PartnerNew'].size());
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