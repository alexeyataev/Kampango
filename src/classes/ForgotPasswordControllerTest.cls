/**
 * An apex page controller that exposes the site forgot password functionality
 */

@IsTest public with sharing class ForgotPasswordControllerTest {
  	 @IsTest public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
    @IsTest
    public static void testPositiveForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User'];
      	User u = new User(Alias = 'newUsers', Email='newusers@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newusers@testorg.com');
    	ForgotPasswordController controller = new ForgotPasswordController();
        
    	controller.username = 'newusers@testorg.com';     	
    	controller.forgotPassword();	
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}