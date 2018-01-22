/**
 * Created by mohamed.mizar on 12/01/18.
 *
 * @Description: Inbound Email handler to mimic Email-to-case functionnality
                  Task: Task: SFBECASE-115  -> https://jira.lampiris.be/browse/SFBECASE-115
 */

global class EmailToCaseHandlerForTest implements Messaging.inboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail inboundEmail, Messaging.InboundEnvelope inboundEnvelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success=true;
        result.message='the mail processed succesfully';


        TST_UtilityClass.TestUtilityWrapperClass UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        Account testPersonAccount = TST_UtilityClass.createTestPersonAccount('Person Account','1','0474123452','tst@tst.com');
        insert testPersonAccount;
        Profile testProfil = TST_UtilityClass.getProfileByName('System Administrator');
        User testUser = TST_UtilityClass.createTestUser(testProfil);
        insert testUser;
        Account_Reference__c testAccountReference = TST_UtilityClass.createTestAccountReference(testPersonAccount);
        insert testAccountReference;

        Case cs;
        cs = TST_UtilityClass.createTestCase( testAccountReference,testUser );
        cs.Subject=inboundEmail.subject;
        cs.SuppliedEmail=inboundEnvelope.fromAddress;
        cs.Description=inboundEmail.plainTextBody;

        insert cs;
        EmailMessage aMessage=new EmailMessage();
        aMessage.Subject=inboundEmail.subject;
        aMessage.FromAddress=inboundEnvelope.fromAddress;
        aMessage.ToAddress=inboundEnvelope.toAddress;
        aMessage.TextBody=inboundEmail.plainTextBody;
        aMessage.ParentId=cs.Id;
        aMessage.Incoming=true;
        try{
            insert aMessage;
        }catch(Exception e){
            System.debug(e);
        }
        return result;
    }

}