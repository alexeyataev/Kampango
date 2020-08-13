List<Zumzum__Tax_Rate__c> taxRates = [
    SELECT Id, Name, Zumzum__Active__c
    FROM Zumzum__Tax_Rate__c
    WHERE Name LIKE '%Standard Rated%' 
        OR Name LIKE '%Zero Rated%'
];
for (Zumzum__Tax_Rate__c taxRate: taxRates){
    taxRate.Zumzum__Active__c = true;
}
update taxRates;

List<Zumzum__Tax_Rate__c> taxRatesToUpdate = new List<Zumzum__Tax_Rate__c>();
List<Zumzum__Tax_Rate__c> taxRecords = [
		SELECT Id, Zumzum__Active__c,Name, Zumzum__Type__c, Zumzum__Tax_Rate__c,
				Zumzum__Exclude_from_VAT_Return__c, Zumzum__is_default__c
		FROM Zumzum__Tax_Rate__c
];
Zumzum__Tax_Rate__c taxRateDefault = new Zumzum__Tax_Rate__c();
for (Zumzum__Tax_Rate__c taxRate : taxRecords) {
	if(taxRate.Name == 'Standard Rated Transactions (20%)'){
		taxRate.Zumzum__is_default__c = false;
		taxRateDefault = taxRate;
	}
}
update taxRateDefault;

for (Zumzum__Tax_Rate__c taxRate : taxRecords) {	
	if (taxRate.Name == 'Exempt Transactions (0%)') {
		taxRate.Zumzum__Active__c = true;
		taxRate.Zumzum__Exclude_from_VAT_Return__c = true;
		taxRatesToUpdate.add(taxRate);
	}
	if (taxRate.Name == 'Zero Rated Transactions (0%)'
		|| taxRate.Name == 'Zero Rated Acquisitions of Goods From Suppliers in EC (0%)'
		|| taxRate.Name == 'Standard Rated Acquisitions of Goods From Suppliers in EC (0%)'
		|| taxRate.Name == 'Zero Rated Acquisition of Services From Suppliers in EC (0%)'
		|| taxRate.Name == 'Standard Rated Acquisition of Services From Suppliers in EC (0%)'
		|| taxRate.Name == 'Zero Rated Acquisition of Services From Suppliers in EC (20%)'
		|| taxRate.Name == 'Standard Rated Acquisition of Services From Suppliers in EC (20%)'
		|| taxRate.Name == 'Zero Rated Acquisitions of Goods From Suppliers in EC (20%)'
		|| taxRate.Name == 'Standard Rated Acquisitions of Goods From Suppliers in EC (20%)'
		 
	   ) {
		taxRate.Zumzum__Active__c = false;
		taxRatesToUpdate.add(taxRate);
	}
	if(taxRate.Name == 'No VAT'){
		taxRate.Zumzum__Active__c = true;
		taxRate.Name = 'No VAT (0%)';
		taxRate.Zumzum__Type__c = 'Zero Rated';
		taxRate.Zumzum__Exclude_from_VAT_Return__c = false;
		taxRate.Zumzum__is_no_tax__c = true;
		taxRate.Zumzum__is_default__c = true;
		taxRatesToUpdate.add(taxRate);
	}	
}
update taxRatesToUpdate;