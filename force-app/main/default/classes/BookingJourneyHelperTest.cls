@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #36 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
public class BookingJourneyHelperTest {

    public static String createPrimaryContact(){
        Account account = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Test Household'
        );
        insert account;
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Primary')
            .insertRecord(true)
            .build();
        return primaryContact.Id;
    }

    public static String createPartnerContact(){
        Account account = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(),
            Name = 'Test Household2'
        );
        insert account;
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
        return partnerContact.Id;
    }

    public static String createIndividual(){
        TestIndividualBuilder individualBuilder = new TestIndividualBuilder();
        Individual individual = individualBuilder.withFirstName('FirstName')
            .withLastName('LastName')
            .withSalutation('Mr.')
            .insertRecord(true)
            .build();
        return individual.Id;
    }

    @IsTest
    static void updateContact_primaryContact_contactUpdated(){
        String primaryId = BookingJourneyHelperTest.createPrimaryContact();
        String partnerId = BookingJourneyHelperTest.createPartnerContact();
        List<Contact> primaryContact = [
            SELECT Id, npe01__PreferredPhone__c, FirstName, LastName, Salutation
            FROM Contact
            WHERE Id = :primaryId
        ];
        for(Contact contact :primaryContact){
            contact.npe01__PreferredPhone__c = 'Mobile';
            contact.FirstName = 'Test1';
        }
        Test.startTest();
        BookingJourneyHelper.updateContact(primaryContact);
        Test.stopTest();
        System.assertEquals(
            [
                SELECT Id 
                FROM Contact 
                WHERE FirstName = 'Test1' 
                AND npe01__PreferredPhone__c = 'Mobile'
            ].size(),
            1
        );
    }

    @IsTest
    static void updateContact_partnerContactWithId_contactUpdated(){
        String primaryId = BookingJourneyHelperTest.createPrimaryContact();
        String partnerId = BookingJourneyHelperTest.createPartnerContact();
        List<Contact> partnerContact = [
            SELECT Id, npe01__PreferredPhone__c, FirstName, LastName, Salutation
            FROM Contact
            WHERE Id = :partnerId
        ];
        for(Contact contact :partnerContact){
            contact.npe01__PreferredPhone__c = 'Home';
            contact.FirstName = 'Test2';
        }
        Test.startTest();
        BookingJourneyHelper.updateContact(partnerContact);
        Test.stopTest();
        System.assertEquals(
            [
                SELECT Id 
                FROM Contact 
                WHERE FirstName = 'Test2' 
                AND npe01__PreferredPhone__c = 'Home'
            ].size(),
            1
        );
    }

    @IsTest
    static void updateContact_partnerContactNoId_contactCreated(){
        String primaryId = BookingJourneyHelperTest.createPrimaryContact();
        String partnerId = BookingJourneyHelperTest.createPartnerContact();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        List<Contact> partnerContact = new List<Contact>{
            contactBuilder.withRecordType('Client')
                .withAccount([SELECT Id FROM Account LIMIT 1])
                .withFirstName('Test')
                .withLastName('PartnerNew')
                .insertRecord(false)
                .build()
        };
        Test.startTest();
        BookingJourneyHelper.updateContact(partnerContact);
        Test.stopTest();
        System.assertEquals(
            [
                SELECT Id 
                FROM Contact 
                WHERE FirstName = 'Test' 
                AND LastName = 'PartnerNew'
            ].size(),
            1
        );
    }

    @IsTest
    static void updateContact_emptyList_noUpdate(){
        Datetime timeStamp = System.now();
        Test.startTest();
        BookingJourneyHelper.updateContact(new List<Contact>());
        Test.stopTest();
        System.assert(
            [
                SELECT Id 
                FROM Contact 
                WHERE LastModifiedDate > :timeStamp
            ].isEmpty()
        );
    }

    @IsTest
    static void retrieveIndividual_individualId_individualRetrieved(){
        String individualId = createIndividual();
        Test.startTest();
        Individual individual = BookingJourneyHelper.retrieveMarketingPreferences(individualId);
        Test.stopTest();
        System.assertEquals(individualId, individual.Id);
    }

    @IsTest
    static void retrieveIndividual_null_nullReturned(){
        Test.startTest();
        Individual individual = BookingJourneyHelper.retrieveMarketingPreferences(null);
        Test.stopTest();
        System.assertEquals(null, individual);
    }


}