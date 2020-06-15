public with sharing class UserEncryptionDecryptionProvider {
    public static String encrypt(String dataToEncrypt, String userId) {
        String strEncrypted = ued.UserCryptoHelper.doEncrypt(dataToEncrypt, userId);
        return strEncrypted;
    }
    public static String decrypt(String dataToDecrypt) {
        String strDecrypted = ued.UserCryptoHelper.doDecrypt(dataToDecrypt);
        return strDecrypted;
    }
    public static String decryptUrl(String urlData) {
        urlData = EncodingUtil.urlDecode(urlData, 'UTF-8').replace(' ', '+');
        String urlDataDecrypted = decrypt(urlData);
        return urlDataDecrypted;
    }
}
