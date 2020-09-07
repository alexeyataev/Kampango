@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #119 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class PRLineItem_PreventDeletion_TDTM extends npsp.TDTM_Runnable {
    @SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #120 - https://confluence.nct.org.uk:8443/x/EoSO

    private static final String PAYMENT_RUN_STATUS_DRAFT = 'Draft';
    private static final String PAYMENT_RUN_STATUS_FAILED = 'Failed To Create Transactions';

    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Payment_Run_Line_Item__c> oldPaymentRunLineItemList = (List<Payment_Run_Line_Item__c>) triggerOld;

        if ( triggerAction == npsp.TDTM_Runnable.Action.BeforeDelete ) {
            preventPaymentRunLineItemDeletion(oldPaymentRunLineItemList);
        }

        return dmlWrapper;
    }

    private void preventPaymentRunLineItemDeletion(List<Payment_Run_Line_Item__c> oldPaymentRunLineItemList) {
        Set<Id> paymentRunLineItemPreventDeleteIds = getPaymentRunLineItemPreventDeleteIds(oldPaymentRunLineItemList);

        for (Payment_Run_Line_Item__c paymentRunLineItem : oldPaymentRunLineItemList) {

            if (paymentRunLineItemPreventDeleteIds.contains(paymentRunLineItem.Id)) {
                paymentRunLineItem.addError(System.Label.Delete_Payment_Run_Line_Item_Error_Text);
            }

        }
    }

    private Set<Id> getPaymentRunLineItemPreventDeleteIds(List<Payment_Run_Line_Item__c> oldPaymentRunLineItemList) {
        Map<Id, Payment_Run_Line_Item__c> paymentRunLineItemMap = new Map<Id, Payment_Run_Line_Item__c>( oldPaymentRunLineItemList );

        return new Map<Id, Payment_Run_Line_Item__c> (
            [
                SELECT Id, Payment_Run__r.Status__c 
                FROM Payment_Run_Line_Item__c
                WHERE  Id IN :paymentRunLineItemMap.keySet()
                       AND
                       Payment_Run__r.Status__c IN (:PAYMENT_RUN_STATUS_DRAFT, :PAYMENT_RUN_STATUS_FAILED)
                WITH SECURITY_ENFORCED
            ]
        ).keySet();
    }

}
