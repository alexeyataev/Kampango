@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public class PaymentPlanOptionsTest {
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
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        System.assertEquals(options.size(), 0);
        Test.stopTest();
    }
    @isTest
    static void NextMonthFirstRecurringPayment_InitialPaymentEarlyDayOfTheMonth_FirstPaymentNextMonth() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[1].displayLabel, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].endDate, Date.newInstance(2020, 3, 31));
        System.assertEquals(options[2].displayLabel, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void AfterNextMonthFirstRecurringPayment_InitialPaymentLaterDayOfTheMonth_FirstPaymentAfterNextMonth() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 25));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 2, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[0].displayLabel, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 3, 31));
        System.assertEquals(options[1].displayLabel, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        System.assertEquals(options[2].endDate, Date.newInstance(2020, 4, 30));
        System.assertEquals(options[2].displayLabel, '4 monthly payment of £ 50.00');
        Test.stopTest();
    }
    @isTest
    static void DatesOneRecurringPayment_TwoMonthBefore_OneOptionGenerated() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 2, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, '2 monthly payment of £ 100.00');
        Test.stopTest();
    }
    @isTest
    static void DatesTwoRecurringPayment_TwoMonthBefore_TwoOptionGenerated() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 3, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, '2 monthly payment of £ 100.00');
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[1].displayLabel, '1 payment of £ 66.68 and 2 monthly payment of £ 66.66');
        Test.stopTest();
    }
    @isTest
    static void FeeOneRecurringPayment_FeeSmall_OneOptionGenerated() {
        Integer courseFee = 45;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, '1 payment of £ 30.00 and 1 monthly payment of £ 15.00');
        Test.stopTest();
    }
    @isTest
    static void FeeTwoRecurringPayment_FeeMedium_TwoOptionsGenerated() {
        Integer courseFee = 55;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, '1 payment of £ 30.00 and 1 monthly payment of £ 25.00');
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[1].displayLabel, '1 payment of £ 30.00 and 2 monthly payment of £ 12.50');
        Test.stopTest();
    }
}