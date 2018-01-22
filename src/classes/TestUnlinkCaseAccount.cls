/**
 * Created by mohamed.mizar on 6/01/18.
 */
@isTest
public with sharing class TestUnlinkCaseAccount {

    public static TST_UtilityClass.TestUtilityWrapperClass UnitTest{get;set;}
    @isTest
    static  void testUnlikAccountFromCase() {
        Test.startTest();
        UnitTest = new TST_UtilityClass.TestUtilityWrapperClass();
        UnitTest.CPAS_EmailAddressInit();
        Account testPersonAccount = TST_UtilityClass.createTestPersonAccount('Person Account','1','0474123452','tst@tst.com');
        insert testPersonAccount;
        Profile testProfil = TST_UtilityClass.getProfileByName('System Administrator');
        User testUser = TST_UtilityClass.createTestUser(testProfil);
        insert testUser;
        Account_Reference__c testAccountReference = TST_UtilityClass.createTestAccountReference(testPersonAccount);
        insert testAccountReference;

        List<Case> lsCase = new List<Case>();
        Case cs;
        cs = TST_UtilityClass.createTestCase( testAccountReference,testUser );
        cs.SuppliedEmail='tst@tst.com';
        cs.C_Account_Reference__c = null;
        cs.Status = 'New';
        //cs.Origin='Internal';

        system.assert(cs.AccountId!=null);
        lsCase.Add(cs);
        HNDL_Case.setFirstRun(true);
        insert lsCase;
        Set<Id> caseIds=new Set<Id>();
        for (Case aCase : lsCase) {
            caseIds.add(cs.Id);
        }
        System.debug('Linked account is:'+cs.AccountId);
        List<Case> caseResultList= [ SELECT Id, AccountId FROM Case WHERE Id in :caseIds];

        for (Case caseResult : caseResultList) {
            System.debug('Case '+ caseResult.Id +' inserted linked to account :'+caseResult.AccountId);
            system.assert(caseResult.Id!=null);
            system.assertEquals(null,caseResult.AccountId);
        }

        Test.stopTest();

    }

}