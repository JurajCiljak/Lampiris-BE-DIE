/**
 * Created by mohamed.mizar on 9/01/18.
 *
 *  @Description: Helper class for Checking duplicate Case and Email messages
                  Task: SFBECASE-115  -> https://jira.lampiris.be/browse/SFBECASE-115
 */

public with sharing class HLPR_DuplicateEmailMessage {
    public static Map<String,Group> groupMap=new Map<String,Group>();
    private static Map<String,T_CMT_Email_Address_Language_Dependency__mdt> mailPrioritiesMap=new Map<String,T_CMT_Email_Address_Language_Dependency__mdt>();


    static {
        List<T_CMT_Email_Address_Language_Dependency__mdt> listMailPriorities=[SELECT T_Email_Address__c,Priority__c,Queue_Name__c FROM T_CMT_Email_Address_Language_Dependency__mdt];
        for(T_CMT_Email_Address_Language_Dependency__mdt mp:listMailPriorities){
            mailPrioritiesMap.put(mp.T_Email_Address__c,mp);
        }
        List<Group> listGroup=[Select g.Id, g.Name From Group g where g.Type='Queue'];
        for(Group g: listGroup){
            groupMap.put(g.Name,g);
        }
    }

    public static void checkAndFixDuplicateEmails( List <SObject> newEmailMessageList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap ){
        EmailMessage newEmail;
        List<Case> cases = new List<Case>();
        Set<String> fromAddressSet = new Set<String>();
        Set<String> subjectSet = new Set<String>();
        Map<Id,T_CMT_Email_Address_Language_Dependency__mdt> caseIdsWithEmailConfigMap =new Map<Id,T_CMT_Email_Address_Language_Dependency__mdt>();
        Datetime dt = System.now();
        dt=dt.addSeconds(-5);

        for(SObject so: newEmailMessageList){
            newEmail =(EmailMessage)so;
            fromAddressSet.add(newEmail.FromAddress);
            subjectSet.add(newEmail.Subject);
            if(newEmail.ToAddress.contains(';')){
                T_CMT_Email_Address_Language_Dependency__mdt pm=getPrioritizedMail(newEmail.ToAddress);
                if(pm!=null){
                    caseIdsWithEmailConfigMap.put(newEmail.ParentId,pm);
                    newEmail.ToAddress=pm.T_Email_Address__c;
                }
            }
        }

        List<EmailMessage> duplicateEmailMessageList =[SELECT Id,FromAddress,Subject,ParentId FROM EmailMessage
        WHERE FromAddress IN:fromAddressSet
        AND Subject IN:subjectSet
        AND Incoming = TRUE
        AND CreatedDate>=:dt];

        Map<String,List<EmailMessage>> duplicateEmailMessageMap =new Map<String,List<EmailMessage>>();

        for (EmailMessage emailMessage : duplicateEmailMessageList) {
            if(duplicateEmailMessageMap.containsKey(emailMessage.FromAddress)){
                duplicateEmailMessageMap.get(emailMessage.FromAddress).add(emailMessage);
            }else{
                List<EmailMessage> listMessages=new List<EmailMessage>();
                listMessages.add(emailMessage);
                duplicateEmailMessageMap.put(emailMessage.FromAddress,listMessages);
            }
        }
        fixCasesOwner(caseIdsWithEmailConfigMap);
        fixDuplicateCases(newEmailMessageList, duplicateEmailMessageMap);

    }

    private static  void fixDuplicateCases( List <SObject> newEmailMessageList,Map<String,List<EmailMessage>> duplicateEmailMessageMap){
        Map<Id,String> mailCaseIds=new Map<Id,String>();
        for(SObject so: newEmailMessageList) {
            EmailMessage newEmail = (EmailMessage) so;
            if(duplicateEmailMessageMap.keySet().contains(newEmail.FromAddress)){
                List<EmailMessage> emailMessages= duplicateEmailMessageMap.get(newEmail.FromAddress);
                for (EmailMessage emailMessage : emailMessages) {
                    mailCaseIds.put(emailMessage.ParentId,newEmail.FromAddress);
                }
            }
        }

        List<Case> listCasesToUpdate=[Select Id from Case where Id in:mailCaseIds.keySet()];

        for (Case aCase : listCasesToUpdate) {
            aCase.C_SPAM__c=true;
            aCase.Status='Closed';
            aCase.Reason='Duplicate';
        }
        if(!listCasesToUpdate.isEmpty()){
            update listCasesToUpdate;
        }

    }

    private static void fixCasesOwner(Map<Id,T_CMT_Email_Address_Language_Dependency__mdt> caseIdsWithEmailConfigMap){
        List<Case> cases=[SELECT id, Priority, T_To_Address__c,OwnerId FROM Case WHERE Id in :caseIdsWithEmailConfigMap.keySet()];
        System.debug(cases);
        for (Case aCase : cases) {
            aCase.T_To_Address__c= caseIdsWithEmailConfigMap.get(aCase.Id).T_Email_Address__c;
            aCase.OwnerId=groupMap.get(caseIdsWithEmailConfigMap.get(aCase.Id).Queue_Name__c).Id;
        }
        if(!cases.isEmpty()){
            update cases;
        }
    }

    public static T_CMT_Email_Address_Language_Dependency__mdt getPrioritizedMail(String emailAddresses){
        List<String> parts=emailAddresses.split(';');
        T_CMT_Email_Address_Language_Dependency__mdt result;
        Decimal oldPriority=0;
        for(String emailAddress: parts){
            T_CMT_Email_Address_Language_Dependency__mdt ep=mailPrioritiesMap.get(emailAddress);
            if(ep!=null && ep.Priority__c > oldPriority){
                result=ep;
                oldPriority=ep.Priority__c;
            }
        }
        return result;
    }

}