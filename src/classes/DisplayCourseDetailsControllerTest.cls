@isTest
private class DisplayCourseDetailsControllerTest {
	
	private final static String practitionerRecordTypeName = 'Practitioner';
	private static Contact practitioner;

	@isTest
	static void CourseQuery_WithValidCourseDataPresent_ReturnsCorrectData() {
		
		setupTestData();

		TestCourseBuilder courseBuilder = new TestCourseBuilder();
		Course__c course = courseBuilder.WithPractitioner(practitioner)
										.WithFee(200.00)
										.WithCourseType('NCT Signature')
										.InsertRecord(true)
										.Build();

		DisplayCourseDetailsController controller = new DisplayCourseDetailsController();
		controller.courseId = course.Id;

		Test.startTest();

		Course__c returnedCourse = controller.getCourse();

		Test.stopTest();

		System.assertEquals(200.00, returnedCourse.Fee__c);
		System.assertEquals('NCT Signature', returnedCourse.Course_Type__c);
	}

	private static void setupTestData()
	{
		TestContactbuilder practitionerContactBuilder = new TestContactbuilder();
		practitioner = practitionerContactBuilder.WithRecordType(practitionerRecordTypeName)
										.InsertRecord(true)
										.Build();
	}	
}