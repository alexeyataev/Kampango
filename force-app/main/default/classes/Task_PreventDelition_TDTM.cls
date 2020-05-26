//@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class Task_PreventDelition_TDTM extends npsp.TDTM_Runnable {
    private static Boolean hasCustomPermission = FeatureManagement.checkPermission('Can_Delete_Activities');
    //@SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Task> oldTaskList = (List<Task>) triggerOld;

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeDelete && !hasCustomPermission) {
            preventTaskDeletion(oldTaskList);
        }
        return dmlWrapper;
    }

    private void preventTaskDeletion(List<Task> oldTaskList) {
        for (Task task : oldTaskList) {
            task.addError(System.label.Delete_Activity_Error_Text);
        }
    }
}