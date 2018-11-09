public with sharing class DisplayDdScheduleController {

    public Object ddScheduleObject { get; set; }

    public DisplayDdScheduleController() {}

    public List<String> getFormattedScheduleItems()
    {
        DirectDebitModels.DdSchedule schedule = (DirectDebitModels.DdSchedule)ddScheduleObject;
        return DirectDebitUtilities.getFormattedDdSchedule(schedule.TotalAmount, schedule.Months, schedule.PaymentDay);
    }
}