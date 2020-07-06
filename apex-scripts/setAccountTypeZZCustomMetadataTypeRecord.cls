Metadata.DeployContainer container = new Metadata.DeployContainer();
List<Metadata.Metadata> records = Metadata.Operations.retrieve(Metadata.MetadataType.CustomMetadata, new List<String>{'Zumzum__Account_Settings__mdt.Zumzum__Account_Settings'});
for (Metadata.Metadata record : records) {
    Metadata.CustomMetadata settingRecord = (Metadata.CustomMetadata) record;
    for (Metadata.CustomMetadataValue settingRecordValue : settingRecord.values) {
        if (settingRecordValue.field == 'Zumzum__Zumzum_Accounting_Customer_Value__c') {
            settingRecordValue.value = 'Customer,Household';
        }
		if (settingRecordValue.field == 'Zumzum__Zumzum_Accounting_Customer_Field__c') {
            settingRecordValue.value = 'Accounting_Type__c';
        }
        if (settingRecordValue.field == 'Zumzum__Disable_Account_Number_Uniqueness_Check__c') {
            settingRecordValue.value = true;
        }
    }
container.addMetadata(settingRecord);
}
Id asyncResultId = Metadata.Operations.enqueueDeployment(container, null);
