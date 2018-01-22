<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>T_EA_Send_Auto_Response_In_All_Languages</fullName>
        <description>Send Auto-Response in all languages</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_AutoResponse_All_Languages</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Auto_Response_In_Dutch</fullName>
        <description>Send Auto-Response in Dutch</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_AutoResponse_NL</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Auto_Response_In_English</fullName>
        <description>Send Auto-Response in English</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_AutoResponse_EN</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Auto_Response_In_German</fullName>
        <description>Send Auto-Response in German</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_AutoResponse_DE</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Auto_Response_in_French</fullName>
        <description>Send Auto-Response in French</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_AutoResponse_FR</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Reminder_Email_All_Languages</fullName>
        <description>Send Reminder Email All Languages</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_Reminder_All_Languages</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Reminder_Email_DE</fullName>
        <description>Send Reminder Email DE</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_Reminder_DE</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Reminder_Email_En</fullName>
        <description>Send Reminder Email EN</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_Reminder_EN</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Reminder_Email_Fr</fullName>
        <description>Send Reminder Email FR</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_Reminder_FR</template>
    </alerts>
    <alerts>
        <fullName>T_EA_Send_Reminder_Email_Nl</fullName>
        <description>Send Reminder Email NL</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>L_Automated_Email_Templates/Lampiris_Reminder_NL</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Set_As_Spam</fullName>
        <description>This workflow action is used to set the case as spam cases.</description>
        <field>C_SPAM__c</field>
        <literalValue>1</literalValue>
        <name>Case_Set_As_Spam</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Push_Detected_Language_DE</fullName>
        <description>This field update is used to set the detected language to &quot;DE&quot;</description>
        <field>C_Detected_Language__c</field>
        <literalValue>DE</literalValue>
        <name>Case Push Detected Language DE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Push_Detected_Language_EN</fullName>
        <description>This field update is used to set the detected language to &quot;EN&quot;</description>
        <field>C_Detected_Language__c</field>
        <literalValue>EN</literalValue>
        <name>Case Push Detected Language EN</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Push_Detected_Language_FR</fullName>
        <description>This field update is used to set the detected language to &quot;FR&quot;</description>
        <field>C_Detected_Language__c</field>
        <literalValue>FR</literalValue>
        <name>Case Push Detected Language FR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Push_Detected_Language_NL</fullName>
        <description>This field update is used to set the detected language to &quot;NL&quot;</description>
        <field>C_Detected_Language__c</field>
        <literalValue>NL</literalValue>
        <name>Case Push Detected Language NL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Set_External_Id</fullName>
        <description>This field update push the Case NUmber to the field &quot;Case Number (External Id)&quot;</description>
        <field>T_Case_Number__c</field>
        <formula>CaseNumber</formula>
        <name>Case Set External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Set_Inbound_Email_SLA_To_False</fullName>
        <description>This field update sets the Trigger Inbound Email SLA field to false.</description>
        <field>T_Trigger_Inbound_Email_SLA__c</field>
        <literalValue>0</literalValue>
        <name>Case Set Inbound Email SLA To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Set_Inbound_Email_SLA_To_True</fullName>
        <description>This field update sets the Trigger Inbound Email SLA field to true.</description>
        <field>T_Trigger_Inbound_Email_SLA__c</field>
        <literalValue>1</literalValue>
        <name>Case Set Inbound Email SLA To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Set_Outbound_Email_SLA_False</fullName>
        <description>This field update sets the Trigger Outbound Email SLA field to false.</description>
        <field>T_Trigger_Outbound_Email_SLA__c</field>
        <literalValue>0</literalValue>
        <name>Case Set Outbound Email SLA To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Set_Outbound_Email_SLA_To_True</fullName>
        <description>This field update sets the Trigger Outbound Email SLA field to true.</description>
        <field>T_Trigger_Outbound_Email_SLA__c</field>
        <literalValue>1</literalValue>
        <name>Case Set Outbound Email SLA To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Set_Priority_To_High</fullName>
        <description>This field update is used to set the priority of a case to high</description>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Case Set Priority To High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>T_FU_Case_Set_Status_To_Closed</fullName>
        <description>This field update is used to close a case &quot;On-hold awaiting customer&quot; that has not received any answer from the customer within 5 days</description>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Case Set Status To Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>T_WF_Case_Push_Account_Language_DE</fullName>
        <actions>
            <name>T_FU_Case_Push_Detected_Language_DE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to push the language DE of an account to a related case.</description>
        <formula>ISPICKVAL(Account.C_Language__c, &quot;DE&quot;) &amp;&amp; OR(ISNEW(),ISCHANGED(ContactId),ISCHANGED(AccountId)) &amp;&amp; IF(    ISNULL( AccountId ),FALSE,    IF(ISBLANK(TEXT(Account.C_Language__c)), FALSE,TRUE)    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>T_WF_Case_Push_Account_Language_EN</fullName>
        <actions>
            <name>T_FU_Case_Push_Detected_Language_EN</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to push the language EN of an account to a related case.</description>
        <formula>ISPICKVAL(Account.C_Language__c, &quot;EN&quot;) &amp;&amp; OR(ISNEW(),ISCHANGED(ContactId),ISCHANGED(AccountId)) &amp;&amp; IF(    ISNULL( AccountId ),FALSE,    IF(ISBLANK(TEXT(Account.C_Language__c)), FALSE,TRUE)    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>T_WF_Case_Push_Account_Language_FR</fullName>
        <actions>
            <name>T_FU_Case_Push_Detected_Language_FR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to push the language FR of an account to a related case.</description>
        <formula>ISPICKVAL(Account.C_Language__c, &quot;FR&quot;) &amp;&amp; OR(ISNEW(),ISCHANGED(ContactId),ISCHANGED(AccountId)) &amp;&amp; IF(    ISNULL( AccountId ),FALSE,    IF(ISBLANK(TEXT(Account.C_Language__c)), FALSE,TRUE)    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>T_WF_Case_Push_Account_Language_NL</fullName>
        <actions>
            <name>T_FU_Case_Push_Detected_Language_NL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to push the language NL of an account to a related case.</description>
        <formula>ISPICKVAL(Account.C_Language__c, &quot;NL&quot;) &amp;&amp; OR(ISNEW(),ISCHANGED(ContactId),ISCHANGED(AccountId)) &amp;&amp; IF(    ISNULL( AccountId ),FALSE,    IF(ISBLANK(TEXT(Account.C_Language__c)), FALSE,TRUE)    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>T_WF_Case_Set_As_Spam</fullName>
        <actions>
            <name>Case_Set_As_Spam</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>T_FU_Case_Set_Status_To_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
            <value>Undelivered Mail Returned to Sender</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is used to close spam cases from mailer-daemon@lampiris.biz.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>T_WF_Case_Set_External_Id</fullName>
        <actions>
            <name>T_FU_Case_Set_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to push the case number to the field &quot;Case Number (External Id)&quot; flagged as external Id.</description>
        <formula>NOT (ISBLANK(CaseNumber))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>T_WF_Case_Set_Priority_To_High_For_VIP_Accounts</fullName>
        <actions>
            <name>T_FU_Case_Set_Priority_To_High</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to set the priority to &quot;High&quot; if the Account is flagged as &quot;VIP&quot;.</description>
        <formula>IF (  (Account.C_VIP__c = True), True, False )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>T_WF_Case_Set_Status_To_Closed_When_No_Response_From_Customer</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold - Awaiting Customer</value>
        </criteriaItems>
        <description>This workflow is used to close cases &quot;On-hold awaiting Customer&quot; that have not received any answer from the customer within 5 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>T_FU_Case_Set_Status_To_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>T_WF_Send_Reminder_Email_All_Languages</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold - Awaiting Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.C_Detected_Language__c</field>
            <operation>notEqual</operation>
            <value>FR,NL,DE,EN</value>
        </criteriaItems>
        <description>This workflow is used to send a reminder email after 2 days that a case record has been put as &quot;On-hold - awaiting customer&quot; and detected language is unknown</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>T_EA_Send_Reminder_Email_All_Languages</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>T_WF_Send_Reminder_Email_DE</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold - Awaiting Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.C_Detected_Language__c</field>
            <operation>equals</operation>
            <value>DE</value>
        </criteriaItems>
        <description>This workflow is used to send a reminder email after 2 days that a case record has been put as &quot;On-hold - awaiting customer&quot; and detected language = &quot;DE&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>T_EA_Send_Reminder_Email_DE</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>T_WF_Send_Reminder_Email_EN</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold - Awaiting Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.C_Detected_Language__c</field>
            <operation>equals</operation>
            <value>EN</value>
        </criteriaItems>
        <description>This workflow is used to send a reminder email after 2 days that a case record has been put as &quot;On-hold - awaiting customer&quot; and detected language = &quot;EN&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>T_EA_Send_Reminder_Email_En</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>T_WF_Send_Reminder_Email_FR</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold - Awaiting Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.C_Detected_Language__c</field>
            <operation>equals</operation>
            <value>FR</value>
        </criteriaItems>
        <description>This workflow is used to send a reminder email after 2 days that a case record has been put as &quot;On-hold - awaiting customer&quot; and detected language = &quot;FR&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>T_EA_Send_Reminder_Email_Fr</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>T_WF_Send_Reminder_Email_NL</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold - Awaiting Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.C_Detected_Language__c</field>
            <operation>equals</operation>
            <value>NL</value>
        </criteriaItems>
        <description>This workflow is used to send a reminder email after 2 days that a case record has been put as &quot;On-hold - awaiting customer&quot; and detected language = &quot;NL&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>T_EA_Send_Reminder_Email_Nl</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
