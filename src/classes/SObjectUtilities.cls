/*SObjectUtilities Class: Used to get the sObject pick list field values.
    **
    * Author        : Ujwal Theja
    * Created Date  : 28-01-2019
    * (c) Copyright by CSS Corp.
    **
*/

public without sharing class SObjectUtilities {
    /**
    *   @obj : This is sObject and can be API name of "Custom/Standard" objects.
    *   returns valid Object.
    *   @picklistfield : This is a picklistfield and should have pick list datatype with field values.
    *   returns list of Values.
    *    
    **/

    public static list<SelectOption> getPicklistValues(SObject obj, String picklistfield){
		
        
        
        list<SelectOption> options = new list<SelectOption>();
        
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   
        
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get(picklistfield).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        { 
            options.add(new SelectOption( a.getValue(),a.getLabel())); 
        }
        System.debug('Options: '+options);
        return options;
        
    }
    
}