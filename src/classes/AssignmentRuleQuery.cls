public without sharing class AssignmentRuleQuery {
    public static AssignmentRule getAssignmentRule(){
		AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        return AR;
    }

}