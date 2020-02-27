Map<String, Integer> getRecordsCountByFieldName(String fieldName) {
    Map<String, Integer> resultMap = new Map<String, Integer>();
    List<String> objectsWithField = findObjectsByField(fieldName);
    for (String objectName : objectsWithField) {
        String q2 = 'SELECT count() FROM ' + objectName + ' WHERE ' + fieldName + ' <> null';
        Integer r2 = Database.countQuery(q2);
        if (r2 > 0) {
            System.debug(objectName + '=>' + r2);
        	resultMap.put(objectName, r2);    
        }
    }
    return resultMap;
}

List<String> findObjectsByField(String fieldName) {
    Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
    List<String> apiNames = new List<String>();
    
    for(string objectApi: globalDescribe.keyset()) {
        apiNames.add(objectApi);
    }
    
    Schema.DescribeSobjectResult[] results  = Schema.describeSObjects(apiNames);
    List<String> objectsWithField = new List<String>();
    for(Schema.DescribeSobjectResult describeResult  : results) {
        String objectName = describeResult.getName();
        
        Schema.SObjectField field = describeResult.fields.getMap().get(fieldName);
        if (field != null && !objectName.contains('ChangeEvent')) {
            objectsWithField.add(objectName);
        }
    }
    return objectsWithField;
}

void manualUnlink(String lookupField, String objName) {
    String query = 'SELECT Id FROM ' + objName + ' WHERE ' + lookupField + ' <> null';
    List<SObject> objects = Database.query(query);
    for (SObject obj : objects) {
        obj.put(lookupField, null);
    }
    update objects;
    System.debug('Unlinked ' + objName + ' manually');
}

/* these methods are Zumzum-specific */
void deleteLedgerEntriesByField(String field) {
    String query = 'SELECT Id FROM Zumzum__Sales_Invoice_Line_Item__c WHERE ' + field +' <> null';
    List<SObject> sili = Database.query(query);
    Set<Id> siliIds = new Set<Id>();
    for (SObject obj : sili) {
        siliIds.add(obj.Id);
    }
        
    Set<Id> journalIds = new Set<Id>();
    List<SObject> jli = [SELECT Id, Zumzum__Journal__c FROM Zumzum__Journal_Line_Item__c WHERE Zumzum__Sales_Invoice_Line_Item__c IN :siliIds];
    for (SObject obj : jli) {
        journalIds.add((Id)obj.get('Zumzum__Journal__c'));
    }
    List<SObject> journals = [SELECT Id, Name, Zumzum__Status__c FROM Zumzum__Journal__c WHERE Id IN :journalIds];
    for (SObject j : journals) {
        j.put('Zumzum__Status__c', 'Draft');
    }
    List<SObject> ledgers = [
        SELECT Id FROM Zumzum__Ledger__c
    ]; 
    List<SObject> ledgerHistories = [SELECT Id FROM Zumzum__Ledger_Payment_History__c]; 
    //reversed order    
    update journals;
    delete journals;
    
    delete jli;
    delete sili;
    
    delete ledgerHistories;
    delete ledgers;
}
void unlinkNominalAccountsFromRRRS() { //revenue recognition rule settings
    SObject rrrs = [SELECT Id FROM Zumzum__Revenue_Recognition_Rule_Setting__c LIMIT 1];
    rrrs.put('Zumzum__Deferred_Revenue_Nominal_Account__c', null); //Deferred Income
    rrrs.put('Zumzum__Recognised_Revenue_Nominal_Account__c', null); //Sales North
    update rrrs;
}
/* these methods are Zumzum-specific  */


String field = 'zumzum__nominal_account__c';
deleteLedgerEntriesByField(field);
unlinkNominalAccountsFromRRRS();
Map<String, Integer> objectToRecCount = getRecordsCountByFieldName(field);

List<String> queriesToUnlink = new List<String>();
for (String objName : objectToRecCount.keySet()) {
    String query = 'SELECT Id FROM ' + objName + ' WHERE ' + field +  ' <> null';
    System.debug(query);
    List<SObject> objects = Database.query(query);
    try {
        delete objects;
        System.debug('success');
    } catch (DmlException e) {
        System.debug('trying to unlink...');
        System.debug(e.getMessage());
        try {
        	manualUnlink(field, objName);
        } catch (Exception e2) {
            System.debug('cannot unlink - ' + objName);
            System.debug(e2.getMessage());
        }
    }
}