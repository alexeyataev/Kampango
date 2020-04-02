@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public with sharing class PaymentPlanOptionsControllerTest {

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
    static void ThreeRecurringPaymentsDependsOnFee_WithFeeForThreePaymentsBeforeDeadline_ThreeOptionsGenerated() {
        Test.startTest();
            Decimal courseFee = 250;
            Date courseStartDate = System.today().addMonths(5);
            List<PaymentPlanOption> paymentPlanOptionList = PaymentPlanOptionsController.getOptions(courseFee, courseStartDate);
            System.assertEquals(3, paymentPlanOptionList.size(), 'expecting three payment options');
        Test.stopTest();
    }

    @isTest
    static void OneRecurringPaymentDependsOnFee_WithFeeForOnePaymentBeforeDeadline_OneOptionGenerated() {
        Test.startTest();
            Decimal courseFee = 100;
            Date courseStartDate = System.today().addMonths(3);
            List<PaymentPlanOption> paymentPlanOptionList = PaymentPlanOptionsController.getOptions(courseFee, courseStartDate);
            System.assert(!paymentPlanOptionList.isEmpty(), 'list should be not is empty');
        Test.stopTest();
    }

}