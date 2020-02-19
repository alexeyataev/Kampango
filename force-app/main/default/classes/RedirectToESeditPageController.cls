public with sharing class RedirectToESeditPageController {
    @AuraEnabled(cacheable=false)
    public static Boolean isExpenseSheetLocked(String recordId) {
        return Approval.isLocked(recordId);
    }
}
