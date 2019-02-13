<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>GW_Volunteers__Volunteer_Signup_Notification_Email_Alert_Contact</fullName>
        <description>Volunteer Signup Notification Email Alert - Contact</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>GW_Volunteers__Volunteers_Email_Templates/GW_Volunteers__Volunteer_Signup_Notification</template>
    </alerts>
    <alerts>
        <fullName>GW_Volunteers__Volunteer_Signup_Thank_You_Email_Alert_Contact</fullName>
        <description>Volunteer Signup Thank You Email Alert - Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>GW_Volunteers__Volunteers_Email_Templates/GW_Volunteers__Volunteer_Signup_Thank_You</template>
    </alerts>
    <alerts>
        <fullName>Volunteer_de_registration_alert</fullName>
        <description>Volunteer de-registration alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>anjineyulu.valasa@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>swathi.kota@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>GW_Volunteers__Volunteers_Email_Templates/Volunteer_de_register</template>
    </alerts> 
    <tasks>
        <fullName>GW_Volunteers__Volunteer_Signup_Thank_You_Sent_Contact</fullName>
        <assignedToType>owner</assignedToType>
        <description>An automatic thank you email has been sent to the contact for signing up to be a volunteer.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Volunteer Signup Thank You Sent - Contact</subject>
    </tasks>
</Workflow>
