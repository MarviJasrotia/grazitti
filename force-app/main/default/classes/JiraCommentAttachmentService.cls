public class JiraCommentAttachmentService {
    
    public static   Map<String,SyncCommentsFilesToJira.WrapperClass1> SendAttachment(Attachment attach,List<ContentVersion> cvList,List<String> id ,JiraIssue__c issue,Set<id> commentattac){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        Map<String,SyncCommentsFilesToJira.WrapperClass1> SendAttachmentSuccessMap=new Map<String,SyncCommentsFilesToJira.WrapperClass1>();
        Map<String,CaseJiraHelper__c>  CjHelper=new  Map<String,CaseJiraHelper__c> ();
        Map<String,CaseJiraHelper__c>  CjHelperMap=new  Map<String,CaseJiraHelper__c> ();
        SyncCommentsFilesToJira.WrapperClass1 wrap=new SyncCommentsFilesToJira.WrapperClass1();
        String issuekey=issue.issuekey__c;
        String CvId='';
        String attachID='';
        List<ContentVersion> ConttoUpdate= new List<ContentVersion>();
        try{
            
            for(ContentVersion cv : cvList){
                CvId=cv.id;
                
                Blob file_body;
                String file_name;
                String boundary = '----------------------------741e90d31eff'; 
                String footer = '--' + boundary + '--';
                String headerEncoded;
                String header;
                String bodyEncoded;
                Blob bodyBlob;
                String last4Bytes;
                HttpResponse res;
                Http http;
                Httprequest req;
                if(Attachment.sObjectType.getDescribe().isAccessible() && ContentVersion.sObjectType.getDescribe().isAccessible()){
                    http = new Http();
                    res = new HttpResponse();
                    req = new HttpRequest();
                    file_body = null;
                    file_name = '';
                    boundary = '----------------------------741e90d31eff'; 
                    footer = '--' + boundary + '--';
                    headerEncoded = '';
                    header = '';
                    bodyEncoded = '';
                    bodyBlob = null;
                    last4Bytes = '';
                    if(attach!=null){
                        file_body = attach.Body;
                        file_name = attach.Name;
                        attachID=attach.id;
                    }else if(cv!=null){
                        file_body = cv.VersionData;
                        file_name = cv.Title+'.'+cv.FileExtension ;
                    }
                    bodyBlob = null;
                    header = '--' + boundary + '\n' +
                        'Content-Disposition: form-data; name="file"; filename="' + file_name + '";\n' +
                        'Content-Type: application/octet-stream'; 
                    headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
                    while (headerEncoded.endsWith('=')) {
                        header += ' ';
                        headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                    }
                    bodyEncoded = EncodingUtil.base64Encode(file_body);
                    last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
                    
                    if (last4Bytes.endsWith('==')) {
                        last4Bytes = last4Bytes.substring(0, 2) + '0K';
                        bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    } else if (last4Bytes.endsWith('=')) {
                        last4Bytes = last4Bytes.substring(0, 3) + 'N';
                        bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                        footer = '\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    } else {
                        footer = '\r\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
                    }
                    if(CaseJiraHelper__c.sObjectType.getDescribe().isAccessible()){
                        for(CaseJiraHelper__c cj:[select id,name,type__c,jiraissueid__c from CaseJiraHelper__c where name in:commentattac]){
                            if(Schema.sObjectType.CaseJiraHelper__c.fields.name.isAccessible()){
                                CjHelper.put(cj.name,cj); 
                            }
                        }
                    }
                    
                    
                    if(CjHelper.containsKey(CvId)) {}     
                    else{
                        req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + issueKey + '/attachments', 'POST', 'multipart/form-data; boundary=' + boundary); 
                        
                        req.setHeader('X-Atlassian-Token', 'nocheck');
                        req.setBodyAsBlob(bodyBlob);
                        req.setTimeout(120000);
                        
                        res = http.send(req);
                        
                        //if(res.getStatus() == 'OK' || res.getStatusCode() == 200) {
                          if(res.getStatusCode() == 200){  
                            List<Object> AttachmentResList = (list<Object>)JSON.deserializeUntyped(res.getbody());
                            for(Object Ob:AttachmentResList){
                                Map<String,Object> AttachmentMap =  (Map<String,Object>)Ob;
                                String AttId = String.valueof(AttachmentMap.get('id'));
                                ContentVersion con= new ContentVersion(id=cv.id);
                                con.JIRA_Attachment_Id__c =Decimal.valueOf(AttId);
                                ConttoUpdate.add(con);
                                break;
                            }  
                              
                            wrap.str='success';
                            SendAttachmentSuccessMap.put('success',wrap);
                            
                            CaseJiraHelper__c cjh= new CaseJiraHelper__c();
                            cjh.Name=CvId;
                            cjh.Type__c='Attachment';
                            cjh.jiraissueid__c=issuekey;
                            CjHelper.put(CvId,cjh);
                        } else {
                            JiraErrorLogs__c logs=new JiraErrorLogs__c();   
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isupdateable()){
                                logs.Apex_Class__c='JiraCommentAttachmentService';
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isupdateable()){
                                logs.Request_End_Point__c='/rest/api/2/issue/' + issueKey + '/Attachments';
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isUpdateable()){
                                logs.Request_Method__c='POST';
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isupdateable()){
                                logs.Response_Status__c=res.getStatus();
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isupdateable()){
                                logs.Response_Status_Code__c=String.valueOf(res.getStatuscode());
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isupdateable()){
                                logs.Request_Details__c=req.getBody();
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isupdateable()){
                                logs.Response_Details__c=res.getBody();
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isupdateable()){
                                logs.RecordId__c=cv.Id;
                            }
                            if(schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isupdateable()){
                                logs.Request_From__c='SendAttachment'; 
                            }
                         
                            wrap.log1.add(logs);
                            SendAttachmentSuccessMap.put('LOG',wrap);
                            
                        } 
                    }
                    
                }
            }
            
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
          
            wrap.str=issuekey;
            wrap.log1.add(GenerateJiraLogs.CreateJiraLog('JiraCommentAttachmentService','/rest/api/2/issue/' + issueKey + '/attachments', 'POST', null, null,null,null,null,  CvId!=''?cvId:attachID!=null?attachID:'', 'Salesforce', Error));
            SendAttachmentSuccessMap.put(issuekey,wrap);
        }
        
         if(!ConttoUpdate.isEmpty()){
            if(ContentVersion.sObjectType.getDescribe().isAccessible() &&
               ContentVersion.sObjectType.getDescribe().isupdateable() ){
                   update ConttoUpdate;
               }
        }
        if(!CjHelper.isEmpty()){
            try{
                if(schema.sObjectType.CaseJiraHelper__c.isupdateable() && schema.sObjectType.CaseJiraHelper__c.isCreateable()){
                    upsert CjHelper.values();
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraCommentAttachmentService',null, null, null,null,null, null , null, null, 'SendAttachment', Error);
                
            }
        }
        return SendAttachmentSuccessMap;
    }
    
    public static  SyncCommentsFilesToJira.WrapperClass1  SendComments(JiraIssue__c JiraKeyy,String commentId,String commentBody,string Jiracommentid,String name,String CommentSource){
        
        String cmnt;
        SyncCommentsFilesToJira.WrapperClass1 wrap=new SyncCommentsFilesToJira.WrapperClass1();
        String JiraKey=JiraKeyy.IssueKey__c;
        String JiraId=String.valueof(JiraKeyy.IssueId__c);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        
        try{
            if(JiraCommentId!=null && JiraCommentId!=''){
                
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + jirakey + '/comment/'+JiraCommentId, 'PUT', 'application/json');
            } else {
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' +  jirakey + '/comment', 'POST', 'application/json');        
            }
            if(CommentBody.contains('Created by Salesforce :')){
                req.setBody('{"body": "' + Commentbody.escapeJava() + '"}');
            } else {
                if(CommentSource!='Jira'){
                    cmnt=Commentbody+'\n (Created by Salesforce :'+name+')';
                }else{
                    cmnt=Commentbody;
                }
                String cmmnt=cmnt;
                req.setBody('{"body": "' + Cmmnt.escapeJava() + '"}'); 
            }
            req.setTimeout(120000);
            res = http.send(req);
            String issueskey='';
            if(res.getStatus() == 'Created' || res.getStatus() == 'OK' ||res.getStatusCode() == 201 ||res.getStatusCode() == 200) {
                if(res.getStatusCode() == 201){
                    JiraIssueComments__c jc= new JiraIssueComments__c(id=commentid,Comment_Added__c=true);
                    
                    if(CommentSource!='Jira'){
                        jc.source__c='Salesforce'; 
                    }
                    String ResBody=res.getbody();
                    ResBody = ResBody.replace('\n', '\\n');
                    Map<String,Object> myobjDeserialized = (Map<String,Object>) JSON.deserializeuntyped(ResBody);
                    jc.CommentId__c = (String)myobjDeserialized.get('id');
                    jc.JiraId__c=JiraId;
                    wrap.IsuueCom.put(commentId,jc);
                    return wrap;   
                }
                if(res.getStatusCode() == 200){
                    JiraIssueComments__c jc= new JiraIssueComments__c(id=commentid);
                    jc.Comment_Added__c=true;
                    String ResBody=res.getbody();
                    ResBody = ResBody.replace('\n', '\\n');
                    if(CommentSource!='Jira'){
                        jc.source__c='Salesforce'; 
                    }
                    Map<String,Object> myobjDeserialized = (Map<String,Object>) JSON.deserializeuntyped(ResBody);
                    jc.CommentId__c = (String)myobjDeserialized.get('id');
                    wrap.IsuueCom.put(commentId,jc);
                    return wrap;   
                }
            }
            else{ 
                
                JiraErrorLogs__c logs=new JiraErrorLogs__c();   
                if(schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Apex_Class__c.isupdateable()){
                    logs.Apex_Class__c='JiraCommentAttechmentService';
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_End_Point__c.isupdateable()){
                    logs.Request_End_Point__c='/rest/api/2/issue/' + jiraKey + '/comments';
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_Method__c.isUpdateable()){
                    logs.Request_Method__c='POST';
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status__c.isupdateable()){
                    logs.Response_Status__c=res.getStatus();
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Response_Status_Code__c.isupdateable()){
                    logs.Response_Status_Code__c=String.valueOf(res.getStatuscode());
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_Details__c.isupdateable()){
                    logs.Request_Details__c=req.getBody();
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Response_Details__c.isupdateable()){
                    logs.Response_Details__c=res.getBody();
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.RecordId__c.isupdateable()){
                    logs.RecordId__c=commentId;
                }
                if(schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isCreateable() && schema.sObjectType.JiraErrorLogs__c.fields.Request_From__c.isupdateable()){
                    logs.Request_From__c='SendComments';
                }
                
                wrap.log1.add(logs);
                return wrap;  
            }
            
        }catch(Exception ex) {
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            wrap.log1.add(GenerateJiraLogs.CreateJiraLog('JiraCommentAttachmentService',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'SendComments', Error));
            return wrap;  
        }  
        return null; 
    }
}