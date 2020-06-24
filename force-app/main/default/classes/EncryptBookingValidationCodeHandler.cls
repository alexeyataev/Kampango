public with sharing class EncryptBookingValidationCodeHandler {
    private static final String PARENT_COMMUNITY_PROFILE_NAME = 'Parent Community Profile';
    @InvocableMethod
    public static List<List<String>> encrypt(List<List<String>> dataToEncrypt) {
        List<List<String>> encryptedValidationCodeList = new List<List<String>>();
        try {
            User parentCommunityUser = [SELECT Id FROM User WHERE Profile.Name =: PARENT_COMMUNITY_PROFILE_NAME];
            for(List<String> dataToEncryptItem : dataToEncrypt) {
                String encryptedValidationCode = UserEncryptionDecryptionProvider.encrypt(dataToEncryptItem[0], parentCommunityUser.Id);
                encryptedValidationCodeList.add(new List<String> {encryptedValidationCode});
            }
        } catch(Exception e) {
            encryptedValidationCodeList.add(new List<String> {null});
        }
        return encryptedValidationCodeList;
    }
}