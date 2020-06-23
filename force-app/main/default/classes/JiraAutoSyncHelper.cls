public with sharing class JiraAutoSyncHelper {
    
    public static String attachFileName(String CaseNumber, Datetime createdDate, String Name){
        String createDate = createdDate.format('yyyyMMddhhmm');
        String fileName = CaseNumber+'_'+createDate+'_'+Name;
        return fileName;
    }
    
    @future (callout=true) 
    public static void SendAttachment(Set<Id> attach ){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        set<Id> parentattach = new set<Id>();
        Map<Id,Id> casetoAttach = new Map<Id,Id>();
        Map<Id,Attachment> attachidtoAttach = new Map<Id,Attachment>();
        Map<Id,List<String>> casetoJira = new Map<Id,List<String>>();
        Map<Id,List<String>> attachtoJira = new Map<Id,List<String>>();
        Map<Id,integer> AttachsizeMap = new Map<Id,integer>();
        List<Attachment> att = new List<Attachment>();
        if(Attachment.sObjectType.getDescribe().isAccessible()){
            att=[SELECT id, Name, Body, CreatedDate, ParentId,BodyLength, Parent.Name FROM Attachment WHERE id IN:attach];
        }
        
        decimal sizeOfFile=0;
        decimal sizeOfFile1=0;
        JiraSalesforceDetail__c settingss1=JiraSalesforceDetail__c.getInstance('File_Size');
        String FileSize=settingss1.value__c;
        
        IF(FileSize.contains('MB')){
            FileSize=FileSize.remove('MB');
            sizeOfFile=decimal.valueOf(FileSize.trim());
            decimal d=(1024*1024)* sizeOfFile;
            
            sizeOfFile1=d;
        }ELSE{
            FileSize=FileSize.remove('KB');  
            sizeOfFile=decimal.valueOf(FileSize.trim());
            Decimal d=1024* sizeOfFile;
            
            sizeOfFile1=d;
        }
        
        for(Attachment attchcaseid:att){
            if(Schema.sObjectType.Attachment.fields.ParentId.isAccessible()){
                parentattach.add(attchcaseid.ParentId);
            }
            if(Schema.sObjectType.Attachment.fields.Id.isAccessible()){
                attachidtoAttach.put(attchcaseid.Id,attchcaseid);
            }
            if(Schema.sObjectType.Attachment.fields.Id.isAccessible() && Schema.sObjectType.Attachment.fields.ParentId.isAccessible()){
                casetoAttach.put(attchcaseid.Id,attchcaseid.ParentId);
            }
            if(Schema.sObjectType.Attachment.fields.Id.isAccessible() && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()){
                AttachsizeMap.put(attchcaseid.Id,attchcaseid.BodyLength);
            }
        }
        if(!parentattach.isEmpty()){
            
            Map<String,Schema.SObjectType> SchemaMap=Schema.getGlobalDescribe();
            Boolean caselookupExist=false;
            String fieldName='';
            String query='';
            //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
            if(SchemaMap.ContainsKey('JiraRelationship__c')){
                //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                Map<String,Schema.SObjectField> SchemaField=SchemaMap.get('JiraRelationship__c').getDescribe().Fields.getMap(); 
                for(String field : SchemaField.keySet()){
                    if(field.contains('case') || field.contains('Case')){
                        
                        String RelationFieldName=field;
                        if(RelationFieldName.contains('Grz_Sf__')) {
                            RelationFieldName=RelationFieldName.remove('Grz_Sf__');
                        }
                        if(RelationFieldName.containsIgnoreCase('__c')){
                            RelationFieldName= RelationFieldName.substringBeforeLast('__c');
                        }  
                        
                        if(RelationFieldName.contains('__'))RelationFieldName=RelationFieldName.substring(RelationFieldName.indexof('__')+2,RelationFieldName.length() );
                        
                        if(field!=NULL && field.contains(RelationFieldName)){
                            
                            caselookupExist=true;
                            fieldName=field;
                        }
                    }
                }
            }
            
            
            if((caselookupExist) &&  fieldName!='')
                query='SELECT id ,Name,JiraIssue__c,JiraIssue__r.IssueKey__c, JiraIssueId__c, Jira_Issue_Link__c,'+ fieldName +' FROM JiraRelationship__c WHERE '+ fieldName + ' IN : parentattach' ; 
            
            
            
            List<JiraRelationship__c> jiraIssuewithCase=new List<JiraRelationship__c>();
            
            if(query!='' && fieldName!='' && fieldName!=NULL && JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
                jiraIssuewithCase = DataBase.query(query);
                
                if(jiraIssuewithCase.size()>0 && jiraIssuewithCase!=NULL){
                    for(JiraRelationship__c jiraKey:jiraIssuewithCase){
                        ID caseID=(ID)jiraKey.get(fieldName);
                        if(caseID!=NULL){
                            if(casetoJira.containsKey(caseID)){
                                casetoJira.get(caseID).add(jiraKey.JiraIssue__r.IssueKey__c);
                            }else{
                                casetoJira.put(caseID,new List<String>{jiraKey.JiraIssue__r.IssueKey__c});
                            }
                        }
                    }
                }
            }
        }
        
        for(Id casejira:casetoAttach.keyset()){
            attachtoJira.put(casejira,casetoJira.get(casetoAttach.get(casejira)));
        }
        Map<Id,CaseJiraHelper__c> cjhelperMap = new Map<Id,CaseJiraHelper__c>();
        List<CaseJiraHelper__c> cj = new List<CaseJiraHelper__c>();
        if(CaseJiraHelper__c.sObjectType.getDescribe().isAccessible()){
            cj=[SELECT id, Name, Type__c, jiraissueid__c FROM CaseJiraHelper__c WHERE Name IN:attach];
        }
        for(CaseJiraHelper__c cjh:cj){
            if(Schema.sObjectType.CaseJiraHelper__c.fields.Name.isAccessible()){
                cjhelperMap.put(cjh.Name,cjh);
            }
        }
        integer count=0;
        
        for(Id attachJira:attachtoJira.keyset()){
            if(AttachsizeMap.get(attachJira)<=integer.valueof(sizeOfFile1) && AttachsizeMap.get(attachJira)<=10000000){
                for(String jiraIssues:attachtoJira.get(attachJira)){
                    try{
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
                        if(Attachment.sObjectType.getDescribe().isAccessible() ){
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
                            
                            file_body = attachidtoAttach.get(attachJira).Body;
                            file_name = attachFileName(attachidtoAttach.get(attachJira).Parent.Name,attachidtoAttach.get(attachJira).CreatedDate,attachidtoAttach.get(attachJira).Name);
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
                            
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + jiraIssues + '/attachments', 'POST', 'multipart/form-data; boundary=' + boundary);
                            req.setHeader('X-Atlassian-Token', 'nocheck');
                            req.setBodyAsBlob(bodyBlob);
                            req.setTimeout(120000);
                            count++;
                            res = http.send(req);
                            String issueskey='';
                            // if(res.getStatus() == 'OK' || res.getStatusCode() == 200){
                            if(res.getStatusCode() == 200){
                                if(cjhelperMap.containsKey(attachJira)){
                                    if(cjhelperMap.get(attachJira).jiraissueid__c!=Null){
                                        issueskey+=jiraIssues +';';
                                        cjhelperMap.get(attachJira).jiraissueid__c=cjhelperMap.get(attachJira).jiraissueid__c+issueskey;
                                    }
                                }
                                else{
                                    issueskey+=jiraIssues +';';
                                    CaseJiraHelper__c cjhelp = new CaseJiraHelper__c ();
                                    cjhelp.Name = attachJira;
                                    cjhelp.Type__c='Attachment';
                                    cjhelp.jiraissueid__c = issueskey;
                                    cjhelperMap.put(attachJira,cjhelp);
                                }
                            }else{
                                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, jiraIssues, 'Send Attachment', res.getbody()));   
                                
                            }          
                        }           
                        
                    }catch(Exception ex){
                        String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',null ,null, null, null , null, null, null, jiraIssues, 'Send Attachment', Error));
                    }
                }
            }
        }
        if(!cjhelperMap.isEmpty()){
            try{
                if(schema.sObjectType.CaseJiraHelper__c.isUpdateable() && schema.sObjectType.CaseJiraHelper__c.isCreateable()){
                    upsert cjhelperMap.values();
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraAutoSyncHelper',null ,null, null, null , null, null, null, null, 'Send Attachment', Error);
            }
        }
        
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
    
    @future (callout=true)
    public static void SendComments(Set<Id> caseComm){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        set<Id> parentCaseIds = new set<Id>();
        Map<Id,Id> caseCommentoCase = new Map<Id,Id>();
        Map<Id,CaseComment> IdtoCaseComment = new Map<Id,CaseComment>();
        Map<Id,List<String>> casetoJira = new Map<Id,List<String>>();
        Map<String,String> JiraKeyIdMap=new Map<String,String>();
        Map<Id,List<String>> attachtoJira = new Map<Id,List<String>>();
        List<CaseComment> com = new List<CaseComment>();
        if(CaseComment.sObjectType.getDescribe().isAccessible()){
            com=[SELECT Id, ParentId, CommentBody FROM CaseComment WHERE Id IN:caseComm];
        }
        for(CaseComment caseComId:com){
            parentCaseIds.add(caseComId.ParentId);
            IdtoCaseComment.put(caseComId.Id,caseComId);
            caseCommentoCase.put(caseComId.Id,caseComId.ParentId);
        }
        if(!parentCaseIds.isEmpty()){
            
            Map<String,Schema.SObjectType> SchemaMap=Schema.getGlobalDescribe();
            Boolean caselookupExist=false;
            String fieldName='';
            String query='';
            //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
            if(SchemaMap.ContainsKey('JiraRelationship__c')){
                //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                Map<String,Schema.SObjectField> SchemaField=SchemaMap.get('JiraRelationship__c').getDescribe().Fields.getMap(); 
                for(String field : SchemaField.keySet()){
                    if(field.contains('case') || field.contains('Case')){
                        
                        String RelationFieldName=field;
                        if(RelationFieldName.contains('Grz_Sf__')) {
                            RelationFieldName=RelationFieldName.remove('Grz_Sf__');
                        }
                        if(RelationFieldName.containsIgnoreCase('__c')){
                            RelationFieldName= RelationFieldName.substringBeforeLast('__c');
                        }  
                        
                        if(RelationFieldName.contains('__'))RelationFieldName=RelationFieldName.substring(RelationFieldName.indexof('__')+2,RelationFieldName.length() );
                        
                        if(field!=NULL && field.contains(RelationFieldName)){
                            
                            caselookupExist=true;
                            fieldName=field;
                        }
                    }
                }
            }
            
            
            if((caselookupExist) &&  fieldName!='')
                query='SELECT id ,Name,JiraIssue__c,JiraIssue__r.IssueKey__c, JiraIssueId__c, Jira_Issue_Link__c,'+ fieldName +' FROM JiraRelationship__c WHERE '+ fieldName + ' IN : parentCaseIds' ; 
            
            
            List<JiraRelationship__c> jiraIssuewithCase=new List<JiraRelationship__c>();
            if(query!='' && fieldName!='' && fieldName!=NULL && JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
                jiraIssuewithCase = DataBase.query(query);
                
                if(jiraIssuewithCase.size()>0 && jiraIssuewithCase!=NULL){
                    
                    for(JiraRelationship__c jiraKey:jiraIssuewithCase){
                        ID caseID=(ID)jiraKey.get(fieldName);
                        if(caseID!=NULL){
                            
                            if(casetoJira.containsKey(caseID)){
                                casetoJira.get(caseID).add(jiraKey.JiraIssue__r.IssueKey__c);
                            }else{
                                casetoJira.put(caseID,new List<String>{jiraKey.JiraIssue__r.IssueKey__c});
                            }
                            
                            if(!JiraKeyIdMap.Containskey(jiraKey.JiraIssue__r.IssueKey__c)){
                                JiraKeyIdMap.put(jiraKey.JiraIssue__r.IssueKey__c,String.valueof(jirakey.JiraIssueId__c));
                            }
                            
                        }
                    }
                }
            }
        }
        
        if(!casetoJira.ISEmpty()){
            for(Id casejira:caseCommentoCase.keyset()){
                attachtoJira.put(casejira,casetoJira.get(caseCommentoCase.get(casejira)));
            }
        }
        Map<Id,CaseJiraHelper__c> cjhelperMap = new Map<Id,CaseJiraHelper__c>();
        List<CaseJiraHelper__c> cj = new List<CaseJiraHelper__c>(); 
        List<JiraCommentController__c> ComController = new List<JiraCommentController__c>();
        if(CaseJiraHelper__c.sObjectType.getDescribe().isAccessible()){
            cj=[SELECT id, Name, Type__c, jiraissueid__c FROM CaseJiraHelper__c WHERE Name IN:caseComm];
        }
        for(CaseJiraHelper__c cjh:cj){
            if(Schema.sObjectType.CaseJiraHelper__c.fields.Name.isAccessible()){
                cjhelperMap.put(cjh.Name,cjh);
            }
        }
        Integer Count=0;
        for(Id attachJira:attachtoJira.keyset()){
            for(String jiraIssues:attachtoJira.get(attachJira)){
                String name='';
                if(cjhelperMap.containsKey(attachJira))
                    name=cjhelperMap.get(attachJira).Name;
                
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                String combody=IdtoCaseComment.get(attachJira).commentBody+'\n (Created by Salesforce :'+Userinfo.getName()+')';
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + jiraIssues + '/comment', 'POST', 'application/json');
                // req.setBody('{"body": "' + IdtoCaseComment.get(attachJira).commentBody.escapeJava() + ' \\n (Created by Salesforce :'+UserInfo.getName()+')"} ');
                req.setBody('{"body":"'+combody.escapeJava()+'"}');
                req.setTimeout(120000);
                try{
                    res = http.send(req);
                    String issueskey='';
                    if(res.getStatus() == 'Created' || res.getStatusCode() == 201){   
                        if(cjhelperMap.containsKey(attachJira)){
                            if(cjhelperMap.get(attachJira).jiraissueid__c!=Null){
                                issueskey+=jiraIssues +';';
                                cjhelperMap.get(attachJira).jiraissueid__c=cjhelperMap.get(attachJira).jiraissueid__c+issueskey;
                            }
                        }
                        else{
                            issueskey+=jiraIssues +';';
                            CaseJiraHelper__c cjhelp = new CaseJiraHelper__c ();
                            cjhelp.Name = attachJira;
                            cjhelp.Type__c='Comment';
                            cjhelp.jiraissueid__c = issueskey;
                            cjhelperMap.put(attachJira,cjhelp);
                        }  
                        JiraCommentController__c jicom=new JiraCommentController__c();
                        
                        String ResBody=res.getbody();
                        
                        ResBody = ResBody.replace('\n', '\\n');
                        Map<String,Object> myobjDeserialized = (Map<String,Object>) JSON.deserializeuntyped(ResBody);
                        if(schema.sObjectType.JiraCommentController__c.fields.CommentId__c.isCreateable()){
                            jicom.CommentId__c = (String)myobjDeserialized.get('id');
                        }
                        if(schema.sObjectType.JiraCommentController__c.fields.CaseCommentId__c.isCreateable() ){
                            jicom.CaseCommentId__c=attachJira ;
                        }
                        if(schema.sObjectType.JiraCommentController__c.fields.JiraIssueId__c.isCreateable()){
                            jicom.JiraIssueId__c=JiraKeyIdMap.get(JiraIssues);
                        }
                        if(schema.sObjectType.JiraCommentController__c.fields.CommentType__c.isCreateable()){
                            jicom.CommentType__c='CaseComment';
                        }
                        ComController.add(jicom);
                    }else{
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(),null , jiraIssues, 'Send Comments', res.getBody()));
                        
                    }      
                    Count++;
                }catch(Exception ex){
                    String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                    JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(),  req.getbody(),null , jiraIssues, 'Send Comments', Error));
                    
                }
            }
            
        }
        
        if(!cjhelperMap.isEmpty()){
            try{
                if(schema.sObjectType.CaseJiraHelper__c.isUpdateable() && schema.sObjectType.CaseJiraHelper__c.isCreateable()){
                    upsert cjhelperMap.values();
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraAutoSyncHelper',null, null, null,null,null, null , null, null, 'Send Comments', Error);
            }
        }
        if(!ComController.isEmpty()){
            try{
                if(schema.sObjectType.JiraCommentController__c.isCreateable()){
                    insert ComController;
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraAutoSyncHelper',null, null, null,null,null, null , null, null, 'Send Comments', Error);
            }
        }
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
    
  /*  @future (callout=true)
    public static void SendFilesToJira(Set<id> linkedCaseid, Set<id> FinalVersion){
        Integer count=0;
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        Map<Id,List<String>> caseToJira =new Map<id,List<String>>();
        List<ContentVersion> Content=new  List<ContentVersion>();
        if(!linkedCaseid.isEmpty() && JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
            for(JiraRelationship__c jiraKey: [SELECT Id, Name, CaseRelation__c,JiraIssue__c,JiraIssue__r.IssueKey__c, JiraIssueId__c, Jira_Issue_Link__c FROM JiraRelationship__c WHERE CaseRelation__c IN:linkedCaseid]){
                if(caseToJira.containsKey(jiraKey.CaseRelation__c)){
                    caseToJira.get(jiraKey.CaseRelation__c).add(jiraKey.JiraIssue__r.IssueKey__c);
                }else{
                    caseToJira.put(jiraKey.CaseRelation__c,new List<String>{jiraKey.JiraIssue__r.IssueKey__c});
                }
            }
        }
        if(!FinalVersion.isEmpty() && ContentVersion.sObjectType.getDescribe().isAccessible()){
            
            Content=[SELECT Id, Title, FileExtension, VersionData,ContentSize FROM ContentVersion where id in:FinalVersion];
            
        }
        Map<Id,CaseJiraHelper__c> cjhelperMap = new Map<Id,CaseJiraHelper__c>();
        List<CaseJiraHelper__c> cj = new List<CaseJiraHelper__c>(); 
        if(CaseJiraHelper__c.sObjectType.getDescribe().isAccessible()){
            cj=[SELECT id, Name, Type__c, jiraissueid__c FROM CaseJiraHelper__c WHERE Name IN:FinalVersion];
        }
        for(CaseJiraHelper__c cjh:cj){
            if(Schema.sObjectType.CaseJiraHelper__c.fields.Name.isAccessible()){
                cjhelperMap.put(cjh.Name,cjh);
            }
        }
        
        decimal sizeOfFile=0;
        decimal sizeOfFile1=0;
        JiraSalesforceDetail__c settingss1=JiraSalesforceDetail__c.getInstance('File_Size');
        String FileSize=settingss1.value__c;
        
        IF(FileSize.contains('MB')){
            FileSize=FileSize.remove('MB');
            sizeOfFile=decimal.valueOf(FileSize.trim());
            decimal d=(1024*1024)* sizeOfFile;
            
            sizeOfFile1=d;
        }ELSE{
            FileSize=FileSize.remove('KB');  
            sizeOfFile=decimal.valueOf(FileSize.trim());
            Decimal d=1024* sizeOfFile;
            // string temp=string.valueOf(d);
            sizeOfFile1=d;
        }
        
        if(!caseToJira.isEmpty() && !Content.isEmpty()){
            for(ContentVersion cont :Content){
                if(cont.contentsize<= sizeOfFile1 && cont.contentsize<=10000000){
                    try{
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
                        
                        if(Attachment.sObjectType.getDescribe().isAccessible() ){
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
                            file_body = cont.VersionData;
                            file_name = cont.Title+'.'+cont.FileExtension ;
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
                            
                            for(String caseno:caseToJira.keySet()){
                                for(String issueKey:caseToJira.get(caseno)){
                                    count++;
                                    req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + issueKey + '/attachments', 'POST', 'multipart/form-data; boundary=' + boundary);
                                    req.setHeader('X-Atlassian-Token', 'nocheck');
                                    req.setBodyAsBlob(bodyBlob);
                                    req.setTimeout(120000);
                                    res = http.send(req);
                                    String issueskey='';
                                    // if(res.getStatus() == 'OK' || res.getStatusCode() == 200){
                                    if(res.getStatusCode() == 200){  
                                        if(cjhelperMap.containsKey(cont.id)){
                                            if(cjhelperMap.get(cont.id).jiraissueid__c!=Null){
                                                issueskey+=issueKey +';';
                                                cjhelperMap.get(cont.id).jiraissueid__c=cjhelperMap.get(cont.id).jiraissueid__c+issueskey;
                                            }
                                        }
                                        else{
                                            issueskey+=issueKey +';';
                                            CaseJiraHelper__c cjhelp = new CaseJiraHelper__c ();
                                            cjhelp.Name = cont.id;
                                            cjhelp.Type__c='Attachment';
                                            cjhelp.jiraissueid__c = issueskey;
                                            cjhelperMap.put(cont.id,cjhelp);
                                        }
                                    }else{
                                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, issueKey, 'SendFilesToJira', res.getbody()));   
                                        
                                    }     
                                    
                                }
                                
                            }
                            
                            
                        }   
                        
                        
                    }catch(Exception ex){
                        String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',null ,null, null, null , null, null, null, null, 'Send Files To Jira', Error));
                    } 
                }
            }
        }
        if(!cjhelperMap.isEmpty()){
            try{
                if(schema.sObjectType.CaseJiraHelper__c.isUpdateable() && schema.sObjectType.CaseJiraHelper__c.isCreateable()){
                    upsert cjhelperMap.values();
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraAutoSyncHelper',null, null, null,null,null, null , null, null, 'Send Files To Jira', Error);
                
                
            }
        }
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }*/
    
    @future (callout=true)
    public static void SendCommentsTojira(String commentMap){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        Map<string,string> jirakeyId=new Map<string,string>();
        List<JiraSalesforceDetail__c> setting=new List<JiraSalesforceDetail__c>();
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
            setting=[select id, Value__c from JiraSalesforceDetail__c where name = 'Auto_SF_Comment_Sync_Type' limit 1];
        }
        Map<String,object> commentMapOuter=(Map<String,object>) JSON.deserializeUntyped(commentMap);
        for(Jiraissue__c jira:[Select Issueid__c,name from Jiraissue__c where name in:commentMapOuter.keyset()]){
            if(!jirakeyId.containskey(jira.name))
                jirakeyId.put(jira.name,String.valueof(jira.Issueid__c));
        }
        
        for(String Key : commentMapOuter.keyset()){
            
            Map<String,object> commentMapInner=(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(commentMapOuter.get(Key)));
            
            for(String comid : commentMapInner.keyset()){
                
                JiraIssueComments__c  jc= (JiraIssueComments__c) Json.deserialize(Json.serialize(commentMapInner.get(comid)), JiraIssueComments__c.Class);
                
                if(setting[0]!=null && setting[0].Value__c!=Null && setting[0].Value__c!='' &&
                   
                   ((setting[0].Value__c.tolowerCase()=='public'&& jc.IsPublished__c)
                    ||(setting[0].Value__c.tolowerCase()=='private'&& !jc.IsPublished__c)
                    ||(setting[0].Value__c.tolowerCase()=='both'))){
                        
                        String body;
                        if(!(jc.CommentBody__c).contains('Created by Salesforce :')){ 
                            if(jc.Source__c=='Jira'){
                                body=jc.CommentBody__c;
                            }else{
                                body=jc.CommentBody__c+'\n (Created by Salesforce :'+jc.createdby.name+')';
                            }
                        }else{
                            body=jc.CommentBody__c;
                        } 
                        
                        Integer count=0;
                        String str;
                        
                        if(String.isNotEmpty(body))
                        {
                            
                            str=body.replace('<b>','*');
                            str=str.replace('</b>','*');
                            str=str.replace('<i>','_');
                            str=str.replace('<p>','');
                            str=str.replace('</p>','');
                            str=str.replace('<div>','');
                            str=str.replace('</div>','');
                            str=str.replace('</i>','_');
                            str=str.replace('<u>','+');
                            str=str.replace('</u>','+');
                            str=str.replace('<strike>','-');
                            str=str.replace('</strike>','-');
                            
                            str=str.replace('<ul>','');
                            str=str.replace('</ul>','');
                            str=str.replace('<li>','* ');
                            str=str.replace('</li>','');
                        }
                        
                        HttpResponse res = new HttpResponse();
                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        if(jc.CommentId__c!=null && jc.CommentId__c!=''){
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + key + '/comment/'+jc.CommentId__c, 'PUT', 'application/json');
                        }
                        else{
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/latest/issue/' + key + '/comment/?expand=renderedBody', 'POST', 'application/json');
                        }
                        
                        req.setBody('{"body": "' + body.escapeJava() +'"}');
                        req.setTimeout(120000);
                        try{
                            if(!Test.isRunningTest())
                                res = http.send(req);
                            
                            String issueskey='';
                            if(res.getStatus() == 'Created' || res.getStatusCode() == 201){
                                
                                JiraIssueComments__c jc1= new JiraIssueComments__c(id=comid);
                                if(schema.sObjectType.JiraIssueComments__c.fields.Comment_Added__c.isUpdateable() && schema.sObjectType.JiraIssueComments__c.fields.Comment_Added__c.isCreateable()){
                                    jc1.Comment_Added__c=true;
                                }
                                String ResBody=res.getbody();
                                ResBody = ResBody.replace('\n', '\\n');
                                Map<String,Object> myobjDeserialized = (Map<String,Object>) JSON.deserializeuntyped(ResBody);
                                if(schema.sObjectType.JiraIssueComments__c.fields.CommentId__c.isUpdateable() && schema.sObjectType.JiraIssueComments__c.fields.CommentId__c.isCreateable()){
                                    jc1.CommentId__c = (String)myobjDeserialized.get('id');
                                }
                                if(schema.sObjectType.JiraIssueComments__c.fields.JiraId__c.isUpdateable() && schema.sObjectType.JiraIssueComments__c.fields.JiraId__c.isCreateable()){
                                    jc1.JiraId__c=jirakeyId.get(key);
                                }
                                if(schema.sObjectType.JiraIssueComments__c.isUpdateable()){
                                    update jc1;
                                }
                            }
                            if(res.getStatusCode() != 201&& res.getStatusCode()!=200) {
                                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(),null , Key, 'Send Comments To Jira', res.getBody()));
                                
                            }
                            
                        }catch(Exception ex){
                            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(),null , Key, 'Send Comments To Jira', Error));
                            
                        }
                        
                        
                    }
            }
        }
        
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
    
    @future (callout=true)    
    public static void SendideaCommentsTojira(String commentMap){
        List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
        List<JiraSalesforceDetail__c> setting=new List<JiraSalesforceDetail__c>();
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
            setting=[select id, Value__c from JiraSalesforceDetail__c where name = 'Auto_SF_Comment_Sync_Type' limit 1];
        }
        Map<String,object> commentMapOuter=(Map<String,object>) JSON.deserializeUntyped(commentMap);
        
        
        for(String Key : commentMapOuter.keyset()){
            
            Map<String,object> commentMapInner=(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(commentMapOuter.get(Key)));
            
            for(String comid : commentMapInner.keyset()){
                
                IdeaComment jc=(IdeaComment)Json.deserialize(Json.serialize(commentMapInner.get(comid)), IdeaComment.Class);
                
                if(setting[0]!=null && setting[0].Value__c!=Null && setting[0].Value__c!='' &&
                   
                   ((setting[0].Value__c.tolowerCase()=='public')
                    ||(setting[0].Value__c.tolowerCase()=='private')
                    ||(setting[0].Value__c.tolowerCase()=='both'))){
                        
                        String body;
                        // String str='Created By :';
                        //String str1='Last Modified By :';
                        if(!jc.CommentBody.contains('Created by Salesforce : ')){ 
                            body=jc.CommentBody+'\n (Created by Salesforce : '+jc.CreatorName+')';
                        }else{
                            body=jc.CommentBody;
                        } 
                        
                        Integer count=0;
                        HttpResponse res = new HttpResponse();
                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        
                        
                        try{
                            req = CreateJIRAWrapper.CreateRequest('/rest/api/latest/issue/' + Key + '/comment/?expand=renderedBody', 'POST', 'application/json');
                            
                            req.setBody('{"body": "' + body.escapeJava() +'"}');
                            req.setTimeout(120000);
                            res = http.send(req);
                            
                            String issueskey='';
                            if(res.getStatus() == 'Created' || res.getStatusCode() == 201){
                                
                                JSONParser parser = JSON.createParser(res.getBody());
                                
                                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                
                                /* if(results.containsKey('id')){

}*/
                                JiraIssueComments__c jc1= new JiraIssueComments__c();
                                String ResBody=res.getbody();
                                ResBody = ResBody.replace('\n', '\\n');
                                Map<String,Object> myobjDeserialized = (Map<String,Object>) JSON.deserializeuntyped(ResBody);
                                if(schema.sObjectType.JiraIssueComments__c.fields.CommentId__c.isCreateable()){
                                    jc1.CommentId__c = (String)myobjDeserialized.get('id');
                                }
                                if(schema.sObjectType.JiraIssueComments__c.fields.CommentBody__c.isCreateable()){
                                    jc1.CommentBody__c = (String)myobjDeserialized.get('body');
                                }
                                if(schema.sObjectType.JiraIssueComments__c.fields.Comment_Added__c.isCreateable()){
                                    jc1.Comment_Added__c=true;
                                }
                                if(schema.sObjectType.JiraIssueComments__c.fields.JiraIssue__c.isCreateable()){
                                    jc1.JiraIssue__c = [SELECT IssueKey__c, Id, Name FROM JiraIssue__c where IssueKey__c =: Key limit 1].id;
                                }
                                if(schema.sObjectType.JiraIssueComments__c.isCreateable()){
                                    insert jc1;
                                }
                            }
                            if(res.getStatusCode() != 201 && res.getStatusCode()!=200) {
                                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper1',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, Key, 'SendideaCommentsTojira',res.getBody()));   
                                
                            }
                            Count++;
                        }catch(Exception ex){
                            String Errormsg=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraAutoSyncHelper1',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, Key, 'SendideaCommentsTojira',Errormsg));   
                            
                        }
                    }
            }
        }
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
    
}