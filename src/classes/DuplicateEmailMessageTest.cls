/**
 * Created by mohamed.mizar on 9/01/18.
 *
 * @Description: Test class to test duplicate cases
                  Task: Task: SFBECASE-115  -> https://jira.lampiris.be/browse/SFBECASE-115
 */

@isTest(SeeAllData=true)
public with sharing class DuplicateEmailMessageTest {

    public static TST_UtilityClass.TestUtilityWrapperClass UnitTest{get;set;}

    @isTest
    static void testDuplicateMail() {
        Test.startTest();
        Profile testProfil = TST_UtilityClass.getProfileByName('System Administrator');
        User testUser = TST_UtilityClass.createTestUser(testProfil);
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        insert testUser;

        for (Integer i=0;i<2;i++) {
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'Test duplicate';
            email.plainTextBody = 'This is a duplicate mail'+i;

            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            env.fromAddress = 'test@lampiris.be';
            env.toAddress = 'mohamed.mizar@lampiris.be;testunjean@gmail.com';

            EmailToCaseHandlerForTest emailHandler = new EmailToCaseHandlerForTest();
            emailHandler.handleInboundEmail(email, env);
        }
        Integer invocations = Limits.getEmailInvocations();

        List<Case> listCases=[Select Status,C_SPAM__c,Reason FROM Case where SuppliedEmail='test@lampiris.be'];
        System.assertEquals(2,listCases.size());
        for (Case aCase : listCases) {
            if('Closed'.equals(aCase.Status)){
                System.assert(aCase.C_SPAM__c);
                System.assertEquals(aCase.Reason,'Duplicate');
            }else{
                System.assert(!aCase.C_SPAM__c);
            }

        }
        Test.stopTest();
    }

}