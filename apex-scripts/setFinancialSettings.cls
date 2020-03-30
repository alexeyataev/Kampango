Integer practitionerRegCapFees = 300;
Integer pracRegFeeRate = 3;

List<Financial_Settings__c> financialSettings = [SELECT Id FROM Financial_Settings__c LIMIT 1];

Zumzum__Nominal_Account__c pcNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 1502];
Zumzum__Nominal_Account__c piNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 5130];

if(financialSettings.size() == 0) {
    Financial_Settings__c newFinancialSettings = new Financial_Settings__c(
        Practitioner_Registration_Capped_Fees__c = practitionerRegCapFees,
        Practitioner_Registration_Fees_Rate__c = pracRegFeeRate,
        PC_Nominal_Account_Id__c = pcNominalAccount.Id,
        PI_Nominal_Account_Id__c = piNominalAccount.Id
    );
    insert newFinancialSettings;
} else {
    financialSettings[0].Practitioner_Registration_Capped_Fees__c = practitionerRegCapFees;
    financialSettings[0].Practitioner_Registration_Fees_Rate__c = pracRegFeeRate;
    financialSettings[0].PC_Nominal_Account_Id__c = pcNominalAccount.Id;
    financialSettings[0].PI_Nominal_Account_Id__c = piNominalAccount.Id;
    update financialSettings;
}
