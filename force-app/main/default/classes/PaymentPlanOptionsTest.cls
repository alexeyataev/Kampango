@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public class PaymentPlanOptionsTest {
    private static Date THIS_MONTH_START_DATE = Date.today().toStartOfMonth();
    @testSetup
    static void createTestData() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Maximum_Days_Before_Paid__c = 28;
        cardPaymentPlanSettings.Minimum_First_Amount__c = 30;
        cardPaymentPlanSettings.Minimum_Recurring_Amount__c = 10;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
    }
    @isTest
    static void CourseFeeLessThanMinimum_CourseFeeTooSmall_NoOptionsGenerated() {
        Integer courseFee = 20;
        Date startDate = THIS_MONTH_START_DATE.addMonths(6);
        PaymentPlanGenerator.initialPaymentDate = THIS_MONTH_START_DATE.addDays(5);
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, startDate);
        System.assertEquals(options.size(), 0);
        Test.stopTest();
    }
    @isTest
    static void NextMonthFirstRecurringPayment_InitialPaymentEarlyDayOfTheMonth_FirstPaymentNextMonth() {
        Integer courseFee = 200;
        Date startDate = THIS_MONTH_START_DATE.addMonths(6);
        PaymentPlanGenerator.initialPaymentDate = THIS_MONTH_START_DATE.addDays(5);
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, startDate);
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, THIS_MONTH_START_DATE.addMonths(1));
        System.assertEquals(options[0].endDate, THIS_MONTH_START_DATE.addMonths(1) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(1).year(), THIS_MONTH_START_DATE.addMonths(1).month()) - 1);
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].endDate, THIS_MONTH_START_DATE.addMonths(2) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(2).year(), THIS_MONTH_START_DATE.addMonths(2).month()) - 1);
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].endDate, THIS_MONTH_START_DATE.addMonths(3) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(3).year(), THIS_MONTH_START_DATE.addMonths(3).month()) - 1);
        System.assertEquals(options[2].label, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void AfterNextMonthFirstRecurringPayment_InitialPaymentLaterDayOfTheMonth_FirstPaymentAfterNextMonth() {
        Integer courseFee = 200;
        Date startDate = THIS_MONTH_START_DATE.addMonths(6);
        PaymentPlanGenerator.initialPaymentDate = THIS_MONTH_START_DATE.addDays(25);
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, startDate);
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, THIS_MONTH_START_DATE.addDays(25).addMonths(2).toStartOfMonth());
        System.assertEquals(options[0].endDate, THIS_MONTH_START_DATE.addMonths(2) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(2).year(), THIS_MONTH_START_DATE.addMonths(2).month()) - 1);
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].endDate, THIS_MONTH_START_DATE.addMonths(3) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(3).year(), THIS_MONTH_START_DATE.addMonths(3).month()) - 1);
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].endDate, THIS_MONTH_START_DATE.addMonths(4) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(4).year(), THIS_MONTH_START_DATE.addMonths(4).month()) - 1);
        System.assertEquals(options[2].label, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void DatesOneRecurringPayment_TwoMonthBefore_OneOptionGenerated() {
        Integer courseFee = 200;
        Date startDate = THIS_MONTH_START_DATE.addMonths(2);
        PaymentPlanGenerator.initialPaymentDate = THIS_MONTH_START_DATE.addDays(5);
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, startDate);
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, THIS_MONTH_START_DATE.addDays(5).addMonths(1).toStartOfMonth());
        System.assertEquals(options[0].endDate, THIS_MONTH_START_DATE.addMonths(1) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(1).year(), THIS_MONTH_START_DATE.addMonths(1).month()) - 1);
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        Test.stopTest();
    }
    @isTest
    static void DatesTwoRecurringPayment_TwoMonthBefore_TwoOptionGenerated() {
        Integer courseFee = 200;
        Date startDate = THIS_MONTH_START_DATE.addMonths(3);
        PaymentPlanGenerator.initialPaymentDate = THIS_MONTH_START_DATE.addDays(5);
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, startDate);
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, THIS_MONTH_START_DATE.addDays(5).addMonths(1).toStartOfMonth());
        System.assertEquals(options[0].endDate, THIS_MONTH_START_DATE.addMonths(1) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(1).year(), THIS_MONTH_START_DATE.addMonths(1).month()) - 1);
        System.assertEquals(options[0].label, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].endDate, THIS_MONTH_START_DATE.addMonths(2) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(2).year(), THIS_MONTH_START_DATE.addMonths(2).month()) - 1);
        System.assertEquals(options[1].label, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        Test.stopTest();
    }
    @isTest
    static void FeeOneRecurringPayment_FeeSmall_OneOptionGenerated() {
        Integer courseFee = 45;
        Date startDate = THIS_MONTH_START_DATE.addMonths(6);
        PaymentPlanGenerator.initialPaymentDate = THIS_MONTH_START_DATE.addDays(5);
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, startDate);
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, THIS_MONTH_START_DATE.addDays(5).addMonths(1).toStartOfMonth());
        System.assertEquals(options[0].endDate, THIS_MONTH_START_DATE.addMonths(1) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(1).year(), THIS_MONTH_START_DATE.addMonths(1).month()) - 1);
        System.assertEquals(options[0].label, '1 payment of £ 30.00 and 1 monthly payment of £ 15.00');
        Test.stopTest();
    }
    @isTest
    static void FeeTwoRecurringPayment_FeeMedium_TwoOptionsGenerated() {
        Integer courseFee = 55;
        Date startDate = THIS_MONTH_START_DATE.addMonths(6);
        PaymentPlanGenerator.initialPaymentDate = THIS_MONTH_START_DATE.addDays(5);
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, startDate);
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, THIS_MONTH_START_DATE.addDays(5).addMonths(1).toStartOfMonth());
        System.assertEquals(options[0].endDate, THIS_MONTH_START_DATE.addMonths(1) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(1).year(), THIS_MONTH_START_DATE.addMonths(1).month()) - 1);
        System.assertEquals(options[0].label, '1 payment of £ 30.00 and 1 monthly payment of £ 25.00');
        System.assertEquals(options[1].endDate, THIS_MONTH_START_DATE.addMonths(2) + Date.daysInMonth(THIS_MONTH_START_DATE.addMonths(2).year(), THIS_MONTH_START_DATE.addMonths(2).month()) - 1);
        System.assertEquals(options[1].label, '1 payment of £ 30.00 and 2 monthly payment of £ 12.50');
        Test.stopTest();
    }
}