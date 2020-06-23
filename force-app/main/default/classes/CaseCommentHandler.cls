public with sharing class CaseCommentHandler implements ITrigger{
    public set<Id> CaseCommentIds = new set<Id>();
    public list<JiraSalesforceDetail__c> setting=new list<JiraSalesforceDetail__c>();
    public CaseCommentHandler(){}
    
    public void bulkBefore(){}
    public void bulkAfter(){
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
            setting=[select id, Value__c from JiraSalesforceDetail__c where name = 'Auto_SF_Comment_Sync_Type'];
            
        }
    }
    public void beforeInsert(SObject so){}
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterDelete(SObject so){}
    public void afterUpdate(SObject newso, Sobject oldSo){}
    public void afterInsert(SObject so){
        CaseComment comm = (CaseComment)so;
        
        if(setting[0]!=null && setting[0].Value__c!=Null && setting[0].Value__c!='' &&
           !comm.CommentBody.contains('Created by Jira :')&&
           ((setting[0].Value__c.tolowerCase()=='public'&& comm.IsPublished)
            ||(setting[0].Value__c.tolowerCase()=='private'&& !comm.IsPublished)
            ||(setting[0].Value__c.tolowerCase()=='both'))){
                CaseCommentIds.add(comm.Id);
            }
        
    }
    public void andFinally(){
        if (!CaseCommentIds.isEmpty())
        {
            
            JiraAutoSyncHelper.SendComments(CaseCommentIds);
        }
    }    
    
}