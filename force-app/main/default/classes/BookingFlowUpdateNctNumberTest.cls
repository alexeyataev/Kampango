@SuppressWarnings('PMD.MethodNamingConventions')

@IsTest
public class BookingFlowUpdateNctNumberTest {

    private static final String HOUSEHOLD_ACCOUNT = 'HH_Account';
    private static final Id HOUSEHOLD_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_ACCOUNT).getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Household Account Test';
    private static final String CLIENT_RECORDTYPE_NAME  = 'Client';
    private static final String NCT_PRIMARY_NUMBER = '111111';
    private static final String NCT_PRIMARY_LASTNAME = 'Primary';
    private static final String NCT_PARTNER_NUMBER = '222222';
    private static final String NCT_PARTNER_LASTNAME = 'Partner';

    @TestSetup
    static void setupTestData(){
        Account account = new Account (
            RecordTypeId = HOUSEHOLD_ACCOUNT_RECORD_TYPE_ID,
            Name = ACCOUNT_NAME
        );
        insert account;

        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact primaryContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(account)
            .withFirstName('Dina')
            .withLastName(NCT_PRIMARY_LASTNAME)
            .insertRecord(true)
            .build();

        Contact partnerContact = contactBuilder.withRecordType(CLIENT_RECORDTYPE_NAME)
            .withAccount(account)
            .withFirstName('John')
            .withLastName(NCT_PARTNER_LASTNAME)
            .insertRecord(true)
            .build();
    }

    @IsTest
    public static void CheckNctNumber_SetNctNumberAndUpdate_NctNumberNotBeEmpty(){
        List<Contact> primaryContact = [
            SELECT Id, NCT_Number__c, Care_Status__c
            FROM Contact
            WHERE LastName = :NCT_PRIMARY_LASTNAME
        ];

        primaryContact[0].NCT_Number__c = NCT_PRIMARY_NUMBER;

        Test.startTest();
        BookingFlowUpdateNctNumber.updateContact(new List<List<Contact>>{primaryContact});
        Test.stopTest();

        List<Contact> primaryContactToTest = [
            SELECT Id, NCT_Number__c, Care_Status__c
            FROM Contact
            WHERE LastName = :NCT_PRIMARY_LASTNAME
        ];
        System.assertEquals(NCT_PRIMARY_NUMBER, primaryContactToTest[0].NCT_Number__c, 'should be returned NCT number for Primary Contact.');
    }

    @IsTest
    public static void CheckNctNumber_SetNctNumberAndUpdateForPartnerAndPrimaryContact_NctNumbersNotBeEmpty(){
        List<Contact> contactList = [
            SELECT Id, NCT_Number__c, Care_Status__c
            FROM Contact
            ORDER BY LastName DESC
        ];

        contactList[0].NCT_Number__c = NCT_PRIMARY_NUMBER;
        contactList[1].NCT_Number__c = NCT_PARTNER_NUMBER;

        Test.startTest();
        BookingFlowUpdateNctNumber.updateContact(new List<List<Contact>>{contactList});
        Test.stopTest();
        
        List<Contact> contactsToTest = [
            SELECT Id, NCT_Number__c, Care_Status__c
            FROM Contact
            ORDER BY LastName DESC
        ];
        System.assertEquals(NCT_PRIMARY_NUMBER, contactsToTest[0].NCT_Number__c, 'should be returned NCT number for Primary Contact.');
        System.assertEquals(NCT_PARTNER_NUMBER, contactsToTest[1].NCT_Number__c, 'should be returned NCT number for Partner Contact.');

    }
}