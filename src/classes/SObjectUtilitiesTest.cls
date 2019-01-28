/*ContactUtilitiesTest Class: Used to check the Code Coverage.
    **
    * Author        : Ujwal Theja
    * Created Date  : 23-01-2019
    * (c) Copyright by CSS Corp.
    **
*/
@isTest
private class SObjectUtilitiesTest {
     
	@isTest static void positive_method() {
		
		Contact con = new Contact();
        
        list<SelectOption> nearestBranchs = SObjectUtilities.getPicklistValues(con, 'salutation');
        
        System.assertNotEquals(null, nearestBranchs);
        System.assertNotEquals(0, nearestBranchs.size());


    }
	@isTest static void negative_method() {
		
		Contact con = new Contact();
        
        list<SelectOption> nearestBranchs = SObjectUtilities.getPicklistValues(con, 'FirstName');
     
		System.assertNotEquals(null, nearestBranchs);
        System.assertEquals(0, nearestBranchs.size());
	}
}