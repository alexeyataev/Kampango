@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #104 - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class EXPENSESHEET_ConvertEStoPI_TDTM extends npsp.TDTM_Runnable {

    static final String APPROVAL_STATUS_APPROVED = 'Approved';
    static final String EXPENSE_SHEET_CONVERT_RESPONSE_STATUS_SUCCESS = 'Success';
    static final Boolean EXECUTE_IN_BATCH_PROCESSING = false;
    @SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #105 - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        Set<Id> expenseSheetIds = new Set<Id>();
        Map<Id, Zumzum__Expense_Sheet__c> expenseSheetMapOld = new Map<Id, Zumzum__Expense_Sheet__c> ((List<Zumzum__Expense_Sheet__c>) triggerOld);
        List<Zumzum__Expense_Sheet__c> expenseSheetNew = (List<Zumzum__Expense_Sheet__c>) triggerNew;

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {

            for (Zumzum__Expense_Sheet__c expenseSheet : expenseSheetNew) {
                Boolean isStatusApproved = expenseSheetMapOld.get(expenseSheet.Id).Approval_Status__c != APPROVAL_STATUS_APPROVED 
                && expenseSheet.Approval_Status__c == APPROVAL_STATUS_APPROVED;

                if (isStatusApproved) {
                    expenseSheetIds.add(expenseSheet.Id);
                }
            }

        }

        if (!expenseSheetIds.isEmpty()) {

            Zumzum.ExpenseSheetService.Response convertResponse = ConvertEStoPIHandler.convertExpenseSheetToPurchaseInvoice(expenseSheetIds);

            Boolean isConvertResponseValid = convertResponse.ResponseMessage == EXPENSE_SHEET_CONVERT_RESPONSE_STATUS_SUCCESS
            && !convertResponse.purchaseInvoices.isEmpty();

            if(isConvertResponseValid) {

                Set<Id> purchaseInvoiceIds = new Set<Id>();
                for (Zumzum__Purchase_Invoice__c purchaseInvoiceRecord : convertResponse.purchaseInvoices) {
                    purchaseInvoiceIds.add(purchaseInvoiceRecord.Id);
                }

                Zumzum.PurchaseInvoiceService.Response postPurchaseInvoiceResponse = ZumzumPurchaseInvoiceCreator.PostPurchaseInvoice(purchaseInvoiceIds, EXECUTE_IN_BATCH_PROCESSING);
            }
        }

        return dmlWrapper;
    }
}