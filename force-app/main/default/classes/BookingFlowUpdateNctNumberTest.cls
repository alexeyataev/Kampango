@SuppressWarnings('PMD.MethodNamingConventions')

@IsTest
public class BookingFlowUpdateNctNumberTest {

    private static final Id RECORD_TYPE_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Household Account Test';
    private static final String CLIENT_RECORDTYPE_NAME  = 'Client';
    private static final String NCT_PRIMARY_NUMBER = '111111';
    private static final String NCT_PARTNER_NUMBER = '222222';

    public static String createPrimaryContact() {
        Account account = new Account (
            RecordTypeId = RECORD_TYPE_ID,
            Name = ACCOUNT_NAME
        );

        insert account;

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(account)
            .withFirstName('Dina')
            .withLastName('Primary')
            .insertRecord(true)
            .build();

        return primaryContact.Id;
    }

     public static String createPartnerContact(){
        Account account = new Account (
            RecordTypeId = RECORD_TYPE_ID,
            Name = ACCOUNT_NAME
        );

        insert account;

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact partnerContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Partner')
            .insertRecord(true)
            .build();

        return partnerContact.Id;
    }

    @IsTest
    public static void CheckNctNumber_SetNctNumberAndUpdate_NctNumberNotBeEmpty() {
        String primaryId = BookingJourneyHelperTest.createPrimaryContact();

        List<Contact> primaryContact = [
            SELECT Id, NCT_Number__c, Care_Status__c
            FROM Contact
            WHERE Id = :primaryId
        ];

        primaryContact[0].NCT_Number__c = NCT_PRIMARY_NUMBER;

        Test.startTest();
            BookingFlowUpdateNctNumber.updateContact(new List<List<Contact>>{primaryContact});
        Test.stopTest();

        System.assertEquals(NCT_PRIMARY_NUMBER, [SELECT Name, NCT_Number__c FROM Contact][0].NCT_Number__c, 'should be returned NCT number for Primary Contact.');
    }

    @IsTest
    public static void CheckNctNumber_SetNctNumberAndUpdateForPartnerAndPrimaryContact_NctNumbersNotBeEmpty() {
        String primaryId = BookingJourneyHelperTest.createPrimaryContact();
        String partnerId = BookingJourneyHelperTest.createPartnerContact();

        Set<Id> contactIds = new Set<Id> {
            primaryId,
            partnerId
        };

        List<Contact> contactList = [
            SELECT Id, NCT_Number__c, Care_Status__c
            FROM Contact
            WHERE Id in :contactIds
        ];

        contactList[0].NCT_Number__c = NCT_PRIMARY_NUMBER;
        contactList[1].NCT_Number__c = NCT_PARTNER_NUMBER;

        Test.startTest();
            BookingFlowUpdateNctNumber.updateContact(new List<List<Contact>>{contactList});
        Test.stopTest();
        
        System.assertEquals(NCT_PRIMARY_NUMBER, [SELECT Name, NCT_Number__c FROM Contact][0].NCT_Number__c, 'should be returned NCT number for Primary Contact.');
        System.assertEquals(NCT_PARTNER_NUMBER, [SELECT Name, NCT_Number__c FROM Contact][1].NCT_Number__c, 'should be returned NCT number for Partner Contact.');

    }
}