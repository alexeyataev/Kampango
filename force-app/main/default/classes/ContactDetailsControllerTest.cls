@isTest
public with sharing class ContactDetailsControllerTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';

    @TestSetup 
    private static void setupTestData() {
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
                    .buildSession()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildReunion();
    }

    @IsTest
	public static void generateCourseSummaryContactDetails() {

		Course__c course = [
			SELECT Id 
			FROM Course__c
			LIMIT 1
		];

        List<Contact> contacts = [
			SELECT Id
			FROM Contact 
		];

		List<Id> contactsIds = new List<Id>();

        for (Contact cont : contacts) {
            contactsIds.add(cont.Id);
        }

		ContactDetailsController contactDetailsController = new ContactDetailsController();
		contactDetailsController.contactIds = contactsIds;
		contactDetailsController.contactFieldSetName = 'CourseSummaryEmergencyContactFields';

		Test.startTest();

		List<Contact> contactsToTest = contactDetailsController.getContacts();

		Test.stopTest();

		System.assertEquals(contactsToTest[0].Id, contacts[0].Id);

	}
}
