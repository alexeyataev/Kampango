public with sharing class DirectDebitModels {
	
	public Class DdSchedule
    {
    	public Integer Months;
    	public Decimal TotalAmount;
    	public Integer PaymentDay;
    	public List<scheduleItem> ScheduleItems;
    }

    public Class ScheduleItem
    {
    	public Decimal Amount;
    	public Date PaymentDate;
    }
}