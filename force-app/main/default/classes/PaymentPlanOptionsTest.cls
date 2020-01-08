@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public class PaymentPlanOptionsTest {
    @testSetup
    static void createTestData() {
        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Min_Days_Fully_Paid_Before_Course_Start__c = 28;
        cardPaymentPlanSettings.Minimum_First_Amount__c = 30;
        cardPaymentPlanSettings.Minimum_Recurring_Amount__c = 10;
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        insert cardPaymentPlanSettings;
    }
    @isTest
    static void CourseFeeTooSmall_CourseFeeLessThanMinimum_NoOptionsGenerated() {
        Integer courseFee = 20;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        Test.stopTest();
        System.assertEquals(options.size(), 0);
    }
    @isTest
    static void NextMonthFirstRecurringPayment_InitialPaymentEarlyDayOfTheMonth_FirstPaymentNextMonth() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        Test.stopTest();
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, String.format(Label.Payment_Plan_Equal_Amounts_Option_Template, new List<Object> {2, 100.00}));
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[1].displayLabel, String.format(Label.Payment_Plan_Different_Multiple_Amounts_Option_Template, new List<Object> {66.68, 2, 66.66}));
        System.assertEquals(options[2].endDate, Date.newInstance(2020, 3, 31));
        System.assertEquals(options[2].displayLabel, String.format(Label.Payment_Plan_Equal_Amounts_Option_Template, new List<Object> {4, 50.00}));
    }
    @isTest
    static void AfterNextMonthFirstRecurringPayment_InitialPaymentLaterDayOfTheMonth_FirstPaymentAfterNextMonth() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 25));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        Test.stopTest();
        System.assertEquals(options.size(), 3);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 2, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[0].displayLabel, String.format(Label.Payment_Plan_Equal_Amounts_Option_Template, new List<Object> {2, 100.00}));
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 3, 31));
        System.assertEquals(options[1].displayLabel, String.format(Label.Payment_Plan_Different_Multiple_Amounts_Option_Template, new List<Object> {66.68, 2, 66.66}));
        System.assertEquals(options[2].endDate, Date.newInstance(2020, 4, 30));
        System.assertEquals(options[2].displayLabel, String.format(Label.Payment_Plan_Equal_Amounts_Option_Template, new List<Object> {4, 50.00}));
    }
    @isTest
    static void OneRecurringPaymentDependsOnTime_WithTimeForOnlyOnePaymentBeforeDeadline_OneOptionGenerated() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 2, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        Test.stopTest();
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, String.format(Label.Payment_Plan_Equal_Amounts_Option_Template, new List<Object> {2, 100.00}));
    }
    @isTest
    static void TwoRecurringPaymentsDependsOnTime_WithTimeForTwoPaymentsBeforeDeadline_TwoOptionGenerated() {
        Integer courseFee = 200;
        Date courseStartDate = Date.newInstance(2020, 3, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        Test.stopTest();
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, String.format(Label.Payment_Plan_Equal_Amounts_Option_Template, new List<Object> {2, 100.00}));
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[1].displayLabel, String.format(Label.Payment_Plan_Different_Multiple_Amounts_Option_Template, new List<Object> {66.68, 2, 66.66}));
    }
    @isTest
    static void OneRecurringPaymentDependsOnFe_WithFeeForOnlyOnePaymentBeforeDeadline_OneOptionGenerated() {
        Integer courseFee = 45;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        Test.stopTest();
        System.assertEquals(options.size(), 1);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, String.format(Label.Payment_Plan_Different_Amounts_Option_Template, new List<Object> {30.00, 1, 15.00}));
    }
    @isTest
    static void TwoRecurringPaymentsDependsOnFe_WithFeeForTwoPaymentsBeforeDeadline_TwoOptionsGenerated() {
        Integer courseFee = 55;
        Date courseStartDate = Date.newInstance(2020, 6, 1);
        PaymentPlanGenerator.clock = new PaymentPlanMockClock(Date.newInstance(2019, 12, 5));
        Test.startTest();
        List<PaymentPlanOption> options = PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
        Test.stopTest();
        System.assertEquals(options.size(), 2);
        System.assertEquals(options[0].startDate, Date.newInstance(2020, 1, 1));
        System.assertEquals(options[0].endDate, Date.newInstance(2020, 1, 31));
        System.assertEquals(options[0].displayLabel, String.format(Label.Payment_Plan_Different_Amounts_Option_Template, new List<Object> {30.00, 1, 25.00}));
        System.assertEquals(options[1].endDate, Date.newInstance(2020, 2, 29));
        System.assertEquals(options[1].displayLabel, String.format(Label.Payment_Plan_Different_Multiple_Amounts_Option_Template, new List<Object> {30.00, 2, 12.50}));
    }
}