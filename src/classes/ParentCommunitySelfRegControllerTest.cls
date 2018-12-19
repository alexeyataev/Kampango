@IsTest public with sharing class ParentCommunitySelfRegControllerTest {
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegController() {
        list<String> pref = new list<String> {'Mail','Phone'};
        
        ParentCommunitySelfRegController controller = new ParentCommunitySelfRegController();
        list<SelectOption> sel= controller.getPreferenceOptions();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.Email = 'test@force.com';
        controller.phone = '123456789';
        controller.SelectedPreferences = pref ;
        //controller.communityNickname = 'test';
        
              
		system.assertNotEquals(null, sel, 'The collection should be instantiated');
    	system.assert(!sel.isEmpty(), 'The collection should be populated');
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
        System.assert(controller.registerUser() == null);  
        //controller.ParentCommunitySelfReg();
        
    } 
    @IsTest(SeeAllData=true) //Wrong Password
    public static void testCommunitiesSelfRegControllerWrongPassword() {
       list<String> pref = new list<String> {'Mail','Phone'};
        
        ParentCommunitySelfRegController controller = new ParentCommunitySelfRegController();
        list<SelectOption> sel= controller.getPreferenceOptions();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.Email = 'test@force.com';
        controller.phone = '123456789';
        controller.SelectedPreferences = pref ;
        //controller.communityNickname = 'test';
        
              
		system.assertNotEquals(null, sel, 'The collection should be instantiated');
    	system.assert(!sel.isEmpty(), 'The collection should be populated');
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'sdsdsfsf';
        System.assert(controller.registerUser() == null);  
        System.assert(controller.registerUser() == null);    
        
    }    
    @IsTest(SeeAllData=true) //Null Password
    public static void testCommunitiesSelfRegControllerNullPassword() {
        list<String> pref = new list<String> {'Mail','Phone'};
        
        ParentCommunitySelfRegController controller = new ParentCommunitySelfRegController();
        list<SelectOption> sel= controller.getPreferenceOptions();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.Email = 'test@force.com';
        controller.phone = '123456789';
        controller.SelectedPreferences = pref ;
        //controller.communityNickname = 'test';
        
              
		system.assertNotEquals(null, sel, 'The collection should be instantiated');
    	system.assert(!sel.isEmpty(), 'The collection should be populated');
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        //controller.password = 'abcd1234';
        //controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
        System.assert(controller.registerUser() == null);    
        
    }
}