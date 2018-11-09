@isTest
private class DisplayCourseSessionsControllerTest {
	
	private static Course__c course;

	@isTest static void GetSessions_WhenValidSessionsExist_ReturnsListOfSessions() {
		
		setupTestData();

		Datetime initialStartTime = (Datetime.newInstance(2017, 3, 20, 18, 0, 0));

		TestSessionBuilder sessionBuilder = new TestSessionBuilder();
		sessionBuilder.WithCourse(course.Id)
					.WithStartTime(initialStartTime)
					.WithEndTime(initialStartTime.addHours(2))
					.InsertRecord(true).Build();

		sessionBuilder.WithCourse(course.Id)
					.WithStartTime(initialStartTime.addDays(7))
					.WithEndTime(initialStartTime.addDays(7).addHours(2).addMinutes(30))
					.InsertRecord(true).Build();

		DisplayCourseSessionsController controller = new DisplayCourseSessionsController();
		controller.courseId = course.Id;

		Test.startTest();

		List<Session__c> sessions = controller.getSessions();

		Test.stopTest();

		System.assertEquals(2, sessions.size());
		System.assertEquals('2 hours', sessions.get(0).Duration_Formatted__c);
		System.assertEquals(initialStartTime, sessions.get(0).Start__c);
		System.assertEquals('2 hours and 30 minutes', sessions.get(1).Duration_Formatted__c);
	}

	private static void setupTestData()
	{
		String practitionerRecordTypeName = 'Practitioner';

		TestContactbuilder practitionerContactBuilder = new TestContactbuilder();
		Contact practitioner = practitionerContactBuilder.WithRecordType(practitionerRecordTypeName)
										.InsertRecord(true)
										.Build();

		TestCourseBuilder courseBuilder = new TestCourseBuilder();
		course = courseBuilder.WithPractitioner(practitioner)
										.WithFee(200.00)
										.WithCourseType('NCT Signature')
										.InsertRecord(true)
										.Build();
	}
	
}