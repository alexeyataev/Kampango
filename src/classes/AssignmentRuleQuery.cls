public without sharing class AssignmentRuleQuery {
    public static AssignmentRule getAssignmentRule(){
		AssignmentRule ar = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        return ar;
    }

}