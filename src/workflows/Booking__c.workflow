<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Booking_Status_is_Paid_or_Installment_mail_to_parent</fullName>
        <description>Booking Status is Paid or Installment mail to parent</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/Booking_Status_is_Paid_or_Installment</template>
    </alerts>
</Workflow>
