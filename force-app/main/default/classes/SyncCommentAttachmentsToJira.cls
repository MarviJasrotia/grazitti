/**
 * For cases only
* Controller for SendCommentsAttachmentCaseToJira visualforce page 
* @Grazitti
* version 1.0
* 
*/
public with sharing class SyncCommentAttachmentsToJira {
    public String lang{get;set;} 
    WrapperClass1 wrap1;
    
    List<Jiracommentcontroller__c> contlist;
    /* List of case comments 
*/
    public List<wrapperclass> commentWrapperList{get;set;}
    /*
List of case Attachment 
*/
    public List<wrapperclass> attachementWrapperList{get;set;}
    
    /*
List of Jira Issues
*/
    public List<wrapperclass> JiraWrapperList{get;set;}
    /**
* Current case 
*/
    public Case caseRecord{get;set;} 
    /**
*  decides to show/hide error section onpage
*/
    public Boolean displayError {get;set;}
    public Set<String> CommentsIdset;
    public Set<String> validAttachmentIdSet;
    public Set<String> invalidAttachmentIdSet;
    /**
* set of jira issue fethc from page parameter
*/
    public Set<String> jiraIssueSet; 
    public Map<String,CaseJiraHelper__c > CjHelper;
    public Set<id> commentattach;
    public Jira_login__c setting;
    public SyncCommentAttachmentsToJira(){}
    public Map<Id,wrapperclass> commtoJiraMap;
    public Map<Id,wrapperclass> attachtoJiraMap;
    public Id caseId{get;set;}
    public Map<String,String> ErrorInAttachment;
    public Map<String,String> ErrorInComment;
    public integer JiraContentCapacity=0;
    public list<SelectOption> Languages {get;set;}

    /**
* gets caseid from standardcontroller
* fills the jiraIssueSet from page parameter . 
* fills the commentWrapperList: fetch comments related to case.
* fills the attachementWrapperList: fetch Attachments related to case.
* @param stdandard controller from page (case).
*   
*/
    public SyncCommentAttachmentsToJira(ApexPages.StandardController controller) {
        lang=userinfo.getLanguage();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng; 
        }
        Languages = JiraService.LanguageOptions();
        ErrorInAttachment= new Map<String,String>();
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            setting = [select id, Name,License_Key__c, End_Point__c ,LoginSuccess__c
                       from Jira_login__c 
                       where name = 'JIRA'
                       Limit 1
                      ];
        }
        commentattach=new Set<id>();
        CjHelper=new  Map<String,CaseJiraHelper__c> ();
        contlist=new List<Jiracommentcontroller__c>();
        commtoJiraMap = new Map<Id,wrapperclass>();
        attachtoJiraMap = new Map<Id,wrapperclass>();
        caseId = controller.getId();
        commentWrapperList = new List<wrapperclass>();
        attachementWrapperList = new List<wrapperclass>();
        JiraWrapperList = new List<wrapperclass>();
        caseRecord = new Case(Id=caseId);
        displayError = false;      
        
        decimal sizeOfFile=0;
        decimal sizeOfFile1=0;
        JiraSalesforceDetail__c settingss1=JiraSalesforceDetail__c.getInstance('File_Size');
        String FileSize=settingss1.value__c;
        
        if(FileSize != null){
            if(FileSize.contains('MB')){
                FileSize=FileSize.remove('MB');
                sizeOfFile=decimal.valueOf(FileSize.trim());
                decimal d=(1024*1024)* sizeOfFile;
                sizeOfFile1=d;
                //string temp=string.valueOf(d);
                //sizeOfFile1=long.valueOf(temp);
            }
            else{
                FileSize=FileSize.remove('KB');  
                sizeOfFile=decimal.valueOf(FileSize.trim());
                Decimal d=1024* sizeOfFile;
                sizeOfFile1=d;
                //string temp=string.valueOf(d);
                //sizeOfFile1=long.valueOf(temp);
            }
            //String size=string.valueOf(sizeOfFile1);
            JiraContentCapacity = integer.valueOf(sizeOfFile1);
        }
        
        if(!JiraRelationship__c.sObjectType.getDescribe().isAccessible() || !CaseJiraHelper__c.sObjectType.getDescribe().isAccessible() ||
           !ContentDocumentLink.sObjectType.getDescribe().isAccessible() || !Attachment.sObjectType.getDescribe().isAccessible() ||
           !CaseComment.sObjectType.getDescribe().isAccessible() || !ContentVersion.sObjectType.getDescribe().isAccessible()){
               return;
           }
        
        for(JiraRelationship__c jiraIssueInstance: [SELECT Id, JiraIssue__c, CreatedDate, JiraIssue__r.Status__c, JiraIssue__r.IssueId__c, JiraIssue__r.IssueKey__c,JiraIssue__r.Assignee__c, JiraIssue__r.description__c, JiraIssue__r.Priority__c, CaseRelation__c FROM JiraRelationship__c where CaseRelation__c = :caseId order by createdDate]){
            if(Schema.sObjectType.JiraRelationship__c.fields.Id.isAccessible() && Schema.sObjectType.JiraRelationship__c.fields.CreatedDate.isAccessible()){
                JiraWrapperList.add(new wrapperclass(jiraIssueInstance.Id, jiraIssueInstance.JiraIssue__r.IssueKey__c, 'Issue Keys', jiraIssueInstance.CreatedDate.format('MM/dd/yyyy hh:mm a')));          
            }
        }
        for(CaseComment commentObj : [SELECT Id, CommentBody, CreatedDate,Lastmodifiedby.Name FROM CaseComment WHERE ParentId = :caseId  ORDER BY CreatedDate DESC]){
            if(CommentObj.Lastmodifiedby.Name!=null  && (CommentObj.Lastmodifiedby.Name).contains('Guest')){
            }else{
                if(Schema.sObjectType.CaseComment.fields.Id.isAccessible() && Schema.sObjectType.CaseComment.fields.CommentBody.isAccessible() &&
                   Schema.sObjectType.CaseComment.fields.CreatedDate.isAccessible()){
                       commtoJiraMap.put(commentObj.Id,new wrapperclass(commentObj.Id, commentObj.CommentBody, 'Case Comment', commentObj.CreatedDate.format('MM/dd/yyyy hh:mm a')));
                   }
                if(Schema.sObjectType.CaseComment.fields.Id.isAccessible()){
                    commentattach.add(commentObj.id);
                }
            }
        }
        
        for(Attachment attachmentObj : [SELECT Id, Name, CreatedDate, BodyLength FROM Attachment WHERE ParentId = :caseId ORDER BY CreatedDate DESC]){
            boolean SizeExceed =false;
            if(attachmentObj.BodyLength> JiraContentCapacity || attachmentObj.BodyLength>10000000){
                SizeExceed=true;
            }
            if(Schema.sObjectType.Attachment.fields.Id.isAccessible() && Schema.sObjectType.Attachment.fields.Name.isAccessible() &&
               Schema.sObjectType.Attachment.fields.CreatedDate.isAccessible() && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()){
                   attachtoJiraMap.put(attachmentObj.Id,new wrapperclass(attachmentObj.Id, attachmentObj.Name, 'Case Attachment', attachmentObj.CreatedDate.format('MM/dd/yyyy hh:mm a'),attachmentObj.BodyLength, ConvertAttachmentSize(attachmentObj.BodyLength),SizeExceed));
               }
            if(Schema.sObjectType.Attachment.fields.Id.isAccessible()){
                commentattach.add(attachmentObj.Id);
            }
        } 
        set<id>ContentDocumentIdset = new Set<id>();
        for(ContentDocumentLink cdl:[select id,ContentDocumentId from ContentDocumentLink where linkedEntityId=:caseId]){
            if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()){
                ContentDocumentIdset.add(cdl.ContentDocumentId);
            }
        }
        
        for(ContentVersion ContentVersionObj : [SELECT Id, Title, CreatedDate, ContentSize FROM ContentVersion WHERE ContentDocumentId in:ContentDocumentIdset ORDER BY CreatedDate DESC]){
            boolean SizeExceed =false;
            if(ContentVersionObj.contentSize> JiraContentCapacity || ContentVersionObj.contentSize>10000000){
                SizeExceed=true;
            }
            if(Schema.sObjectType.ContentVersion.fields.Id.isAccessible() && Schema.sObjectType.ContentVersion.fields.Title.isAccessible() &&
               Schema.sObjectType.ContentVersion.fields.CreatedDate.isAccessible() && Schema.sObjectType.ContentVersion.fields.ContentSize.isAccessible()){
                   attachtoJiraMap.put(ContentVersionObj.Id,new wrapperclass(ContentVersionObj.Id, ContentVersionObj.Title, 'Case Attachment', ContentVersionObj.CreatedDate.format('MM/dd/yyyy hh:mm a'),ContentVersionObj.ContentSize, ConvertAttachmentSize(ContentVersionObj.ContentSize),SizeExceed));
               }
            if(Schema.sObjectType.ContentVersion.fields.Id.isAccessible()){
                commentattach.add(ContentVersionObj.Id);
            }
        } 
        string AssignedToTemp ='';
        String assignedComm='';
        for(CaseJiraHelper__c cj:[select id,name,type__c,jiraissueid__c from CaseJiraHelper__c where name in:commentattach]){
            if(Schema.sObjectType.CaseJiraHelper__c.fields.name.isAccessible()){
                CjHelper.put(cj.name,cj); 
            }
            if(commtoJiraMap.get(cj.name) != null){
                assignedComm = cj.jiraissueid__c;
                string synJiraId = '';
                for(string jk : assignedComm.split(';')){
                    synJiraId += '<span id="'+cj.name+'_'+jk+'">'+jk+'</span>,';
                }
                commtoJiraMap.get(cj.name).jiraKeys = synJiraId.removeEnd(',');
            }
            if(attachtoJiraMap.get(cj.name) != null){
                AssignedToTemp = cj.jiraissueid__c;
                string AttachSynJiraId = '';
                for(string AJK : AssignedToTemp.split(';')){
                    AttachSynJiraId += '<span id="'+cj.name+'_'+AJK+'">'+AJK+'</span>,';
                }                
                attachtoJiraMap.get(cj.name).jiraKeys = AttachSynJiraId.removeEnd(',');
            }
            
        }
        
        commentWrapperList = commtoJiraMap.values();
        attachementWrapperList = attachtoJiraMap.values();
    }
    
    /**
* checks the licence limit
* update value for total Sync limit.  
*/
    public PageReference SendReqToJIRA(){
        jiraIssueSet = new Set<String>();
        
        if(!setting.LoginSuccess__c){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,System.label.SyncCommentsAttachmentsToJiraclass_Label1);
            ApexPages.addMessage(msg);
            displayError = true;
            return null;
        }
        
        for(wrapperclass wrapper : JiraWrapperList){
            
            if(wrapper.isSelected == true && wrapper.recordType == 'Issue Keys'){
                jiraIssueSet.add(wrapper.recordBody);
            }
        } 
        if(jiraIssueSet.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.label.SyncCommentsAttachmentsToJiraclass_Label2));
        }else{  
            try{
                displayError = false;
                integer syncItemsNo = 0;
                syncItemsNo =syncAttachment(syncItemsNo);
                syncItemsNo=syncCommnets(syncItemsNo);
                
                
                if(!CjHelper.isEmpty() && Schema.sObjectType.CaseJiraHelper__c.isUpdateable() 
                   && Schema.sObjectType.CaseJiraHelper__c.isCreateable()){
                       upsert CjHelper.values();
                   }
                if(!contlist.isEmpty() &&  Schema.sObjectType.JiraCommentController__c.isCreateable()){
                    insert contlist;
                }
                return new PageReference('/'+caseId);
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('SyncCommentAttachmentsToJira',null, null, null,null,null, null , null, null, 'RequestToJira', Error);
            }
        }
        
        
        
        return null;
    }
    
    /** 
* intermediate method between SendReqToJIRA() and SendAttachment()
* @param syncItemsNo count the total calls for jira service 
* @return syncItemsNo 
*/
    public Integer syncAttachment(Integer syncItemsNo){
        validAttachmentIdSet = new Set<String>();
        invalidAttachmentIdSet = new Set<String>();
        for(wrapperclass wrapper : attachementWrapperList){ 
            if(wrapper.isSelected == true && wrapper.recordType == 'Case Attachment'){
                if(wrapper.recordSize <= 10000000 && wrapper.recordSize<=JiraContentCapacity){
                    validAttachmentIdSet.add(wrapper.recordId);
                    syncItemsNo = syncItemsNo + 1;
                }else{
                    invalidAttachmentIdSet.add(wrapper.recordId);
                    
                }                    
            }
        }
        if(!validAttachmentIdSet.isEmpty() && invalidAttachmentIdSet.isEmpty()){
            SendAttachment(validAttachmentIdSet);
        }
        if(!invalidAttachmentIdSet.isEmpty()){
            for(Attachment attach : [SELECT Id, Name, Body FROM Attachment WHERE Id IN :invalidAttachmentIdSet]){
                displayError = true;
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, System.label.SyncCommentsAttachmentsToJiraclass_Label3  +attach.Name);
                ApexPages.addMessage(msg);
            }  
            for(ContentVersion  attach : [SELECT Id, Title FROM ContentVersion WHERE Id IN :invalidAttachmentIdSet]){
                displayError = true;
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, System.label.SyncCommentsAttachmentsToJiraclass_Label3 +attach.Title);
                ApexPages.addMessage(msg);
            }  
        }  
        return syncItemsNo;
    } 
    
    /** 
* intermediate method between SendReqToJIRA() and sendComment()
* @param syncItemsNo count the total calls for jira service 
* @return syncItemsNo
*/
    public Integer syncCommnets(Integer syncItemsNo){
        CommentsIdset=new Set<String>();
        for(wrapperclass wrapper : commentWrapperList){ 
            
            if(wrapper.isSelected == true && wrapper.recordType == 'Case Comment'){
                if(invalidAttachmentIdSet.isEmpty()){
                    CommentsIdset.add(wrapper.recordId);
                    //SendComment(wrapper.recordBody,wrapper.recordId);
                    syncItemsNo = syncItemsNo + 1;
                }                
            }
        }
        if(!CommentsIdset.isempty())
            SendComment(CommentsIdset);
        return syncItemsNo;
    }
    
    /**
* Sends comments to jira with help of jiraserivce class
* @param syncItemsNo count the total calls for jira service 
* @return syncItemsNo
*/
    /*public void SendComment(String commentBody,String recId){
try{

set<String> jiraIssuekeySet =new Set<String>();
jiraIssuekeySet.addAll(jiraIssueSet);
boolean allow = false;
integer callOutUsed = 0;
commentBody = commentBody+'\n (Created by Salesforce : '+Userinfo.getName()+')';

if(CjHelper.containsKey(recId)){
List<String> oldjiraissues=new List<String>();
if(CjHelper.get(recId).jiraissueid__c!=Null){
oldjiraissues =CjHelper.get(recId).jiraissueid__c.split(';');
for(String oj:oldjiraissues ){
if(jiraIssuekeySet.contains(oj)){
jiraIssuekeySet.remove(oj);
} 
}
}

}

for(String issueKey : jiraIssuekeySet){
String response=  JiraService.SendComments(issueKey,commentBody);
if(response=='success'){
if(CjHelper.containsKey(recId)){
CjHelper.get(recId).jiraissueid__c=CjHelper.get(recId).jiraissueid__c+';'+issueKey;
}else{
CaseJiraHelper__c cjh= new CaseJiraHelper__c();
if(schema.sObjectType.CaseJiraHelper__c.fields.Name.isUpdateable() &&
schema.sObjectType.CaseJiraHelper__c.fields.Name.isCreateable() ){
cjh.Name=recId;
}
if(schema.sObjectType.CaseJiraHelper__c.fields.Type__c.isUpdateable() &&
schema.sObjectType.CaseJiraHelper__c.fields.Type__c.isCreateable() ){
cjh.Type__c='Comment';
}
if(schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isUpdateable() &&
schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isCreateable() ){
cjh.jiraissueid__c=issueKey;
}
CjHelper.put(recId,cjh);
}
ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'Success!!');
ApexPages.addMessage(msg);
}else{
if(response=='LIMIT'){
ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Your free Sync limit is over. Please contact info@grazitti.com for increasing Limit');
ApexPages.addMessage(msg);
}else{

}
}   

}

}catch(Exception ex){
String Error='Cause: '+ex.getCause()+'\n'+'LineNumber: '+ex.getLineNumber()+'\n'+'Message: '+ex.getMessage();
GenerateJiraLogs.CreateLogRealTime('SyncCommentAttachmentsToJira',null, null, null,null,null, null , null, null, 'SendComment', Error);
displayError = true;
ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Request could not be completed');
ApexPages.addMessage(msg);
}
}*/
    
    
    public void SendComment(Set<String> CommentsIdSet){
        try{
            Wrap1=new Wrapperclass1();
            
            List<CaseComment> CaseComList=[Select id,ParentId,CommentBody,LastModifiedBy.Name from CaseComment where id in:CommentsIdSet];
            Map<ID,Set<String>> comTojiraIssue=new Map<ID,Set<String>>();
            Map<string,String> JirakeyIssueIdMap =new Map<string,String>();
            for(JiraIssue__c ji:[select name,IssueId__c from JiraIssue__c where name in:jiraIssueSet]){
                if(!JirakeyIssueIdMap.containskey(ji.name))
                    JirakeyIssueIdMap.put(ji.name,String.valueof(ji.IssueId__c));
            }
            for(CaseComment com:CaseComList){
                set<String> jiraIssuekeySet =new Set<String>();
                jiraIssuekeySet.addAll(jiraIssueSet);
                if(!(com.LastModifiedBy.Name).contains('Guest')){
                    if(CjHelper.containsKey(com.id)){
                        
                        if(CjHelper.get(com.id).jiraissueid__c!=Null){
                            List<String> oldjiraissues =CjHelper.get(com.id).jiraissueid__c.split(';');
                            for(String oj:oldjiraissues ){
                                if(jiraIssuekeySet.contains(oj)){
                                    jiraIssuekeySet.remove(oj);
                                }
                            }
                            if(!comTojiraIssue.containsKey(com.Id)){
                                comTojiraIssue.put(com.id,jiraIssuekeySet);
                            }
                        }
                    }else{
                        if(!comTojiraIssue.containsKey(com.Id)){
                            comTojiraIssue.put(com.id,jiraIssuekeySet);
                        }
                    }
                }
            }
            
            Wrap1 =JiraService.SendComments(CaseComList,comTojiraIssue,JirakeyIssueIdMap);
            Map<String,String> responseMap=Wrap1.isuuecom;
            contlist.addall(wrap1.controllerlist);
            for(String response:responseMap.keyset()){
                if(responseMap.get(response)=='Success'){
                    List<String> responsedata= response.split('_');
                    if(CjHelper.containsKey(responsedata[0])){
                        if(schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isUpdateable()){
                            CjHelper.get(responsedata[0]).jiraissueid__c=CjHelper.get(responsedata[0]).jiraissueid__c+';'+responsedata[1];
                        }
                    }else{
                        CaseJiraHelper__c cjh= new CaseJiraHelper__c();
                        if(schema.sObjectType.CaseJiraHelper__c.fields.Name.isUpdateable() &&
                           schema.sObjectType.CaseJiraHelper__c.fields.Name.isCreateable() ){
                               cjh.Name=responsedata[0];
                           }
                        if(schema.sObjectType.CaseJiraHelper__c.fields.Type__c.isUpdateable() &&
                           schema.sObjectType.CaseJiraHelper__c.fields.Type__c.isCreateable() ){
                               cjh.Type__c='Comment';
                           }
                        if(schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isUpdateable() &&
                           schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isCreateable() ){
                               cjh.jiraissueid__c=responsedata[1];
                           }
                        CjHelper.put(responsedata[0],cjh);
                    }
                }
            }
            
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SyncCommentAttachmentsToJira',null, null, null,null,null, null , null, null, 'SendComment', Error);
            displayError = true;
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Request could not be completed');
            ApexPages.addMessage(msg);
        }
    }
    
    /**
* Sends attachment to jira with help of jiraserivce class
* @param syncItemsNo count the total calls for jira service 
* @return syncItemsNo
*/
    public void SendAttachment(Set<String> attachmntIdSet){
        try{
            
            
            List<Attachment> attachmentList = [SELECT Id, Name, Body FROM Attachment WHERE Id = :attachmntIdSet];
            
            List<ContentVersion > ContentList = [SELECT Id, VersionNumber, ContentBodyId, VersionData, FileExtension, FileType, Title, Description, FirstPublishLocationId FROM ContentVersion WHERE Id = :attachmntIdSet];
            
            
            
            //for attachment object
            
            Map<ID,Set<String>> attachmentTojiraIssue=new Map<ID,Set<String>>();
            
            for(Attachment attch:attachmentList){
                set<String> jiraIssuekeySet =new Set<String>();
                jiraIssuekeySet.addAll(jiraIssueSet);
                if(CjHelper.containsKey(attch.id)){
                    
                    if(CjHelper.get(attch.id).jiraissueid__c!=Null){
                        List<String> oldjiraissues =CjHelper.get(attch.id).jiraissueid__c.split(';');
                        for(String oj:oldjiraissues ){
                            if(jiraIssuekeySet.contains(oj)){
                                jiraIssuekeySet.remove(oj);
                            }
                        }
                        if(!attachmentTojiraIssue.containsKey(attch.Id)){
                            attachmentTojiraIssue.put(attch.id,jiraIssuekeySet);
                        }
                    }
                }else{
                    if(!attachmentTojiraIssue.containsKey(attch.Id)){
                        attachmentTojiraIssue.put(attch.id,jiraIssuekeySet);
                    }
                }
            }
            for(ContentVersion attch:ContentList){
                set<String> jiraIssuekeySet =new Set<String>();
                jiraIssuekeySet.addAll(jiraIssueSet);
                if(CjHelper.containsKey(attch.id)){
                    if(CjHelper.get(attch.id).jiraissueid__c!=Null){
                        List<String> oldjiraissues =CjHelper.get(attch.id).jiraissueid__c.split(';');
                        for(String oj:oldjiraissues ){
                            if(jiraIssuekeySet.contains(oj)){
                                jiraIssuekeySet.remove(oj);
                            }
                        }
                        if(!attachmentTojiraIssue.containsKey(attch.Id)){
                            attachmentTojiraIssue.put(attch.id,jiraIssuekeySet);
                        }
                    }
                }else{
                    if(!attachmentTojiraIssue.containsKey(attch.Id)){
                        attachmentTojiraIssue.put(attch.id,jiraIssuekeySet);
                    }
                }
            }
            
            Map<String,String> responseMap= JiraService.SendAttachment(attachmentList,ContentList,attachmentTojiraIssue);
            
            
            for(string response : responseMap.keySet()){ 
                if(responseMap.get(response)=='Succcess'){
                    List<String> responsedata= response.split('_');
                    if(CjHelper.containsKey(responsedata[0])){
                        if(schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isUpdateable()){
                            CjHelper.get(responsedata[0]).jiraissueid__c=CjHelper.get(responsedata[0]).jiraissueid__c+';'+responsedata[1];
                        }
                    }else{
                        CaseJiraHelper__c cjh= new CaseJiraHelper__c();
                        if(schema.sObjectType.CaseJiraHelper__c.fields.Name.isUpdateable() &&
                           schema.sObjectType.CaseJiraHelper__c.fields.Name.isCreateable() ){
                               cjh.Name=responsedata[0];
                           }
                        if(schema.sObjectType.CaseJiraHelper__c.fields.Type__c.isUpdateable() &&
                           schema.sObjectType.CaseJiraHelper__c.fields.Type__c.isCreateable() ){
                               cjh.Type__c='Attachment';
                           }
                        if(schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isUpdateable() &&
                           schema.sObjectType.CaseJiraHelper__c.fields.jiraissueid__c.isCreateable() ){
                               cjh.jiraissueid__c=responsedata[1];
                           }
                        CjHelper.put(responsedata[0],cjh);
                    }
                }
                
            }
            
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'Success!!');
            ApexPages.addMessage(msg);
            
            
        }catch(Exception ex){
            String Error='Cause: '+ex.getCause()+'\n'+'LineNumber: '+ex.getLineNumber()+'\n'+'Message: '+ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SyncCommentAttachmentsToJira',null, null, null,null,null, null , null, null, 'SendAttachment', Error);
            displayError = true;
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex+' Request could not be completed');
            ApexPages.addMessage(msg);
        }
    }
    
    
    /**
* A wrapper class to hold case comment and attachment details
*/
    public class Wrapperclass{
        public String recordId{get;set;}
        public String recordBody{get;set;}
        public Boolean isSelected{get;set;}
        public String recordType{get;set;}
        public String recordDate{get;set;}
        public Integer recordSize{get;set;}
        public String recordSizeInString{get;set;}
        public string jiraKeys{get;set;}
        public Boolean recordSizeExceed{get;set;}
        
        public wrapperclass(String recId, String recBody, String recType, String recDate){        
            recordId = recId;
            recordBody = recBody;
            recordType = recType;
            recordDate = recDate;
            jiraKeys = '';
        }
        
        public wrapperclass(String recId, String recBody, String recType, String recDate, Integer recSize, String recSizeInString,Boolean recSizeExceed){        
            recordId = recId;
            recordBody = recBody;
            recordType = recType;
            recordDate = recDate;
            recordSize = recSize;
            recordSizeInString = recSizeInString;
            jiraKeys='';
            recordSizeExceed=recSizeExceed;
        }
    }
    
    public class WrapperClass1{
        public Map<String,String> isuuecom=new Map<String,String>();  
        public List<JiraCommentController__c> controllerlist=new List<JiraCommentController__c>();
        //public String str='';
    }
    /**
* redirects to case detail page 
*/
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/' + caseRecord.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public String ConvertAttachmentSize(Integer aSize){
        
        String convertedSize = '';
        
        Decimal fileSize = (Decimal)aSize;
        
        if(fileSize < 1024){
            convertedSize = fileSize + ' Bytes';
        }else if(fileSize >= 1024 && fileSize < (1024*1024)){
            fileSize = fileSize.divide(1024,2);
            convertedSize = fileSize + ' KB';
        }else if(fileSize >= (1024*1024) && fileSize < (1024*1024*1024)){
            fileSize = fileSize.divide((1024*1024),2);
            convertedSize = fileSize + ' MB';
        }        
        return convertedSize;
    }
    
    Public PageReference LangaugeReset(){
        String parameter='?';
        Boolean HasLang=false;
        String recordid=ApexPages.currentPage().getParameters().get('id')!=null?ApexPages.currentPage().getParameters().get('id'):'';
        
        String urllink=Apexpages.currentPage().getUrl();
        if(urllink.contains('?')){
            urllink=urllink.substring(0,urllink.lastIndexOf('?'));
          
        }
        
        if(recordid!=''){
            parameter+='id='+recordid+'&';
        }
        parameter+='lg='+lang;
        
        urllink=urllink+parameter;
      
        return new pageReference(urllink);
    }
}