global with sharing class EXPENSESHEET_ConvertEStoPI_TDTM extends npsp.TDTM_Runnable {
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        Set<Id> expenseSheetIds = new Set<Id>();
        Map<Id, Zumzum__Expense_Sheet__c> expenseSheetMapOld = new Map<Id, Zumzum__Expense_Sheet__c> ((List<Zumzum__Expense_Sheet__c>) triggerOld);
        List<Zumzum__Expense_Sheet__c> expenseSheetNew = (List<Zumzum__Expense_Sheet__c>) triggerNew;
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            for(Zumzum__Expense_Sheet__c expenseSheet : expenseSheetNew) {
                if(expenseSheetMapOld.get(expenseSheet.Id).Approval_Status__c != 'Approved' && expenseSheet.Approval_Status__c == 'Approved') {
                    expenseSheetIds.add(expenseSheet.Id);
                }
            }
        }
        if(!expenseSheetIds.isEmpty()) {
            ConvertEStoPIHandler.convertExpenseSheetToPurchaseInvoice(expenseSheetIds);
        }
        return dmlWrapper;
    }
}