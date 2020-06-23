public class JiraIdeaCommentHandler implements ITrigger {
    
    public list<JiraSalesforceDetail__c> setting=new list<JiraSalesforceDetail__c>();
    Map<String,Map<Id,IdeaComment>> commentMap= new  Map<String,Map<Id,IdeaComment>>();
    public String Usertype;
    public String CreateUsertype;
    List<JiraRelationship__c> jiraRelationships=new List<JiraRelationship__c>();
    List<Id> ideaId=new List<Id>();
    Map<id,Set<JiraRelationship__c>> ideaTojiraRelationship=new Map<id,set<JiraRelationship__c>>();
    
    public JiraIdeaCommentHandler(){}
    public void bulkBefore(){}
    
    public void bulkAfter(){
        
        if(!JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() || !JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
            return;
        }
        setting=[select id, Value__c from JiraSalesforceDetail__c where name = 'Auto_SF_Comment_Sync_Type'];
        
        for(Sobject so: trigger.new){
            IdeaComment objidea=(IdeaComment)so;
            ideaId.add(objidea.IdeaId);
        }
        
        
        jiraRelationships=[SELECT id,JiraIssue__c,JiraIssue__r.name,IdeaRelation__c,IdeaRelation__r.body FROM JiraRelationship__c WHERE IdeaRelation__c IN: ideaID]; 
        
        
        for(JiraRelationship__c jr : jiraRelationships){
            
            if(ideaTojiraRelationship.containsKey(jr.IdeaRelation__c)){
                ideaTojiraRelationship.get(jr.IdeaRelation__c).add(jr);
            }else{
                ideaTojiraRelationship.put(jr.IdeaRelation__c,new Set<JiraRelationship__c>{jr});
            }
        }
        
        
        
        for(IdeaComment ideaCom : [SELECT Id,IdeaId, CommentBody,CreatedById, CreatedDate, CreatorName FROM IdeaComment WHERE Id IN:Trigger.new]){          
            
            if(ideaTojiraRelationship.containsKey(ideaCom.IdeaId)){
                
                Set<JiraRelationship__c> realtionSet=ideaTojiraRelationship.get(ideaCom.IdeaId);
                
                for(JiraRelationship__c jr: realtionSet){
                    
                    if(commentMap.containsKey(jr.JiraIssue__r.name)){
                        commentMap.get(jr.JiraIssue__r.name).put(ideaCom.id,ideaCom);
                    }else{
                        commentMap.put(jr.JiraIssue__r.name,new Map<Id,IdeaComment >{ideaCom.id=>ideaCom});
                    }
                }
            }               
        }
    }
    
    public void  beforeInsert(SObject so){}
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterDelete(SObject so){}
    public void afterUpdate(SObject newso, Sobject oldSo){}
    public void afterInsert(SObject so){}
    public void andFinally(){
        
        
        if(!commentMap.isEmpty()){
            string jsonstring = JSON.serialize(commentMap);
            JiraAutoSyncHelper.SendideaCommentsTojira(jsonstring);
            
        }
    }
}