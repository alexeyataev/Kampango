@isTest
public with sharing class PractitionerDetailsControllerTest {

    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';

    @TestSetup 
    private static void SetupTestData() {
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
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS).buildSessionWithTypeAndStatus('Reunion', 'Confirmed');
    }

    @IsTest
	public static void generateCourseSummaryPractitionerDetails() {

		Course__c course = [
			SELECT Id 
			FROM Course__c
			LIMIT 1
		];

		List<Contact> practitioners = [
			SELECT Name, Phone, Email 
			FROM Contact 
			WHERE Id 
				IN (SELECT Practitioner__c 
					FROM Session__c 
					WHERE Course__c = :course.Id)
		];

		PractitionerDetailsController practitionerDetailsController = new PractitionerDetailsController();
		practitionerDetailsController.courseRecord = course;
		practitionerDetailsController.practitionerFieldSetName = 'CourseSummaryPractitionerFields';

		Test.startTest();

		List<Contact> practitionersToTest = practitionerDetailsController.getPractitioners();

		Test.stopTest();

		System.assertEquals(practitionersToTest, practitioners);

	}
}
