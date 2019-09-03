@IsTest
public class BookingJourneyHelperTest {

    @TestSetup
    static void createTestData(){
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
        Contact partnerContact = contactBuilder.withRecordType('Client')
            .withAccount(account)
            .withFirstName('Test')
            .withLastName('Partner')
            .insertRecord(true)
            .build();
    }

    @IsTest
    static void updateContact_primaryContact_contactUpdated(){
        List<Contact> primaryContact = [
            SELECT Id, npe01__PreferredPhone__c, FirstName, LastName
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
        List<Contact> partnerContact = [
            SELECT Id, npe01__PreferredPhone__c, FirstName, LastName
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


}
