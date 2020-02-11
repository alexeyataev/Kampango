Map<String, String> nominalCategoriesRenaming = new Map<String, String> {
    'Sales' => 'Income', 
    'Purchases' => 'Expenditure', 
    'Capital & Reserves' => 'Funds'
};
List<Zumzum__Nominal_Account__c> nominalAccountsToDelete = [
    SELECT Id FROM Zumzum__Nominal_Account__c
];
List<Zumzum__Sub_Category__c> subCategoriesToDelete = [
    SELECT Id FROM Zumzum__Sub_Category__c
];
Zumzum__Tax_Rate__c taxRate = [
    SELECT Id
    FROM Zumzum__Tax_Rate__c
    WHERE Name = 'No VAT'
    LIMIT 1
];


Zumzum__Sub_Category__c newSC(String name, String nominalCategoryId, Integer rangeFrom, Integer rangeTo, Boolean isFloating) {
    return new Zumzum__Sub_Category__c(
        Name = name,
        Zumzum__Nominal_Categories__c = nominalCategoryId,
        Zumzum__Range_From__c = rangeFrom,
        Zumzum__Range_To__c = rangeTo,
        Zumzum__Is_Floating__c = isFloating
    );
}
Zumzum__Nominal_Account__c newNA(String name, Integer accountCode, Boolean po, Boolean so, String subcategoryId) {
    return new Zumzum__Nominal_Account__c(
        Name = name,
        Zumzum__Account_Code__c = accountCode,
        Zumzum__P_O__c = po,
        Zumzum__S_O__c = so,
        Zumzum__Sub_Category__c = subcategoryId,
        Zumzum__Tax_Rate__c = taxRate.Id,
        Zumzum__Total_Credit_Balance__c = 0,
        Zumzum__Total_Debit_Balance__c = 0
    );
}
Zumzum__Nominal_Account__c newNA(String name, Integer accountCode, Integer creditBalance, Integer debitBalance, Boolean po, 
                                            Boolean so, String subcategoryId, Integer totalCreditBalance, Integer totalDebitBalance) {
    return new Zumzum__Nominal_Account__c(
        Name = name,
        Zumzum__Account_Code__c = accountCode,
        Zumzum__Credit_Balance__c = creditBalance,
        Zumzum__Debit_Balance__c = debitBalance,
        Zumzum__P_O__c = po,
        Zumzum__S_O__c = so,
        Zumzum__Sub_Category__c = subcategoryId,
        Zumzum__Tax_Rate__c = taxRate.Id,
        Zumzum__Total_Credit_Balance__c = totalCreditBalance,
        Zumzum__Total_Debit_Balance__c = totalDebitBalance
    );
}


void renameNominalCategories() {
    List<Zumzum__Nominal_Categories__c> categoriesToRename = [
        SELECT Id, Name 
        FROM Zumzum__Nominal_Categories__c
        WHERE Name IN :nominalCategoriesRenaming.keySet()
    ];
    for (Zumzum__Nominal_Categories__c cat : categoriesToRename) {
        cat.Name = nominalCategoriesRenaming.get(cat.Name);
    }
    update categoriesToRename;
}


void deleteExistingNominalAccountsAndSubCategories() {
    delete nominalAccountsToDelete;
    delete subCategoriesToDelete;
}


void insertSubCategories() {
    Map<String, Id> catIdByName = new Map<String, Id>();
    for (Zumzum__Nominal_Categories__c c : [SELECT Id, Name FROM Zumzum__Nominal_Categories__c]) {
        catIdByName.put(c.Name,c.Id);
    }
    List<Zumzum__Sub_Category__c> scs = new List<Zumzum__Sub_Category__c> {
        newSC('Donations - Other', catIdByName.get('Income'), 1001, 1001, false),
        newSC('Donations - Membership', catIdByName.get('Income'), 1002, 1004, false),
        newSC('Other Trading Activity - Community Fundraising', catIdByName.get('Income'), 1101, 1102, false),
        newSC('Donations - Grants Receivable', catIdByName.get('Income'), 1200, 1200, false),
        newSC('Charitable Activities - NCT Courses', catIdByName.get('Income'), 1400, 1400, false),
        newSC('Charitable Activities - NCT College', catIdByName.get('Income'), 1502, 1502, false),
        newSC('Parentforce costs', catIdByName.get('Expenditure'), 5000, 5999, false),
        newSC('Ireccoverable VAT', catIdByName.get('Expenditure'), 7100, 7100, false),
        newSC('Depreciation', catIdByName.get('Expenditure'), 8101, 8101, false),
        newSC('Tangible Fixed Assets', catIdByName.get('Fixed Assets'), 9010, 9015, false),
        newSC('Stock', catIdByName.get('Current Assets'), 9200, 9200, false),
        newSC('Debtors', catIdByName.get('Current Assets'), 9300, 9399, false),
        newSC('Cash at bank and in hand', catIdByName.get('Current Assets'), 9400, 9499, true),
        newSC('Creditors', catIdByName.get('Current Liabilities'), 9600, 9799, false),
        newSC('Unrestricted', catIdByName.get('Funds'), 9800, 9800, false),
        newSC('Restricted', catIdByName.get('Funds'), 9810, 9810, false),
        newSC('Suspense', catIdByName.get('Funds'), 9999, 9999, false)
    };
    insert scs;
}


