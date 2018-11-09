<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Confirmation_Email</fullName>
        <description>Send Confirmation Email</description>
        <protected>false</protected>
        <recipients>
            <field>Client__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/Booking_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Send_Reservation_Email</fullName>
        <description>Send Reservation Email</description>
        <protected>false</protected>
        <recipients>
            <field>Client__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/Course_Reservation</template>
    </alerts>
</Workflow>
