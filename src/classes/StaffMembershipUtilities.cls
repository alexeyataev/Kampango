public with sharing class StaffMembershipUtilities {
	
    
    public static list<User> createStaffMembership(Id userId){
        
        
        list<User> staffUserlist = [SELECT
                               Id ,
                         	   Username, 
                               LastName, 
                               FirstName, 
                               MiddleName, 
                               Suffix, 
                               Name, 
                               Title, 
                               Email, 
                               Phone,
                               Profile.Name 
                         FROM
                         	   User 
                         WHERE 
                         	   id = :userId];
        
        if(staffUserlist.size()>0 && staffUserlist[0].Profile.Name != null && staffUserlist[0].Profile.Name == 'Office Staff'){
            System.debug('Profile Name: '+staffUserlist[0].Profile.Name);
            
            return staffUserlist;
        }
        else{
            
            return null;
        }
    }
}