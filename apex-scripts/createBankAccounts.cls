Zumzum__Company__c nctCompany = [SELECT Id FROM Zumzum__Company__c WHERE Name='NCT'];
Zumzum__Currency__c gbpCurrency = [SELECT Id FROM Zumzum__Currency__c WHERE Name='GBP'];

Zumzum__Nominal_Account__c currentAccountNominal = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 9400];
Zumzum__Nominal_Account__c worldPayAccountNominal = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 9401];
Zumzum__Nominal_Account__c ptxAccountNominal = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 9402];

Zumzum__Bank_Account__c existingCurrentAccount = [SELECT Id FROM Zumzum__Bank_Account__c WHERE Name='Bank Current Account'];
existingCurrentAccount.Zumzum__Status__c = 'Active';
existingCurrentAccount.Zumzum__Nominal_Account__c = currentAccountNominal.Id;
existingCurrentAccount.Zumzum__Bank_Name__c = 'Lloyds';
update existingCurrentAccount;

List<Zumzum__Bank_Account__c> accountsToAdd = new List<Zumzum__Bank_Account__c>{
    new Zumzum__Bank_Account__c (
        Name = 'Card Receipts in Transit',
        Zumzum__Account_Number__c = 'NCTECOMMERCE',
        Zumzum__Type__c = 'PayPal',
        Zumzum__Status__c = 'Active',
        Zumzum__Nominal_Account__c = worldPayAccountNominal.Id,
        Zumzum__Company__c = nctCompany.Id,
        Zumzum__Currency__c = gbpCurrency.Id,
        Zumzum__Bank_Name__c = 'WorldPay'
    ),
    new Zumzum__Bank_Account__c (
        Name = 'BACS Payments in Transit',
        Zumzum__Account_Number__c = 'N/A',
        Zumzum__Type__c = 'PayPal',
        Zumzum__Status__c = 'Active',
        Zumzum__Nominal_Account__c = ptxAccountNominal.Id,
        Zumzum__Company__c = nctCompany.Id,
        Zumzum__Currency__c = gbpCurrency.Id,
        Zumzum__Bank_Name__c = 'PTX'
    )
};

insert accountsToAdd;


