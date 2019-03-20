<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cancellation_Alert_Membership</fullName>
        <description>CancellationAlertMembership</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Second_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>npe03__Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Cancel_Membership</template>
    </alerts>
    <alerts>
        <fullName>Membership_Renewal_notification_Time_Trigger</fullName>
        <description>Membership Renewal notification Time Trigger</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>      
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Renewal</template>
    </alerts>
    <alerts>
        <fullName>Membership_Renewal_notification_Time_Triggers</fullName>
        <description>Membership Renewal notification Time Triggers</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>  
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Membership_Renewal_Date</template>
    </alerts>
    <alerts>
        <fullName>Membership_Renewal_notification_will_send_user</fullName>
        <description>Membership Renewal notification will send user based on Membership_Months_Left__c  minus 30 days</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Renewal</template>
    </alerts>
    <alerts>
        <fullName>Membership_Renewal_notification_will_send_user_based_on_Membership_Months_Left_c</fullName>
        <description>Membership Renewal notification will send user based on Membership_Months_Left__c  minus 30 days</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Renewal</template>
    </alerts>
    <alerts>
        <fullName>Membership_Status_is_Pending_email_trigger_to_parent</fullName>
        <description>Membership Status is Pending email trigger to parent</description>
        <protected>false</protected>
        <recipients>
            <field>npe03__Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Membership_Status_is_Pending_email_trigger_to_parent</template>
    </alerts>
    <alerts>
        <fullName>Payment_Method_Direct_Debit_email_trigger_to_parent</fullName>
        <description>Payment Method Direct Debit email trigger to parent</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Payment_Method_Direct_Debit_email_triggered_to_parent</template>
    </alerts>
    <alerts>
        <fullName>Receive_confirmation_email</fullName>
        <description>Receive confirmation email</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Second_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>npe03__Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/nctMembershipConfirmation</template>
    </alerts>
    <alerts>
        <fullName>Receive_confirmation_email_Any_payment_method_has_made</fullName>
        <description>Receive confirmation email Any payment method has made</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Second_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>npe03__Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/nctMembershipConfirmation</template>
    </alerts>
    <alerts>
        <fullName>Receive_confirmation_email_for_creditcard</fullName>
        <description>Receive confirmation email for creditcard</description>
        <protected>false</protected>
        <recipients>
            <field>First_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Second_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>npe03__Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Receive_confirmation_email_when_a_payment_has_been_made</template>
    </alerts>
    <alerts>
        <fullName>when_Any_payment_method_has_been_made_for_Membership</fullName>
        <description>when Any payment method has been made for Membership</description>
        <protected>false</protected>
        <recipients>
            <field>npe03__Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NCT_Templates/Receive_confirmation_email_when_a_payment_has_been_made</template>
    </alerts>
    <fieldUpdates>
        <fullName>Date_Established_field_update</fullName>
        <field>npe03__Date_Established__c</field>
        <formula>IF(ISPICKVAL( Membership_Status__c , &quot;Confirmed&quot;) , today(), DATEVALUE(CreatedDate ) )</formula>
        <name>Date Established field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>First_Payment_field_update</fullName>
        <field>First_Payment__c</field>
        <formula>IF(ISPICKVAL( Membership_Status__c , &quot;Confirmed&quot;) , today(), DATEVALUE(CreatedDate ) )</formula>
        <name>First Payment field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Nextdonationdatevalue</fullName>
        <field>npe03__Next_Payment_Date__c</field>
        <formula>ADDMONTHS(DATE(YEAR(Renewal_Date__c ),MONTH(Renewal_Date__c ),1),1)+2</formula>
        <name>Nextdonationdatevalue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
	<fullName>Renewal_Date_Field_Update</fullName>
        <description>Renewal date should be blank when change the status from Conformed to cancelled and Conformed to cancelling</description>
        <field>Renewal_Date__c</field>
        <name>Renewal Date Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Renewal_Update</fullName>
        <field>Renewal_Date__c</field>
        <formula>CASE( Text(Membership_type__c) , 
&quot;12 month membership&quot;, ADDMONTHS( DATETIMEVALUE(npe03__Date_Established__c),12),

&quot;18 month membership&quot;, ADDMONTHS( DATETIMEVALUE(npe03__Date_Established__c),18),

&quot;4 year membership&quot;, ADDMONTHS( DATETIMEVALUE(npe03__Date_Established__c),48),

&quot;Life Membership&quot;, ADDMONTHS( DATETIMEVALUE(npe03__Date_Established__c),1188),

&quot;Reduced 12 month membership&quot;, ADDMONTHS( DATETIMEVALUE(npe03__Date_Established__c),12),

&quot;Staff Membership&quot; , ADDMONTHS( DATETIMEVALUE(npe03__Date_Established__c),1188),

&quot;10 year membership&quot; , ADDMONTHS( DATETIMEVALUE(npe03__Date_Established__c),120),

null
)</formula>
        <name>Renewal Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>

    <rules>
        <fullName>Membership Renewal Notification</fullName>
        <actions>
            <name>Membership_Renewal_notification_will_send_user_based_on_Membership_Months_Left_c</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>IF((Membership_Months_Left__c = 1)  || (Membership_Months_Left__c = 0) , true, false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Renewel Notification Prior 30 days</fullName>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Renewal_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Membership_Renewal_notification_Time_Triggers</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>npe03__Recurring_Donation__c.Renewal_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Membership Status is Pending email trigger to parent</fullName>
        <actions>
            <name>Membership_Status_is_Pending_email_trigger_to_parent</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>Membership Status is Pending email trigger to parent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Payment Method Direct Debit email trigger to parent</fullName>
        <actions>
            <name>Payment_Method_Direct_Debit_email_trigger_to_parent</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Payment Method Direct Debit email trigger to parent</description>
        <formula>AND($Profile.Name = &quot;Enquiries Team&quot; &amp;&amp; ISPICKVAL( npsp4hub__Payment_Method__c, &apos;Direct Debit&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
	<fullName>Renewal Date Field Update</fullName>
        <active>false</active>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <description>if membership status is confirmed and based on the Date Established date field, update renewal date field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Renewal Date Update</fullName>
        <actions>
            <name>Renewal_Date_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Cancelling</value>
        </criteriaItems>
        <description>Renewal date should be blank when change the status from Conformed to cancelled and Conformed to cancelling</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
      <fullName>Renewal Update</fullName>
        <actions>
            <name>Renewal_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
        <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateNewDonationDate</fullName>
        <actions>
            <name>Nextdonationdatevalue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updating nextdonationdate field value based on the renewal date.</description>
        <formula>!ISNULL(Renewal_Date__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>cancellationAlertMembership</fullName>
        <actions>
            <name>Cancellation_Alert_Membership</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>creditcard Payment method</fullName>
        <actions>
            <name>Receive_confirmation_email_for_creditcard</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.npsp4hub__Payment_Method__c</field>
            <operation>contains</operation>
            <value>CreditCard</value>
        </criteriaItems>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.npsp4hub__Payment_Method__c</field>
            <operation>contains</operation>
            <value>Direct Debit</value>
        </criteriaItems>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>when Any payment method has been made for Membership</fullName>
        <actions>
            <name>Receive_confirmation_email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Date_Established_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>First_Payment_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>npe03__Recurring_Donation__c.Membership_Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
