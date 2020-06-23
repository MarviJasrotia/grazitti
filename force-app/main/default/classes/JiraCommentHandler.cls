public class JiraCommentHandler implements ITrigger {
    public list<JiraSalesforceDetail__c> setting=new list<JiraSalesforceDetail__c>();
    public Map<String,Map<Id,JiraIssueComments__c >> commentMap= new  Map<String,Map<Id,JiraIssueComments__c >>();
    public String Usertype;
    public String CreateUsertype;
    List<CaseComment> casecommentlist=new List<CaseComment>();
    List<CaseComment> casecommentlisttoinsert=new List<CaseComment>();
    List<CaseJiraHelper__c> CJHelperToInsert = New list<CaseJiraHelper__c>();
    List<JiraCommentController__c> controllerlist=new List<JiraCommentController__c>();
    List<JiraCommentController__c> controllerupdatelist=new List<JiraCommentController__c>();
    Map<String,List<JiraIssueComments__c>> JiraCommentsMap=new Map<String,List<JiraIssueComments__c>>();
    Map<String,List<JiraIssueComments__c>> JiraCommentsMap1=new Map<String,List<JiraIssueComments__c>>();
    
    Map<String,JiraIssueComments__c> CommentsUpdateMap=new Map<String,JiraIssueComments__c>();
    Map<String,JiraCommentController__c> ComidcontrollerMap=new Map<String,JiraCommentController__c>();
    map<String,Set<String>> comIdMap=new map<String,Set<String>>();
    List<CaseComment> commentsToUpdate=new List<CaseComment>();
    Set<string> CaseIds=new Set<string>();
    Set<String> commentIdset=new Set<String>();
    Set<String> CaseComIds=new Set<String>();
    public JiraCommentHandler(){}
    public void bulkBefore(){
        if(Trigger.Isinsert){
            for(Sobject So:Trigger.new){
                JiraIssueComments__c Ji = (JiraIssueComments__c)So;
                if(ji.Source__c!='Jira'){
                    ji.Source__c='Salesforce';
                }
            }
        } 
    }
    public void bulkAfter(){
        if(!System.isFuture() && JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() && JiraIssueComments__c.sObjectType.getDescribe().isAccessible()
           && CaseComment.sObjectType.getDescribe().isAccessible() && JiraCommentController__c.sObjectType.getDescribe().isAccessible() 
           && CaseJiraHelper__c.sObjectType.getDescribe().isAccessible() && JiraRelationShip__c.sObjectType.getDescribe().isAccessible()){
            // setting=[select id, Value__c from JiraSalesforceDetail__c where name = 'Auto_SF_Comment_Sync_Type'];
            
            if(Trigger.Isinsert){
                for(JiraIssueComments__c jiraCom : [SELECT Id,IsPublished__c,Author__c,UpdateAuthor__c,CommentId__c,source__c,JiraIssue__c, JiraIssue__r.name,JiraId__c, CommentBody__c,CreatedById,lastmodifiedby.name,lastmodifiedby.usertype,lastmodifieddate,CreatedBy.name,CreatedBy.usertype,CreatedDate FROM JiraIssueComments__c WHERE Id IN:Trigger.new]){
                    if(jiraCom.Source__c =='Jira' && !(jiracom.commentbody__c).contains('Created by Salesforce :')){
                        if(JiraSalesforceDetail__c.getvalues('Store_Jira_Comment_in_Case').value__c.toLowerCase() == 'yes'){
                            if(!JiraCommentsMap1.containsKey(JiraCom.JiraIssue__c)){
                                JiraCommentsMap1.put(JiraCom.JiraIssue__c,new List<JiraIssueComments__c>{JiraCom});
                            }else{
                                JiraCommentsMap1.get(JiraCom.JiraIssue__c).add(JiraCom);
                            }
                        }
                    }else if(jiraCom.Source__c =='Salesforce' && JiraSalesforceDetail__c.getValues('Sync_SF_Comments').value__c.toLowerCase()=='yes'){
                        if(commentMap.containsKey(jiraCom.JiraIssue__r.name)){
                            commentMap.get(jiraCom.JiraIssue__r.name).put(jiraCom.id,jiraCom);
                        }else{
                            commentMap.put(jiraCom.JiraIssue__r.name,new Map<Id,JiraIssueComments__c >{jiraCom.id=>jiraCom});
                        }
                    }
                    
                }
                for(JiraRelationShip__c JiraRel:[Select CaseRelation__c,JiraIssue__r.name,JiraIssue__c from JiraRelationShip__c where JiraIssue__c in:JiraCommentsMap1.keySet() and CaseRelation__c!=null]){
                    // CaseIds.add(JiraRel.CaseRelation__c);
                    //  for(String str1:JiraCommentsMap1.keySet()){
                    for(JiraIssueComments__c ji:JiraCommentsMap1.get(JiraRel.JiraIssue__c)){
                        CaseComment casecom=new CaseComment();
                        if(schema.sObjectType.CaseComment.fields.CommentBody.IsCreateable()){
                        casecom.CommentBody=ji.commentbody__c+'\n(Created by Jira : '+Ji.Author__c+')\n JiraIssue : '+JiraRel.JiraIssue__r.name;
                        }
                        if(schema.sObjectType.CaseComment.fields.ParentId.IsCreateable()){
                            casecom.ParentId=JiraRel.CaseRelation__c;
                        }
                        if(schema.sObjectType.CaseComment.fields.IsPublished.IsCreateable()){
                        casecom.IsPublished=ji.IsPublished__c;
                        }
                        casecommentlist.add(casecom);
                        
                    }
                    //   }
                }
            }
            
            if(Trigger.Isupdate){
                for(JiraIssueComments__c jiraCom : [SELECT Id,IsPublished__c,Author__c,UpdateAuthor__c,CommentId__c,source__c,JiraIssue__c, JiraIssue__r.name,JiraId__c, CommentBody__c,CreatedById,lastmodifiedby.name,lastmodifiedby.usertype,lastmodifieddate,CreatedBy.name,CreatedBy.usertype,CreatedDate FROM JiraIssueComments__c WHERE Id IN:Trigger.new]){
                    JiraIssueComments__c   oldJiraComment=(JiraIssueComments__c)Trigger.oldMap.get(jiraCom.id);
                    
                    if(jiraCom.CommentBody__c==oldJiraComment.CommentBody__c ){
                        continue;
                    }
                   
                    if((JiraCom.source__c=='Jira' && JiraCom.lastmodifiedby.usertype=='Guest')||test.isRunningTest()){
                        
                        if(JiraSalesforceDetail__c.getvalues('Store_Jira_Comment_in_Case').value__c.toLowerCase() == 'yes'){
                            if(!CommentsUpdateMap.containsKey(JiraCom.CommentId__c)){
                                CommentsUpdateMap.put(JiraCom.CommentId__c,JiraCom);
                            }else{
                                //CommentsUpdateMap.get(JiraCom.CommentId__c).add(JiraCom);
                            }
                            
                            if(!JiraCommentsMap.containsKey(JiraCom.JiraIssue__c)){
                                JiraCommentsMap.put(JiraCom.JiraIssue__c,new List<JiraIssueComments__c>{JiraCom});
                            }else{
                                JiraCommentsMap.get(JiraCom.JiraIssue__c).add(JiraCom);
                            }
                            
                        }else{
                            //return;
                            continue;
                        }
                    }else if(((JiraCom.source__c=='Salesforce' || Jiracom.lastmodifiedby.usertype!='Guest') && JiraSalesforceDetail__c.getValues('Sync_SF_Comments').value__c.toLowerCase()=='yes')||test.isRunningTest()){
                        if(commentMap.containsKey(jiraCom.JiraIssue__r.name)){
                            commentMap.get(jiraCom.JiraIssue__r.name).put(jiraCom.id,jiraCom);
                        }else{
                            commentMap.put(jiraCom.JiraIssue__r.name,new Map<Id,JiraIssueComments__c >{jiraCom.id=>jiraCom});
                        }
                    }
                }
                List<JiraRelationShip__c> JiraRellist=[Select CaseRelation__c,JiraIssue__r.name,JiraIssueId__c from JiraRelationShip__c where JiraIssue__c in:JiraCommentsMap.keySet() and CaseRelation__c!=null];
                for(JiraRelationShip__c rel:JiraRellist){
                    CaseIds.add(Rel.CaseRelation__c);  
                 
                }
                
                List<JiraCommentController__c> comlist=[SELECT Id, Name,CaseCommentId__c,CommentId__c,JiraCommentId__c,CommentType__c,JiraIssueId__c FROM JiraCommentController__c where CommentId__c in:commentsupdateMap.keyset()];
                for(JiraCommentController__c jicom:comlist){
                    CaseComIds.add(jicom.CaseCommentId__c);
                    if(!ComidcontrollerMap.containsKey(jicom.CaseCommentId__c))
                        ComidcontrollerMap.put(jicom.CaseCommentId__c,jicom);
                }
                
                List<CaseComment> casecomlist=[Select id,ParentId from CaseComment where ParentId in:CaseIds and id in:CaseComIds];
                for(CaseComment com:CaseComlist){
                    if(comIdMap.containsKey(com.parentId)){
                        comIdMap.get(com.parentId).add(com.id);
                    }else{
                        comIdMap.put(com.parentId,new set<String>{com.id});
                    }
                    
                    //  commentIdset.add(com.id);
                }
                
                for(String CaseId:CaseIds){
                  
                    if(ComIdMap.containskey(CaseId)){
                        //String comId=ComIdMap.get(CaseId);
                        for(String comId:ComIdMap.get(CaseId)){
                            //  for(String str:ComidcontrollerMap.keySet()){
                            //      if(str==comId){
                            JiraCommentController__c j=ComidcontrollerMap.get(comId);
                            JiraIssueComments__c jcom=CommentsUpdateMap.get(j.CommentId__c);
                            CaseComment caseCom=new CaseComment();
                          
                            caseCom.id=j.CaseCommentId__c;
                          
                          
                            
                            String commentbody=jcom.CommentBody__c;
                            
                            caseCom.CommentBody= commentBody+'\n (Created by Jira : '+Jcom.Author__c+')\n  (Updated by Jira : '+jcom.updateAuthor__c+')\nJiraIssue : '+jcom.JiraIssue__r.name;
                           
                            commentsToUpdate.add(caseCom);
                            
                            if(J.JiraIssueId__c==null){
                                if(schema.sObjectType.JiraCommentController__c.fields.JiraIssueId__c.IsUpdateable()){
                                J.JiraIssueId__c=jcom.JiraId__c;
                                }
                                controllerupdatelist.add(J);
                            }
                            //   }
                            //}
                        }
                    }else{
                        for(String comId:CommentsUpdateMap.keyset()){
                            JIraIssueComments__c jira=CommentsUpdateMap.get(comId);
                            CaseComment casecom=new CaseComment();
                            if(schema.sObjectType.CaseComment.fields.CommentBody.Iscreateable()){
                            casecom.CommentBody=jira.commentbody__c+'\n (Created by Jira : '+Jira.Author__c+')\n JiraIssue : '+Jira.JiraIssue__r.name;
                            }
                            if(schema.sObjectType.CaseComment.fields.ParentId.Iscreateable()){
                            casecom.ParentId=CaseId;
                            }
                            if(schema.sObjectType.CaseComment.fields.IsPublished.Iscreateable()){
                            casecom.IsPublished=jira.IsPublished__c;
                            }
                            
                            casecommentlisttoinsert.add(casecom);
                        }
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
            JiraAutoSyncHelper.sendCommentsToJira(jsonstring);
            
            
        }
        try{
            if(!casecommentlist.isEmpty() && schema.sObjectType.CaseComment.Iscreateable()){
                insert casecommentlist;
                for(CaseComment casecom:casecommentlist){
                    for(String str1:JiraCommentsMap1.keySet()){
                        for(JiraIssueComments__c ji:JiraCommentsMap1.get(str1)){
                            JiraCommentController__c controller =new JiraCommentController__c();
                            if(schema.sObjectType.JiraCommentController__c.fields.JiraIssueId__c.Iscreateable()){
                            controller.JiraIssueId__c=Ji.JiraId__c;
                            }
                            if(schema.sObjectType.JiraCommentController__c.fields.CommentId__c.Iscreateable()){
                            controller.CommentId__c=ji.CommentId__c;
                            }
                            if(schema.sObjectType.JiraCommentController__c.fields.CaseCommentId__c.Iscreateable()){
                            controller.CaseCommentId__c=casecom.id;
                            }
                            if(schema.sObjectType.JiraCommentController__c.fields.CommentType__c.Iscreateable()){
                            controller.CommentType__c='CaseComment';
                            }
                            ControllerList.add(controller);
                            
                            CaseJiraHelper__c CJH = New CaseJiraHelper__c();
                            if(schema.sObjectType.CaseJiraHelper__c.fields.Name.Iscreateable()){
                            CJH.Name = casecom.Id;
                            }
                            if(schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.Iscreateable()){
                            CJH.jiraissueid__c = ji.JiraIssue__r.name;
                            }
                            if(schema.sObjectType.CaseJiraHelper__c.fields.Type__c.Iscreateable()){
                            CJH.Type__c = 'Comment';
                            }
                            CJHelperToInsert.add(CJH);
                        }
                    }
                }
                if(!ControllerList.isEmpty() && schema.sObjectType.JiraCommentController__c.Iscreateable()){
                    insert ControllerList;
                }
                if(!CJHelperToInsert.isEmpty() && schema.sObjectType.CaseJiraHelper__c.Iscreateable()){
                    insert CJHelperToInsert;
                }
            }
            if(!casecommentlisttoinsert.isEmpty() && schema.sObjectType.CaseComment.Iscreateable()){
                insert casecommentlisttoinsert;
                
                for(CaseComment casecom:casecommentlisttoinsert){
                    if(ComidcontrollerMap.containsKey(casecom.id)){
                        
                    }else{
                        for(String val:CommentsUpdateMap.keySet()){
                            JiraIssueComments__c com=CommentsUpdateMap.get(val);
                            JiraCommentController__c controller =new JiraCommentController__c();
                             if(schema.sObjectType.JiraCommentController__c.fields.JiraIssueId__c.Iscreateable()){
                            controller.JiraIssueId__c=com.JiraId__c;
                             }
                             if(schema.sObjectType.JiraCommentController__c.fields.CommentId__c.Iscreateable()){
                            controller.CommentId__c=com.CommentId__c;
                             }
                             if(schema.sObjectType.JiraCommentController__c.fields.CaseCommentId__c.Iscreateable()){
                            controller.CaseCommentId__c=casecom.id;
                             }
                             if(schema.sObjectType.JiraCommentController__c.fields.CommentType__c.Iscreateable()){
                            controller.CommentType__c='CaseComment';
                             }
                            ControllerList.add(controller);
                            
                            CaseJiraHelper__c CJH = New CaseJiraHelper__c();
                            if(schema.sObjectType.CaseJiraHelper__c.fields.Name.Iscreateable()){
                            CJH.Name = casecom.Id;
                            }
                            if(schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.Iscreateable()){
                            CJH.jiraissueid__c = com.JiraIssue__r.name;
                            }
                            if(schema.sObjectType.CaseJiraHelper__c.fields.Type__c.Iscreateable()){
                            CJH.Type__c = 'Comment';
                            }
                            CJHelperToInsert.add(CJH);
                        }
                    }
                }
                if(!ControllerList.isEmpty() && schema.sObjectType.JiraCommentController__c.Iscreateable()){
                    insert ControllerList;
                }
                if(!CJHelperToInsert.isEmpty() && schema.sObjectType.CaseJiraHelper__c.Iscreateable()){
                    insert CJHelperToInsert;
                }
            }
            
            if(!commentsToUpdate.isEmpty() && schema.sObjectType.CaseComment.Isupdateable()){
                update commentsToUpdate;
                if(!controllerupdatelist.isEmpty() && schema.sObjectType.JiraCommentController__c.Isupdateable()){
                    update controllerupdatelist;
                }
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JiraCommentHandler',null, null, null,null,null, null , null, null, 'Jira Comment Handler', Error);
        }
    }
}