@isTest
public with sharing class PaymentPlanOptionsControllerTest {
    @isTest
    static void paymentPlanOptionsTest() {

        Card_Payment_Plan_Settings__c cardPaymentPlanSettings = new Card_Payment_Plan_Settings__c();
        cardPaymentPlanSettings.Min_Days_Before_First_Recurring_Payment__c = 14;
        cardPaymentPlanSettings.Min_Days_Fully_Paid_Before_Course_Start__c = 28;
        cardPaymentPlanSettings.Minimum_First_Amount__c = 10;
        cardPaymentPlanSettings.Minimum_Recurring_Amount__c = 30;
        insert cardPaymentPlanSettings;

        Test.startTest();
            Decimal courseFee = 250;
            Date courseStartDate = System.today().addMonths(5);
            List<PaymentPlanOption> paymentPlanOptionList = PaymentPlanOptionsController.getOptions(courseFee, courseStartDate);
            System.assertEquals(3, paymentPlanOptionList.size(), 'expecting three payment options');

            courseFee = 100;
            courseStartDate = System.today().addMonths(3);
            paymentPlanOptionList = PaymentPlanOptionsController.getOptions(courseFee, courseStartDate);
            System.assertEquals(1, paymentPlanOptionList.size(), 'expecting one payment option');
        Test.stopTest();

    }

}