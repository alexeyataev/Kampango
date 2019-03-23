@isTest
private class DirectDebitModelsTest {
    @isTest static void directDebit(){
        list<DirectDebitModels.ScheduleItem> scheduleItems = new list<DirectDebitModels.ScheduleItem>();
        DirectDebitModels.ScheduleItem scheduleItem = new DirectDebitModels.ScheduleItem();
        scheduleItem.amount = 10000;
        scheduleItem.paymentDate = system.Date.today();
        
        DirectDebitModels.DdSchedule  ddSchedule = new DirectDebitModels.DdSchedule();
        ddSchedule.months = 12;
        ddSchedule.paymentDay = 45;
        ddSchedule.scheduleItems = scheduleItems;
        ddSchedule.totalAmount = 45000;        
       system.assertEquals(10000,scheduleItem.amount);
    }
}