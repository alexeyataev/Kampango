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