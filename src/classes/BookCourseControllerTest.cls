@isTest
private class BookCourseControllerTest {

	private final static String clientRecordTypeName = 'Client';
	private final static String practitionerRecordTypeName = 'Practitioner';
	private final static Decimal courseFee = 180.00;

	private static Contact client;
	private static Contact practitioner;
	private static Course__c course;
	private static Booking__c booking;


	@isTest
	static void LoadingPage_WithBookingStatusEnquiry_ReturnsNotAvailableState() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.InsertRecord(true)
								.Build();

		Test.startTest();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.stopTest();

		System.assertEquals('NotAvailable', model.status);
	}
	
	@isTest
	static void LoadingPage_WithBookingStatusConfirmed_ReturnsNotAvailableState() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Confirmed')
								.InsertRecord(true)
								.Build();

		Test.startTest();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.stopTest();

		System.assertEquals('NotAvailable', model.status);
	}

	@isTest
	static void LoadingPage_WithBookingStatusLapsed_ReturnsNotAvailableState() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Lapsed')
								.InsertRecord(true)
								.Build();

		Test.startTest();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.stopTest();

		System.assertEquals('NotAvailable', model.status);
	}

	@isTest
	static void LoadingPage_WithBookingStatusReserved_ReturnsAcceptState() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.startTest();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.stopTest();

		System.assertEquals('Accept', model.status);
	}

	@isTest
	static void CallingNext_FromAcceptState_ReturnsNextState() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.startTest();

		controller.next();

		Test.stopTest();

		System.assertEquals('Confirm', model.status);
	}

	@isTest
	static void CallingBack_FromPaymentState_ReturnsPreviousState() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		System.assertEquals('Accept', model.status);

		controller.next();
		controller.next();

		System.assertEquals('Payment', model.status);

		Test.startTest();

		controller.back();

		Test.stopTest();

		System.assertEquals('Confirm', model.status);
	}

	@isTest
	static void CheckingWhetherToDisplayNext_FromAcceptState_ReturnsTrue() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.startTest();

		Boolean displayNext = controller.getDisplayNext();

		Test.stopTest();

		System.assertEquals(true, displayNext);
	}

	@isTest
	static void CheckingWhetherToDisplayNext_FromFinalState_ReturnsFalse() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;
		model.status = 'Submit';

		Test.startTest();

		Boolean displayNext = controller.getDisplayNext();

		Test.stopTest();

		System.assertEquals(false, displayNext);
	}

	@isTest
	static void CheckingWhetherToDisplayBack_FromInitialState_ReturnsFalse() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.startTest();

		Boolean displayNext = controller.getDisplayBack();

		Test.stopTest();

		System.assertEquals(false, displayNext);
	}

	@isTest
	static void CheckingWhetherToDisplayBack_FromSecondState_ReturnsTrue() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;
		controller.next();

		Test.startTest();

		Boolean displayNext = controller.getDisplayBack();

		Test.stopTest();

		System.assertEquals(true, displayNext);
	}

	@isTest
	static void NavigateToDdPaymentPageAndSelectingPaymentDate_WithMembershipSelectedButCourseNotSelected_IndicatesThatMembershipDdScheduleIsValidAndCourseScheduleIsNotValid() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		booking.Membership_Choice__c = 'Standard 1-year single payment option - £48';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';
		controller.next();

		controller.next();

		Test.startTest();

		booking.Membership_Payment_Method__c = 'I wish to pay my membership by Direct Debit';
		booking.Preferred_Payment_Date__c = '20th';

		Test.stopTest();

		System.assertEquals(true, controller.getHasMembershipDDSchedule());
		System.assertEquals(false, controller.getHasCourseDDSchedule());
	}

	@isTest
	static void NavigateToDdPaymentPageAndSelectingPaymentDate_WithMembershipAndCoursePaymentSelected_IndicatesThatMembershipAndCourseSchedulesAreValid() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		booking = [SELECT Id, Name, Course__c, Status__c, Client__c, Course__r.Fee__c FROM Booking__c WHERE Id=:booking.Id];

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		booking.Membership_Choice__c = 'Standard 1-year single payment option - £48';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';
		controller.next();

		controller.next();

		Test.startTest();

		booking.Membership_Payment_Method__c = 'I wish to pay my membership by Direct Debit';
		booking.Course_Payment_Method__c = 'I wish to pay for the course fees in 4 monthly installments by Direct Debit';
		booking.Preferred_Payment_Date__c = '20th';

		Test.stopTest();

		System.assertEquals(true, controller.getMembershipPaymentOptionIsDd());
		System.assertEquals(true, controller.getCoursePaymentOptionisDd());
		System.assertEquals(true, controller.getHasMembershipDDSchedule());
		System.assertEquals(true, controller.getHasCourseDDSchedule());
	}

	@isTest
	static void SelectingMembership_ForOneYear_ReturnsCorrectMembershipAmount()
	{
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.startTest();

		booking.Membership_Choice__c = 'Standard 1-year single payment option - £48';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';

		Test.stopTest();

		System.assertEquals(48.00, controller.getMembershipFee());
	}

	@isTest
	static void SelectingMembership_ForEighteenMonths_ReturnsCorrectMembershipAmountAndNumberOfMonths()
	{
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		Test.startTest();

		booking.Membership_Choice__c = 'Value 18-month single payment option - £57';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';

		Test.stopTest();

		System.assertEquals(57.00, controller.getMembershipFee());
	}

	@isTest
	static void NavigateToDdPaymentPage_WithMembershipAndCoursePaymentSelected_ReturnsValidDdMembershipSchedule() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		booking = [SELECT Id, Name, Course__c, Status__c, Client__c, Course__r.Fee__c FROM Booking__c WHERE Id=:booking.Id];

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		booking.Membership_Choice__c = 'Standard 1-year single payment option - £48';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';
		controller.next();

		controller.next();

		Test.startTest();

		booking.Membership_Payment_Method__c = 'I wish to pay my membership by Direct Debit';
		booking.Course_Payment_Method__c = 'I wish to pay for the course fees in 4 monthly installments by Direct Debit';
		booking.Preferred_Payment_Date__c = '20th';
		DirectDebitModels.DdSchedule membershipSchedule = controller.getMembershipDdSchedule();

		Test.stopTest();

		System.assertEquals(4, membershipSchedule.Months);
		System.assertEquals(48.00, membershipSchedule.TotalAmount);
		System.assertEquals(20, membershipSchedule.PaymentDay);
		System.assertEquals(4, membershipSchedule.ScheduleItems.size());
		System.assertEquals(12.00, membershipSchedule.ScheduleItems.get(0).Amount);		
	}

	@isTest
	static void NavigateToDdPaymentPage_WithMembershipAndCoursePaymentSelected_ReturnsValidDdCourseSchedule() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		booking = [SELECT Id, Name, Course__c, Status__c, Client__c, Course__r.Fee__c FROM Booking__c WHERE Id=:booking.Id];

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		booking.Membership_Choice__c = 'Standard 1-year single payment option - £48';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';
		controller.next();

		controller.next();

		Test.startTest();

		booking.Membership_Payment_Method__c = 'I wish to pay my membership by Direct Debit';
		booking.Course_Payment_Method__c = 'I wish to pay for the course fees in 2 monthly installments by Direct Debit';
		booking.Preferred_Payment_Date__c = '3rd';
		DirectDebitModels.DdSchedule courseSchedule = controller.getCourseDdSchedule();

		Test.stopTest();

		System.assertEquals(2, courseSchedule.Months);
		System.assertEquals(courseFee, courseSchedule.TotalAmount);
		System.assertEquals(3, courseSchedule.PaymentDay);
		System.assertEquals(2, courseSchedule.ScheduleItems.size());
		System.assertEquals(90.00, courseSchedule.ScheduleItems.get(0).Amount);	
	}

	@isTest
	static void NavigateToDdPaymentPage_WithMembershipDdAndCourseCardPaymentSelected_ReturnsCorrectCardPaymentAmount() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		booking = [SELECT Id, Name, Course__c, Status__c, Client__c, Course__r.Fee__c FROM Booking__c WHERE Id=:booking.Id];

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		booking.Membership_Choice__c = 'Standard 1-year single payment option - £48';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';
		controller.next();

		controller.next();

		Test.startTest();

		booking.Membership_Payment_Method__c = 'I wish to pay my membership by Direct Debit';
		booking.Course_Payment_Method__c = 'I wish to pay for the course fees by credit or debit card';
		booking.Preferred_Payment_Date__c = '3rd';
		DirectDebitModels.DdSchedule courseSchedule = controller.getCourseDdSchedule();

		Test.stopTest();

		System.assertEquals(true, controller.getHasCardPayment());
		System.assertEquals('£' + String.valueOf(courseFee), controller.getCardPaymentTotal());
	}

	@isTest
	static void NavigateToDdPaymentPage_WithMembershipCardAndCourseDdPaymentSelected_ReturnsCorrectCardPaymentAmount() {
		
		setupTestData();

		TestBookingBuilder bookingBuilder = new TestBookingBuilder();
		booking = bookingBuilder.WithClient(client)
								.WithCourse(course)
								.WithStatus('Reserved')
								.InsertRecord(true)
								.Build();

		booking = [SELECT Id, Name, Course__c, Status__c, Client__c, Course__r.Fee__c FROM Booking__c WHERE Id=:booking.Id];

		Test.setCurrentPage(Page.BookCourse);
		ApexPages.StandardController stdController = new ApexPages.StandardController(booking);

		BookCourseController controller = new BookCourseController(stdController);
		BookCourseControllerModel model = controller.model;

		booking.Membership_Choice__c = 'Standard 1-year single payment option - £48';
		booking.Partner_Membership__c = 'Joint membership for you and your partner';
		controller.next();

		controller.next();

		Test.startTest();

		booking.Membership_Payment_Method__c = 'I wish to pay my membership by credit or debit card';
		booking.Course_Payment_Method__c = 'I wish to pay for the course fees in 2 monthly installments by Direct Debit';
		booking.Preferred_Payment_Date__c = '3rd';
		DirectDebitModels.DdSchedule courseSchedule = controller.getCourseDdSchedule();

		Test.stopTest();

		System.assertEquals(true, controller.getHasCardPayment());
		System.assertEquals('£48.00', controller.getCardPaymentTotal());
	}

	private static void setupTestData()
	{
		TestContactbuilder clientContactBuilder = new TestContactbuilder();
		client = clientContactBuilder.WithRecordType(clientRecordTypeName)
										.InsertRecord(true)
										.Build();

		TestContactbuilder practitionerContactBuilder = new TestContactbuilder();
		practitioner = practitionerContactBuilder.WithRecordType(practitionerRecordTypeName)
										.InsertRecord(true)
										.Build();

		TestCourseBuilder courseBuilder = new TestCourseBuilder();
		course = courseBuilder.WithPractitioner(practitioner)
										.WithFee(courseFee)
										.InsertRecord(true)
										.Build();
	}
}