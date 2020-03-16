public without sharing class TestEmailUtility {
    public static Boolean emailsFeatureEnabled() {
        try {
            Messaging.reserveSingleEmailCapacity(1);
        } catch (System.NoAccessException e) {
            return false;
        }
        return true;
    }
}
