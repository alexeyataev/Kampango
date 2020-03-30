List<Zumzum__Revenue_Recognition_Rule_Setting__c> existingRuleSettings = [SELECT Id FROM Zumzum__Revenue_Recognition_Rule_Setting__c];

if(existingRuleSettings.size() == 0)
{
    Zumzum__Nominal_Account__c deferredIncomeNominal = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Name = 'Deferred Income'];
    Zumzum__Nominal_Account__c courseIncomeNominal = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Name = 'Course Income'];
    Product2 courseProduct = [SELECT Id FROM Product2 WHERE ProductCode = 'CoursePlace'];

    Zumzum__Revenue_Recognition_Rule_Setting__c newRuleSetting = new Zumzum__Revenue_Recognition_Rule_Setting__c(
        Zumzum__Rev_Rec_Start_Date_Source_Object__c = 'Sales_Invoice_Line_Item__c',
        Zumzum__Rev_Rec_Start_Date_Source_Field__c = 'Revenue_Recognition_Start_Date__c',
        Zumzum__Rev_Rec_End_Date_Source_Object__c = 'Sales_Invoice_Line_Item__c',
        Zumzum__Rev_Rec_End_Date_Source_Field__c = 'Revenue_Recognition_End_Date__c',
        Zumzum__Active__c = true,
        Zumzum__Recognised_Revenue_Nominal_Account__c = courseIncomeNominal.Id,
        Zumzum__Deferred_Revenue_Nominal_Account__c = deferredIncomeNominal.Id
    );

    insert newRuleSetting;

    Zumzum__Revenue_Recognition_Rule__c newRule = new Zumzum__Revenue_Recognition_Rule__c (
        Name = 'Course Income On Course Start Date',
        Zumzum__Revenue_Recognition_Type__c = 'Equal Split',
        Zumzum__Revenue_Installment_Period__c = 'Monthly',
        Zumzum__Number_of_Revenue_Periods__c = 1,
        Zumzum__Revenue_Recognition_Rule_Setting__c = newRuleSetting.Id,
        Zumzum__Start_Offset__c = 0,
	Zumzum__Active__c = true
    );

    insert newRule;

    Zumzum__Product_Revenue_Recognition_Rule__c newProductRule = new Zumzum__Product_Revenue_Recognition_Rule__c (
        Zumzum__Product_Revenue_Recognition_Rule_Name__c = 'Course Start Date Recognition Rule',
        Zumzum__Product__c = courseProduct.Id,
        Zumzum__Revenue_Recognition_Rule__c = newRule.Id
    );

    insert newProductRule;
}
