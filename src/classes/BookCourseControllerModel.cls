public class BookCourseControllerModel {

	public final List<String> statuses = new List<String>{'Accept', 'Confirm', 'Payment','DDConfirm','GiftAid','Submit'};
	public String status { get; set; }
	public final Decimal oneYearMembershipFee = 48.00;
	public final Integer oneYearPayments = 4;
	public final Decimal eighteenMonthMembershipFee = 57.00;
	public final Integer eighteenMonthPayments = 6;
}