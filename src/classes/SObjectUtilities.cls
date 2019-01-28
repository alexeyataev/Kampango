/*ContactUtilitiesTest Class: Used to check the Code Coverage.
    **
    * Author        : Ujwal Theja
    * Created Date  : 21-01-2019
    * (c) Copyright by CSS Corp.
    **
*/
public without sharing class SObjectUtilities {

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
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        System.debug('Options: '+options);
        return options;

    }

}