void insertNominalAccounts() {
    Map<String, Id> subCatIdByName = new Map<String, Id>();
    for (Zumzum__Sub_Category__c subCategory : [SELECT Id, Name FROM Zumzum__Sub_Category__c]) {
        subCatIdByName.put(subCategory.Name, subCategory.Id);
    }

    Map<String, Zumzum__Nominal_Account__c> allNominalAccountsMap = new Map<String, Zumzum__Nominal_Account__c> {
        'Debtors' => newNA('Debtors', 9300, 1065, 1275, false, false, subCatIdByName.get('Debtors'), 1065, 1275),
        'Card Receipts in Transit' => newNA('Card Receipts in Transit', 9401, 625, 815, false, TRUE, subCatIdByName.get('Cash at bank and in hand'), 625, 815),
        'Bank Current Account Lloyds' => newNA('Bank Current Account Lloyds', 9400, 60, 695, false, false, subCatIdByName.get('Cash at bank and in hand'), 60, 695),
        'Course Income' => newNA('Course Income',1400, 1275, 190, false, TRUE, subCatIdByName.get('Charitable Activities - NCT Courses'), 1275, 190),
        'Subcontractor Fees' => newNA('Subcontractor Fees', 5130, 0, 100, TRUE, false, subCatIdByName.get('Parentforce costs'), 0, 100),
        'Creditors' => newNA('Creditors', 9600, 100, 50, false, false, subCatIdByName.get('Creditors'), 100, 50),
        'Equipment' => newNA('Equipment', 5234, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Subscriptions' => newNA('Subscriptions', 5237, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Office and IT Equipment Cost' => newNA('Office and IT Equipment Cost', 9010, TRUE, false, subCatIdByName.get('Tangible Fixed Assets')),
        'Unrestricted funds brought forward' => newNA('Unrestricted funds brought forward', 9800, false, false, subCatIdByName.get('Unrestricted')),
        'Suspense Account' => newNA('Suspense Account', 9999, false, false, subCatIdByName.get('Suspense')),
        'Accruals' => newNA('Accruals', 9610, false, false, subCatIdByName.get('Creditors')),
        'Travel' => newNA('Travel', 5150, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Petty Cash' => newNA('Petty Cash', 9490, false, false, subCatIdByName.get('Cash at bank and in hand')),
        'Input VAT (Sales) Control Account' => newNA('Input VAT (Sales) Control Account', 9691, false, false, subCatIdByName.get('Creditors')),
        'Other Debtors' => newNA('Other Debtors', 9390, false, false, subCatIdByName.get('Debtors')),
        'Fundraising Courses' => newNA('Fundraising Courses', 1102, false, TRUE, subCatIdByName.get('Other Trading Activity - Community Fundraising')),
        'Restricted funds brought forward' => newNA('Restricted funds brought forward', 9810, false, false, subCatIdByName.get('Restricted')),
        'VAT Manual Adjustments' => newNA('VAT Manual Adjustments', 9693, false, false, subCatIdByName.get('Creditors')),
        'Cash Transfers' => newNA('Cash Transfers', 9700, false, false, subCatIdByName.get('Creditors')),
        'Irrecoverable VAT' => newNA('Irrecoverable VAT', 7100, TRUE, false, subCatIdByName.get('Ireccoverable VAT')),
        'Donations' => newNA('Donations', 1001, false, TRUE, subCatIdByName.get('Donations - Other')),
        'Membership Donations' => newNA('Membership Donations', 1003, false, TRUE, subCatIdByName.get('Donations - Membership')),
        'Office and IT Equipment Depreciation' => newNA('Office and IT Equipment Depreciation', 9015, TRUE, false, subCatIdByName.get('Tangible Fixed Assets')),
        'National Advertising' => newNA('National Advertising', 5271, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Telephone' => newNA('Telephone', 5156, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Venue Hire' => newNA('Venue Hire', 5157, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Legacy donations' => newNA('Legacy donations', 1004, false, TRUE, subCatIdByName.get('Donations - Membership')),
        'Accommodation' => newNA('Accommodation', 5154, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Grant Income' => newNA('Grant Income', 1200, false, TRUE, subCatIdByName.get('Donations - Grants Receivable')),
        'Prof Fees & Consultancy' => newNA('Prof Fees & Consultancy', 5126, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Licenses' => newNA('Licenses', 5254, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Other' => newNA('Other', 5900, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Profit/loss on disposal of FA' => newNA('Profit/loss on disposal of FA', 5950, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Prepayments' => newNA('Prepayments', 9310, false, false, subCatIdByName.get('Debtors')),
        'Deferred income' => newNA('Deferred income', 9620, false, false, subCatIdByName.get('Creditors')),
        'Equipment Rental' => newNA('Equipment Rental', 5233, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Equipment Depreciation' => newNA('Equipment Depreciation', 8101, false, false, subCatIdByName.get('Depreciation')),
        'Bad Debt Write Of' => newNA('Bad Debt Write Of', 5801, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Fundraising Activities' => newNA('Fundraising Activities', 1101, false, TRUE, subCatIdByName.get('Other Trading Activity - Community Fundraising')),
        'Local Advertising' => newNA('Local Advertising', 5270, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Output VAT (Sales) Control Account' => newNA('Output VAT (Sales) Control Account', 9692, false, false, subCatIdByName.get('Creditors')),
        'Gift Aid' => newNA('Gift Aid', 1002, false, TRUE, subCatIdByName.get('Donations - Membership')),
        'Registration Fees' => newNA('Registration Fees', 1502, false, TRUE, subCatIdByName.get('Charitable Activities - NCT College')),
        'Training' => newNA('Training', 5115, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'VAT liability' => newNA('VAT liability', 9690, false, false, subCatIdByName.get('Creditors')),
        'Stock' => newNA('Stock', 9200, TRUE, false, subCatIdByName.get('Stock')),
        'Subsistence' => newNA('Subsistence', 5155, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Printing & Copying' => newNA('Printing & Copying', 5191, TRUE, false, subCatIdByName.get('Parentforce costs')),
        'Postage Costs' => newNA('Postage Costs', 5170, TRUE, false, subCatIdByName.get('Parentforce costs'))
    };
    List<Zumzum__Nominal_Account__c> allNominalAccounts = allNominalAccountsMap.values();
    insert allNominalAccounts;


    // update control account
    List<Zumzum__Control_Account__c> existingControlAccount = [
        SELECT Id FROM Zumzum__Control_Account__c
        LIMIT 1
    ];
    Zumzum__Control_Account__c controlAccountToAdd;
    if (existingControlAccount.isEmpty()) {
        controlAccountToAdd = new Zumzum__Control_Account__c();
    } else {
        controlAccountToAdd = existingControlAccount[0];
    }
    controlAccountToAdd.Zumzum__Accruals__c = allNominalAccountsMap.get('Accruals').Id;
    controlAccountToAdd.Zumzum__Bad_Debts__c = allNominalAccountsMap.get('Bad Debt Write Of').Id;
    controlAccountToAdd.Zumzum__Credit_Charges__c = allNominalAccountsMap.get('Creditors').Id;
    controlAccountToAdd.Zumzum__Creditors_Control__c = allNominalAccountsMap.get('Creditors').Id;
    controlAccountToAdd.Zumzum__Debtors_Control__c = allNominalAccountsMap.get('Debtors').Id;
    controlAccountToAdd.Zumzum__Default_Bank__c = allNominalAccountsMap.get('Bank Current Account Lloyds').Id;
    controlAccountToAdd.Zumzum__Default_Sales__c = allNominalAccountsMap.get('Course Income').Id;
    controlAccountToAdd.Zumzum__Deferred_Income__c = allNominalAccountsMap.get('Deferred income').Id;
    controlAccountToAdd.Zumzum__Exchange_Rate_Variance__c = allNominalAccountsMap.get('Bad Debt Write Of').Id;
    controlAccountToAdd.Zumzum__Expenses__c = allNominalAccountsMap.get('Travel').Id;
    controlAccountToAdd.Zumzum__Manual_Adjustments__c = allNominalAccountsMap.get('VAT Manual Adjustments').Id;
    controlAccountToAdd.Zumzum__Mispostings__c = allNominalAccountsMap.get('VAT Manual Adjustments').Id;
    controlAccountToAdd.Zumzum__Prepayments__c = allNominalAccountsMap.get('Prepayments').Id;
    controlAccountToAdd.Zumzum__Purchase_Discount__c = allNominalAccountsMap.get('Restricted funds brought forward').Id;
    controlAccountToAdd.Zumzum__Retained_Earnings__c = allNominalAccountsMap.get('Unrestricted funds brought forward').Id;
    controlAccountToAdd.Zumzum__Sales_Discount__c = allNominalAccountsMap.get('Course Income').Id;
    controlAccountToAdd.Zumzum__Suspense__c = allNominalAccountsMap.get('Suspense Account').Id;
    controlAccountToAdd.Zumzum__VAT_Liability__c = allNominalAccountsMap.get('VAT liability').Id;
    controlAccountToAdd.Zumzum__VAT_on_Purchases__c = allNominalAccountsMap.get('Input VAT (Sales) Control Account').Id;
    controlAccountToAdd.Zumzum__VAT_on_Sales__c = allNominalAccountsMap.get('Output VAT (Sales) Control Account').Id;
    upsert controlAccountToAdd;
}


renameNominalCategories();
deleteExistingNominalAccountsAndSubCategories();
insertSubCategories();
insertNominalAccounts();