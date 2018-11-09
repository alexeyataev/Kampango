public with sharing class DirectDebitUtilities {
	
	private static final Integer mandateLeadTimeInCalendarDays = 19;

	private DirectDebitUtilities() {}

	public static List<String> getFormattedDdSchedule(Decimal fee, Integer months, Integer paymentDay)
	{
		DirectDebitModels.DdSchedule schedule =  calculateDDSchedule(fee, months, paymentDay);

		return formatDdSchedule(schedule);
	}

	public static DirectDebitModels.DdSchedule calculateDdSchedule(Decimal fee, Integer months, Integer paymentDay)
	{
		return calculateDDSchedule(fee, months, paymentDay, getFirstCollectionDate(paymentDay));
	}

    public static DirectDebitModels.DdSchedule calculateDdSchedule(Decimal fee, 
    																Integer months, 
    																Integer paymentDay,
    																Date firstCollectionDate)
    {
    	DirectDebitModels.DdSchedule schedule =  new DirectDebitModels.DdSchedule();
    	schedule.ScheduleItems = new List<DirectDebitModels.ScheduleItem>();

        schedule.TotalAmount = fee;
        schedule.Months = months;
        schedule.PaymentDay = paymentDay;

        Decimal monthlyFee = fee / months;
        monthlyFee = monthlyFee.setScale(2);        

        Date nextPaymentDate = firstCollectionDate;

        for(Integer i=0; i<months; i++)
        {
        	DirectDebitModels.ScheduleItem item = new DirectDebitModels.ScheduleItem();
        	item.Amount = monthlyFee;
        	item.PaymentDate = nextPaymentDate;
        	schedule.ScheduleItems.add(item);

            nextPaymentDate = nextPaymentDate.addMonths(1);
        }

        return schedule;
    }

    public static Date getFirstCollectionDate(Integer preferredPaymentDate)
    {
    	return getFirstCollectionDate(preferredPaymentDate, system.today());
    }

    public static Date getFirstCollectionDate(Integer preferredPaymentDate, Date forSpecifiedDate)
    {
    	Date earliestPaymentDate = Date.newInstance(forSpecifiedDate.year(), forSpecifiedDate.month(), preferredPaymentDate);

    	if(earliestPaymentDate.addMonths(-mandateLeadTimeInCalendarDays) < forSpecifiedDate)
    	{
    		earliestPaymentDate = Date.newInstance(forSpecifiedDate.year(), forSpecifiedDate.month() + 1, preferredPaymentDate);
    	}

    	return earliestPaymentDate;
    }

    private static List<String> formatDdSchedule(DirectDebitModels.DdSchedule schedule)
    {
    	List<String> scheduleLines = new List<String>();

    	if(!schedule.ScheduleItems.isEmpty())
    	{
	    	for(DirectDebitModels.ScheduleItem item : schedule.ScheduleItems)
	        {
	            scheduleLines.add('£' + 
	            					item.Amount + 
	            					' on or after ' + 
	            					Datetime.newInstance(item.PaymentDate.year(), item.PaymentDate.month(), item.PaymentDate.day()).format('d MMM yyyy'));
	        }
	    }

   		return scheduleLines;
    }
}