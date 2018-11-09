@isTest
private class DirectDebitUtilitiesTest {
	
	@isTest
	static void GetFirstCollectionDate_ForDateWithSufficientLeadTime_ReturnsFirstPossibleCollectionDate() {
		
		Date requestDate = Date.newInstance(2017, 2, 28);
		Integer preferredPaymentDate = 20;

		Test.startTest();

		Date firstCollectionDate = DirectDebitUtilities.getFirstCollectionDate(preferredPaymentDate, requestDate);

		Test.stopTest();

		System.assertEquals(Date.newInstance(2017, 3, 20), firstCollectionDate);
	}
	
	@isTest
	static void GetFirstCollectionDate_ForDateWithInsufficientLeadTime_ReturnsDateForFollowingCollection() {
		
		Date requestDate = Date.newInstance(2017, 3, 10);
		Integer preferredPaymentDate = 20;

		Test.startTest();

		Date firstCollectionDate = DirectDebitUtilities.getFirstCollectionDate(preferredPaymentDate, requestDate);

		Test.stopTest();

		System.assertEquals(Date.newInstance(2017, 4, 20), firstCollectionDate);
	}
	
	@isTest
	static void CalculateDdSchedule_ForEasilyDivisibleTotalAmount_ReturnsCorrectSchedule()
	{
		Decimal fee = 240.00;
		Integer months = 4;
		Integer paymentDay = 3;
		Date firstCollectionDate = Date.newInstance(2017, 4, paymentDay);

		Test.startTest();

		DirectDebitModels.DdSchedule schedule = DirectDebitUtilities.calculateDdSchedule(fee, months, paymentDay, firstCollectionDate);

		Test.stopTest();

		System.assertEquals(fee, schedule.TotalAmount);
		System.assertEquals(months, schedule.Months);
		System.assertEquals(paymentDay, schedule.PaymentDay);
		System.assertEquals(months, schedule.ScheduleItems.size());
		System.assertEquals(60.00, schedule.ScheduleItems.get(0).Amount);
		System.assertEquals(60.00, schedule.ScheduleItems.get(1).Amount);
		System.assertEquals(60.00, schedule.ScheduleItems.get(2).Amount);
		System.assertEquals(60.00, schedule.ScheduleItems.get(3).Amount);
		System.assertEquals(Date.newInstance(2017, 4, paymentDay), schedule.ScheduleItems.get(0).PaymentDate);
		System.assertEquals(Date.newInstance(2017, 5, paymentDay), schedule.ScheduleItems.get(1).PaymentDate);
		System.assertEquals(Date.newInstance(2017, 6, paymentDay), schedule.ScheduleItems.get(2).PaymentDate);
		System.assertEquals(Date.newInstance(2017, 7, paymentDay), schedule.ScheduleItems.get(3).PaymentDate);
	}

	@isTest
	static void FormatDdSchedule_ForValidSchedule_ReturnsFormattedSchedule()
	{
		Decimal fee = 240.00;
		Integer months = 4;
		Integer paymentDay = 3;

		Test.startTest();

		List<string> formattedSchedule = DirectDebitUtilities.getFormattedDdSchedule(fee, months, paymentDay);

		Test.stopTest();

		System.assertEquals(4, formattedSchedule.size());
		System.assertEquals('£60.00', formattedSchedule.get(0).left(6));
	}
}