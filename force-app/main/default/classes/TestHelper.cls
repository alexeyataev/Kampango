public with sharing class TestHelper {
    public static User assignPermissionSetToUser(String permissionSetName, String profileName) {

        PermissionSet permissionInstance = [
            SELECT Id 
            FROM PermissionSet
            WHERE Name = :permissionSetName
            LIMIT 1
        ];
        
        User userInstance = [
            SELECT Id
            FROM User
            WHERE Profile.Name = :profileName
            LIMIT 1
        ];

        insert new PermissionSetAssignment(AssigneeId = userInstance.Id, PermissionSetId = permissionInstance.Id);

    return userInstance;
    }
}