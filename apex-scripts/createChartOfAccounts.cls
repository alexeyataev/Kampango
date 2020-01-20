/* rename Nominal Categories */
Map<String, String> ncNamesMapping = new Map<String, String> {
    'Sales' => 'Income', 
    'Purchases' => 'Expenditure', 
    'Capital and Reserves' => 'Funds'
};
List<Zumzum__Nominal_Categories__c> categoriesToRename = [
    SELECT Id, Name 
    FROM Zumzum__Nominal_Categories__c
    WHERE Name IN :ncNamesMapping.keySet()
];
for (Zumzum__Nominal_Categories__c cat : categoriesToRename) {
    cat.Name = ncNamesMapping.get(cat.Name);
}
update categoriesToRename;


/* Delete nominal accounts */
List<Zumzum__Nominal_Account__c> nominalAccounts = [
    SELECT Id FROM Zumzum__Nominal_Account__c
];
delete nominalAccounts;


/* Insert nominal accounts */
// Nominal Categories
List<Zumzum__Nominal_Categories__c> categories = new List<Zumzum__Nominal_Categories__c>();
Zumzum__Nominal_Categories__c nc1 = new Zumzum__Nominal_Categories__c(
    Name = 'Expenditure',
    Zumzum__Type__c = 'Purchases'
);
Zumzum__Nominal_Categories__c nc2 = new Zumzum__Nominal_Categories__c(
    Name = 'Direct Expenses',
    Zumzum__Type__c = 'Direct Expenses'
);
Zumzum__Nominal_Categories__c nc3 = new Zumzum__Nominal_Categories__c(
    Name = 'Overheads',
    Zumzum__Type__c = 'Overheads'
);
Zumzum__Nominal_Categories__c nc4 = new Zumzum__Nominal_Categories__c(
    Name = 'Fixed Assets',
    Zumzum__Type__c = 'Fixed Assets'
);
Zumzum__Nominal_Categories__c nc5 = new Zumzum__Nominal_Categories__c(
    Name = 'Current Assets',
    Zumzum__Type__c = 'Current Assets'
);
Zumzum__Nominal_Categories__c nc6 = new Zumzum__Nominal_Categories__c(
    Name = 'Current Liabilities',
    Zumzum__Type__c = 'Current Liabilities'
);
Zumzum__Nominal_Categories__c nc7 = new Zumzum__Nominal_Categories__c(
    Name = 'Long Term Liabilities',
    Zumzum__Type__c = 'Long Term Liabilities'
);
Zumzum__Nominal_Categories__c nc8 = new Zumzum__Nominal_Categories__c(
    Name = 'Funds',
    Zumzum__Type__c = 'Capital & Reserves'
);
Zumzum__Nominal_Categories__c nc9 = new Zumzum__Nominal_Categories__c(
    Name = 'Income',
    Zumzum__Type__c = 'Sales'
);
categories.add(nc1);
categories.add(nc2);
categories.add(nc3);
categories.add(nc4);
categories.add(nc5);
categories.add(nc6);
categories.add(nc7);
categories.add(nc8);
categories.add(nc9);
insert categories;

// Sub categories


// Nominal accounts
