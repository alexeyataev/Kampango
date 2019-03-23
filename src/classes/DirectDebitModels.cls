public with sharing class DirectDebitModels {
	
	public Class DdSchedule
    {
    	public Integer months;
    	public Decimal totalAmount;
    	public Integer paymentDay;
    	public List<scheduleItem> scheduleItems;
    }

    public Class ScheduleItem
    {
    	public Decimal amount;
    	public Date paymentDate;
    }
}