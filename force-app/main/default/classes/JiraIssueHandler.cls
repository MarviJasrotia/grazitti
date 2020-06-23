public without sharing  class JiraIssueHandler implements Itrigger {
    Map<String,Map<String,string>> ObjectProjectMapping = new Map<String,Map<String,string>>();
    
    Map<String,Wrapper> JiraIssueAndAction = new Map<String,Wrapper>();
    Map<String,Map<String,String>> JiraToObjectToJiraData = new Map<String,Map<String,String>>();
    Map<String,Map<String,Set<String>>> ObjectProjectMap = new Map<String,Map<String,Set<String>>>();
    Map<String,String> FinalMapForJiraAndBody = new Map<String,String>();
    List<JiraRelationship__c>CreateJiraRelation = new List<JiraRelationship__c>();
    List<JiraRelationship__c>DeleteJiraRelation = new List<JiraRelationship__c>();
    
    Map<String,String> JiraKeytoProjectId= new Map<String,String>();
    Map<String,String> ProjectKeyTOProjectId = new Map<String,String>();
    Map<String,String> jiraKeytoId=new Map<String,String>();
    
    public void bulkBefore(){}
    
    public void bulkAfter(){
        if(trigger.isUpdate){ 
            if(!Jira_login__c.sObjectType.getDescribe().isAccessible() || !JiraRelationship__c.sObjectType.getDescribe().isAccessible() || !Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() )
            {return;}
            
            //list<Jira_login__c> setting =[SELECT Id, Name, RelationType__c,End_Point__c  FROM Jira_login__c where name ='JIRA'];
            String NmSpcPackage1=System.Label.SinergifyNameSpace;
            
            //Map Of Object Name with ProjectIds and Mappedfields of Jira_ProjectFieldsMapping__c
            for(Jira_ProjectFieldsMapping__c fieldMapped : [SELECT id,Salesforce_Object__c,Enable_Record_Mapping__c,JIRA_Field_Api_Name__c,Jira_Project__c,
                                                            Jira_Project__r.ProjectKey__c FROM Jira_ProjectFieldsMapping__c WHERE 
                                                            Enable_Record_Mapping__c=True]){
                                                                if(!ObjectProjectMapping.containskey(fieldMapped.Salesforce_Object__c)){
                                                                    ObjectProjectMapping.put(fieldMapped.Salesforce_Object__c,new Map<string,string>{fieldMapped.Jira_Project__c=>fieldMapped.JIRA_Field_Api_Name__c});
                                                                }else{
                                                                    if(!ObjectProjectMapping.get(fieldMapped.Salesforce_Object__c).Containskey(fieldMapped.Jira_Project__c)){
                                                                        ObjectProjectMapping.get(fieldMapped.Salesforce_Object__c).put(fieldMapped.Jira_Project__c,fieldMapped.JIRA_Field_Api_Name__c);
                                                                    }
                                                                }
                                                            }
            //Map of projectKeys with projectIds
            for(Jira_Project__c project : [Select id , ProjectKey__c from Jira_Project__c LIMIT 1000] ){
                ProjectKeyTOProjectId.put(project.ProjectKey__c,project.id);
            }
            
            
            if(ObjectProjectMapping.isEmpty()){
                return;
            }
            String OrgNameSpace ='';
            if(Organization.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.Organization.fields.NamespacePrefix.isAccessible()){
                OrgNameSpace =[SELECT Id, NamespacePrefix  FROM Organization LIMIT 1].NamespacePrefix;
            }
            if(OrgNameSpace==null){
                OrgNameSpace=''; 
            }else{
                OrgNameSpace+='__';
            }
            Map<String, JiraSalesforceDetail__c> JiraSalesforceDetail = JiraSalesforceDetail__c.getAll();        
            string sfdomain='';
            if(JiraSalesforceDetail.containsKey('SalesForceDomain')){
                sfdomain=JiraSalesforceDetail.get('SalesForceDomain').Value__c;
            }
            Boolean CreateLinks = false;
            if(JiraSalesforceDetail.containsKey('CreateLinks')){
                if(JiraSalesforceDetail.get('CreateLinks').Value__c.toLowerCase()=='true'||
                   JiraSalesforceDetail.get('CreateLinks').Value__c.toLowerCase()=='yes'){
                       CreateLinks=true;
                   }
            }
            String linkExpiringTime='';
            if(JiraSalesforceDetail.containsKey('TimeStamp')){
                linkExpiringTime=JiraSalesforceDetail.get('TimeStamp').Value__c;
            }
            
            // Fills JiraIssueAndAction map which hold relations to delete/create in salesforce and jira issues which needs to be updated with new links.
            //  if(sfdomain!='' && sfdomain!=null){
            for(object so : Trigger.new){
                Map<String,Set<String>> ObjectNameToIds= new Map<String,Set<String>>();
                Map<String,Set<String>> ObjectNameToIdsToDeleteRelation= new Map<String,Set<String>>();
                Map<String,Set<String>> ObjectNameToIdsToAddRelation= new Map<String,Set<String>>();
                
                JiraIssue__c NewJira = (JiraIssue__c)so;
                JiraIssue__c OldJira=new JiraIssue__c();
                OldJira = (JiraIssue__c)Trigger.oldMap.get(NewJira.id);
                
                Map<String,object> newJiraData=(Map<String,Object>) JSON.deserializeUntyped(NewJira.JsonData__c);
                Map<String,object> newJirafieldMap=(Map<String,Object>) newJiraData.get('fields');
                
                Map<String,object> oldJiraData=(Map<String,Object>) JSON.deserializeUntyped(OldJira.JsonData__c);
                Map<String,object> oldJirafieldMap=(Map<String,Object>) oldJiraData.get('fields');
                //Filling JiraKeytoProjectId with JiraName and ProjectId to use it later to make map of JiraKey with map of mapped field and the Linksbody to be sent on Jira 
                
                if(ProjectKeyTOProjectId.containskey(Newjira.Project__c)){
                    JiraKeytoProjectId.put(Newjira.Name,ProjectKeyTOProjectId.get(Newjira.Project__c));
                }else{
                    continue;
                }
                for(String ObjectName : ObjectProjectMapping.keyset()){
                    String projId=JiraKeytoProjectId.get(Newjira.Name);
                    for(String ProjName : ObjectProjectMapping.get(ObjectName).Keyset()){
                        
                        if(projId.equalsIgnoreCase(ProjName)){
                            string jpm=ObjectProjectMapping.get(ObjectName).get(ProjName);
                            Set<String> newrecordsId=new Set<String>();
                            Set<String> oldrecordsId=new Set<String>();
                            set<String> OldrecordsId1 = new Set<String>();
                            set<String> NewrecordsId1 = new Set<String>();
                            set<String> InvalidrecordsId1 = new Set<String>();
                            //Get the record Ids from trigger.new
                            if(newJirafieldMap.containsKey(jpm) && newJirafieldMap.get(jpm)!=NULL ){
                                
                                String recordsId=String.ValueOf(newJirafieldMap.get(jpm));
                                List<String>  records= new List<String>();
                                records=recordsId.split('\r\n');
                                //regex to obtain encrypted part of the link
                                Pattern p = Pattern.compile('(\\?id.*])'); 
                                
                                //regex to obtain id part out of Object Name and Object Id.
                                Pattern p1=pattern.compile('\\[(.*?)\\]');
                                for(String Recd:Records){
                                    
                                    try{
                                        
                                        String RecId= Id.valueof(Recd.normalizeSpace());
                                        newrecordsId.add(RecId.left(15).normalizeSpace());
                                        NewrecordsId1.add(RecId.left(15).normalizeSpace());
                                        
                                    }catch(Exception ex){
                                        if(!Recd.containsIgnoreCase('?id=') && !Recd.containsIgnoreCase('[')){
                                            continue;
                                        }else if(Recd.containsIgnoreCase('?id=')){
                                            
                                            Matcher mo = p.matcher(Recd); 
                                            while (mo.find()){
                                                String match=mo.group();
                                                match = match.removeStart('?id=');
                                                match = match.removeEnd(']');
                                                Recd=match;
                                            }
                                            
                                            Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                                            Blob data = EncodingUtil.base64Decode(Recd);
                                            Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', encryptionKey , data);
                                            Recd= decryptedBlobData.toString();
                                            newrecordsId.add(Recd.split(',')[0].left(15).normalizeSpace());
                                            NewrecordsId1.add(Recd.split(',')[0].left(15).normalizeSpace());
                                        }else{
                                            if(Recd.containsIgnoreCase('[')){
                                                Matcher mo = p1.matcher(Recd); 
                                                while (mo.find()){
                                                    String match=mo.group();
                                                    match = match.removeStart('[');
                                                    match = match.removeEnd(']');
                                                    Recd=match;
                                                    newrecordsId.add(Recd.left(15).normalizeSpace());
                                                    NewrecordsId1.add(Recd.left(15).normalizeSpace());
                                                }  
                                            }
                                        }
                                    } 
                                }
                                
                                
                            }
                            
                            //Get the record Ids from trigger.old
                            if(oldJirafieldMap.containsKey(jpm) && oldJirafieldMap.get(jpm)!=NULL){
                                
                                String recordsId=String.ValueOf(oldJirafieldMap.get(jpm));
                                List<String>  records= new List<String>();
                                records=recordsId.split('\r\n');
                                Pattern p = Pattern.compile('(\\?id.*])'); 
                                Pattern p1=pattern.compile('\\[(.*?)\\]');
                                for(String Recd:Records){
                                    
                                    try{
                                        
                                        String RecId= Id.valueof(Recd.normalizeSpace());
                                        oldrecordsId.add(RecId.left(15).normalizeSpace());
                                        
                                    }catch(Exception ex){
                                        if(!Recd.containsIgnoreCase('?id=') && !Recd.containsIgnoreCase('[')){
                                            continue;
                                        }else if(Recd.containsIgnoreCase('?id=')){
                                            Matcher mo = p.matcher(Recd); 
                                            while (mo.find()){
                                                String match=mo.group();
                                                match = match.removeStart('?id=');
                                                match = match.removeEnd(']');
                                                Recd=match;
                                            }
                                            Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                                            Blob data = EncodingUtil.base64Decode(Recd);
                                            Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', encryptionKey , data);
                                            Recd= decryptedBlobData.toString();
                                            oldrecordsId.add(Recd.split(',')[0].left(15).normalizeSpace());
                                        }else{
                                            if(Recd.containsIgnoreCase('[')){
                                                Matcher mo = p1.matcher(Recd); 
                                                while (mo.find()){
                                                    String match=mo.group();
                                                    match = match.removeStart('[');
                                                    match = match.removeEnd(']');
                                                    Recd=match;
                                                    oldrecordsId.add(Recd.left(15).normalizeSpace());
                                                } 
                                            }
                                        }
                                    }
                                }
                            }
                            
                            set<String> tempNewrecordsId = new Set<String>();
                            set<String> tempOldrecordsId = new Set<String>();
                            
                            tempNewrecordsId.addAll(newrecordsId);
                            tempNewrecordsId.removeAll(oldrecordsId);
                            tempOldrecordsId.addAll(oldrecordsId);
                            tempOldrecordsId.removeAll(newrecordsId);
                            if(tempnewrecordsId.size()>0){
                                
                                for(String recId: tempNewrecordsId){ 
                                    String sObjName='';
                                    sObjName = ID.valueof(recId).getSObjectType().getDescribe().getName();
                                    if(!ObjectName.equals(sObjName)){
                                        tempNewrecordsId.remove(recId); 
                                        newrecordsId.remove(recId);
                                    }else{
                                        if(ObjectNameToIdsToAddRelation.containsKey(sObjName)){
                                            ObjectNameToIdsToAddRelation.get(sObjName).add(recId);
                                        }else{
                                            ObjectNameToIdsToAddRelation.put(sObjName,new Set<String>{recId});
                                        }
                                    }
                                }
                            }
                            
                            if(tempoldrecordsId.size()>0){
                                for(String recId: tempOldrecordsId){
                                    String sObjName='';
                                    sObjName = ID.valueof(recId).getSObjectType().getDescribe().getName();
                                    if(!ObjectName.equals(sObjName)){
                                        tempOldrecordsId.remove(recId); 
                                    }else{
                                        
                                        if(ObjectNameToIdsToDeleteRelation.containsKey(sObjName)){
                                            ObjectNameToIdsToDeleteRelation.get(sObjName).add(recId);
                                        }else{
                                            ObjectNameToIdsToDeleteRelation.put(sObjName,new Set<String>{recId});
                                        }
                                    }
                                }
                            }
                            for(String ids:NewRecordsId1){
                                if(!newrecordsId.contains(ids)){
                                    InvalidrecordsId1.add(ids);
                                }
                            }
                            if(!tempnewrecordsId.isEmpty() ||  !tempoldrecordsId.IsEmpty() || !InvalidrecordsId1.IsEmpty()){
                                for(String Objnum : NewrecordsId){
                                    
                                    ID id1=Id.valueof(objnum.normalizeSpace());
                                    String objType=(String)id1.getSObjectType().getDescribe().getName();
                                    
                                    if(ObjectNameToIds.containsKey(objType)){
                                        
                                        ObjectNameToIds.get(objType).add(id1);
                                        
                                    }else{
                                        ObjectNameToIds.put(objType,new Set<String>{id1});
                                    }
                                    
                                    
                                }
                            }
                            
                        }}
                    
                }
                Wrapper wrap= new Wrapper();
                //wrap.ObjectNameToProjectIds=ObjectNameToProjectIds
                wrap.ObjectNameToIds=ObjectNameToIds;
                wrap.ObjectNameToIdsToDeleteRelation=ObjectNameToIdsToDeleteRelation;
                wrap.ObjectNameToIdsToAddRelation=ObjectNameToIdsToAddRelation;
                JiraIssueAndAction.put(NewJira.id,wrap); 
                
                
            }
            //      }
            
            
            
            if(!JiraIssueAndAction.isEmpty()){
                for(String JiraId:JiraIssueAndAction.keySet()){
                    Wrapper Wrap=JiraIssueAndAction.get(JiraId);
                    String JiraKey=(String)Trigger.newMap.get(JiraId).get('IssueKey__c');
                    
                    for(String Key:Wrap.ObjectNameToIds.keySet()){
                        String query;
                        String Body='';
                        Set<String> TempIdSet= new Set<string>();
                        TempIdSet.addAll(Wrap.ObjectNameToIds.get(Key));
                        
                        if(Key!=null && Key.toLowercase() =='case'){
                            query='select Id,CaseNumber from '+Key+' where id in :TempIdSet';
                        }else if(Key!=null && Key.toLowercase() =='idea'){
                            query='select Id,Title from '+Key+' where id in :TempIdSet';
                        }else if(Key!=null){
                            query='select Id,Name from '+Key+' where id in:TempIdSet';
                        }
                        List<Sobject> obj=Database.query(query);
                        if(obj.size()>0 && obj!=NULL){
                            List<Object> FieldList=new List<Object>();
                            FieldList = (List<Object>)Json.deserializeUntyped(Json.serialize(obj));
                            
                            for(Object Recobj:FieldList){
                                String Name='';
                                Map<String,Object> RecordMap = (Map<String,Object>)Recobj;
                                
                                if(RecordMap.containskey('Name')){
                                    Name=String.valueOf(RecordMap.get('Name'));
                                }else if(Key=='case' && RecordMap.containsKey('CaseNumber')){
                                    Name=String.valueOf(RecordMap.get('CaseNumber'));
                                }else if(Key=='idea' && RecordMap.containsKey('Title')){
                                    Name=String.valueOf(RecordMap.get('Title'));
                                }
                                if(Name!=NULL && Name!=''){
                                    // Filling encrypted links in Body
                                    if(CreateLinks){
                                        
                                        
                                        Datetime dateGMT=System.now();
                                        if(linkExpiringTime!=NULL && linkExpiringTime!=''){
                                            dateGMT=dateGMT.addMinutes(integer.valueOF(linkExpiringTime));
                                        }else{
                                            dateGMT=dateGMT.addMinutes(1);
                                        }
                                        String formatedDt = dateGMT.format('yyyy-MM-dd HH:mm:ss','Greenwich Mean Time(Europe/London)');
                                        String temp11=String.valueOf(RecordMap.get('Id'))+','+formatedDt+','+JiraKey;
                                        temp11=temp11.replaceAll(' ','----');
                                        Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                                        Blob clearData=Blob.valueOf(temp11);
                                        String objnum1=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
                                        If(Body==''){
                                            Body= Name + '  [view |  ' + sfdomain+ '/apex/'+NmSpcPackage1+'__detailPage?id=' + objnum1 + '] \r\n'; 
                                            
                                        }else{
                                            Body += Name + '  [view |  ' + sfdomain+ '/apex/'+NmSpcPackage1+'__detailPage?id=' + objnum1 + '] \r\n'; 
                                        }
                                        //Body += '\n'+ Name + '  [view |  ' + sfdomain+ '/apex/'+NmSpcPackage1+'__detailPage?id=' + objnum1 + '] \r\n'; 
                                    }else{
                                        // Filling ObjectName with ObjectId in Body
                                        If(Body==''){
                                            Body= Name +'[' + String.valueOf(RecordMap.get('Id')) +']\r\n'; 
                                        }else{
                                            Body += Name +'[' + String.valueOf(RecordMap.get('Id')) +']\r\n'; 
                                        }
                                    }
                                }
                                
                                
                                
                            }
                            
                            //Filling Map of Jirakey with map of ObjectName and Body that needs to be sent on Jira.
                            if(JiraToObjectToJiraData.ContainsKey(JiraKey)){
                                JiraToObjectToJiraData.get(JiraKey).put(Key,body);
                            }else{
                                JiraToObjectToJiraData.put(JiraKey,new Map<string,String>{Key=>Body});
                            }
                            
                            
                        }
                    }
                }
            }
            // Now fetch Existing Jira Relations tied to trigger.new jiras 
            Map<String,Schema.SobjectType> SchemaMap=Schema.getGlobalDescribe();
            Map<String,Schema.SobjectField> jiraRelationFieldMap=SchemaMap.get(NmSpcPackage1+'__jiraRelationship__C').getDescribe().fields.getmap();
            //Map<String,Schema.SobjectField> jiraRelationFieldMap=SchemaMap.get('jiraRelationship__C').getDescribe().fields.getmap();
            
            Set<Schema.SobjectField> JiraRelationFieldsCheckSet= new Set<Schema.SobjectField>();
            
            String jiraRelationQuery='';
            for(String key:ObjectProjectMapping.keySet()){
                String ObjectName=key;
                if(key.toLowerCase()!='account'&& key.toLowerCase()!='case' && key.toLowerCase()!='idea'){
                    ObjectName= ObjectName.removeEnd('__c');
                    if(ObjectName.contains('__')){
                        ObjectName=ObjectName.split('__')[1];
                    }
                    ObjectName=OrgNameSpace+ObjectName;
                }else{
                    //ObjectName=ObjectName;
                    ObjectName=NmSpcPackage1+'__'+ObjectName;
                }
                ObjectName=ObjectName.removeEnd('__c');
                ObjectName= ObjectName+'Relation__c';
                if(jiraRelationFieldMap.containsKey(ObjectName.toLowerCase())){
                    jiraRelationQuery+=''+jiraRelationFieldMap.get(ObjectName.toLowerCase())+',';
                }
            }
            jiraRelationQuery=jiraRelationQuery.removeEnd(',');
            Set<String> JiraIds = new Set<String>();
            JiraIds.addAll(JiraIssueAndAction.keySet());
            jiraRelationQuery='Select Id, '+NmSpcPackage1+'__JiraIssue__c, '+jiraRelationQuery+ ' FROM '+NmSpcPackage1+'__JiraRelationship__c WHERE '+NmSpcPackage1+'__JiraIssue__c in:JiraIds';
            //jiraRelationQuery='Select Id,JiraIssue__c, '+jiraRelationQuery+ ' FROM JiraRelationship__c WHERE JiraIssue__c in:JiraIds';
            
            List<JiraRelationship__c> RelationList=Database.query(jiraRelationQuery);
            Map<String,Map<String,Set<String>>> JiraToExitingRelationMap = new Map<String,Map<String,Set<String>>>();
            for(JiraRelationship__c RelObj:RelationList){
                Wrapper Wrap= JiraIssueAndAction.get(RelObj.JiraIssue__c);
                for(String key:ObjectProjectMapping.keySet()){
                    String ObjectName=key;
                    if(ObjectName.toLowerCase()!='account'&& ObjectName.toLowerCase()!='case' && ObjectName.toLowerCase()!='idea'){
                        ObjectName= ObjectName.removeEnd('__c');
                        if(ObjectName.contains('__')){
                            ObjectName=ObjectName.split('__')[1];
                        }
                        ObjectName=OrgNameSpace+ObjectName;
                        
                    }else{
                        //ObjectName=ObjectName;
                        ObjectName=NmSpcPackage1+'__'+ObjectName;
                    }
                    ObjectName= ObjectName.removeEnd('__c')+'Relation__c';
                    
                    if(RelObj.get(ObjectName)!=null){
                        if(JiraToExitingRelationMap.containsKey(RelObj.JiraIssue__c)){
                            if(JiraToExitingRelationMap.get(RelObj.JiraIssue__c).containsKey(ObjectName)){
                                JiraToExitingRelationMap.get(RelObj.JiraIssue__c).get(ObjectName).add(((String)RelObj.get(ObjectName)).left(15).normalizeSpace());
                            }else{
                                Set<String> IdSets=new Set<String>{(RelObj.get(ObjectName).toString()).left(15).normalizeSpace()};
                                    JiraToExitingRelationMap.get(RelObj.JiraIssue__c).put(ObjectName,IdSets);
                            }
                        }else{
                            Set<String> IdSets=new Set<String>{(RelObj.get(ObjectName).toString()).left(15).normalizeSpace()};
                                JiraToExitingRelationMap.put(RelObj.JiraIssue__c,new Map<String,Set<String>>{ObjectName=>IdSets});
                        }
                        
                        if(wrap.ObjectNameToIdsToDeleteRelation.get(key)!=null &&
                           wrap.ObjectNameToIdsToDeleteRelation.get(key).contains((RelObj.get(ObjectName).toString()).left(15).normalizeSpace())){
                               DeleteJiraRelation.add(RelObj);
                           }
                        
                    }
                    
                }
                
                
                
            }
            
            for(String JiraId:JiraIssueAndAction.keySet()){
                Wrapper Wrap =JiraIssueAndAction.get(JiraId);
                Map<String,Set<String>> ExistingMap = new  Map<String,Set<String>>();
                if(JiraToExitingRelationMap.containskey(JiraId) && JiraToExitingRelationMap.get(JiraId)!=null){
                    ExistingMap=JiraToExitingRelationMap.get(JiraId);
                }
                
                for(String Key:wrap.ObjectNameToIdsToAddRelation.keySet()){
                    
                    String CustomKey=Key;
                    if(CustomKey.toLowerCase()!='account' && 
                       CustomKey.toLowerCase()!='case' && 
                       CustomKey.toLowerCase()!='idea'){
                           CustomKey= CustomKey.removeEnd('__c');
                           if(CustomKey.contains('__')){
                               CustomKey=CustomKey.split('__')[1];
                           }
                           CustomKey=OrgNameSpace+CustomKey;
                           
                       }else{
                           CustomKey=NmSpcPackage1+'__'+CustomKey;
                           //CustomKey=CustomKey;
                       }
                    CustomKey=CustomKey.removeEnd('__c');
                    
                    CustomKey=CustomKey+'Relation__c';
                    
                    
                    if(wrap.ObjectNameToIdsToAddRelation.get(Key)!=null && !wrap.ObjectNameToIdsToAddRelation.get(Key).isEmpty()){
                        if(ExistingMap.get(CustomKey)!=null && !ExistingMap.get(CustomKey).isEmpty()){
                            wrap.ObjectNameToIdsToAddRelation.get(Key).removeAll(ExistingMap.get(CustomKey));
                        } 
                        for(String Reldata:wrap.ObjectNameToIdsToAddRelation.get(Key)){
                            JiraIssue__c Ji =(JiraIssue__c)Trigger.newMap.get(JiraId);
                            JiraRelationship__c JiraRel = new JiraRelationship__c();
                            if(schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.Iscreateable()){
                                JiraRel.Jira_Issue_Link__c=Ji.Jira_Link__c;
                            }
                            if(schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.Iscreateable()){
                                JiraRel.JiraIssue__c=JiraId;
                            }
                            if(schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.Iscreateable()){
                                JiraRel.JiraIssueId__c=Ji.IssueId__c;
                            }
                            JiraRel.put(CustomKey,Reldata);
                            CreateJiraRelation.add(JiraRel);
                        }
                    }
                }
            }
            
            // Filling ObjectProjectMap with JiraKey ,map of MappedField and JiraBody
            
            if(!JiraToObjectToJiraData.isEmpty()){
                for(String key:JiraToObjectToJiraData.keySet()){
                    String JiraProjectId=JiraKeytoProjectId.get(key);
                    String Body='';
                    for(String Objectname:JiraToObjectToJiraData.get(key).keySet()){
                        if(body!=''){
                            body+=',';
                        }
                        if(ObjectProjectMapping.get(Objectname)!=null){
                            if(ObjectProjectMap.containskey(key)){
                                if(ObjectProjectMap.get(key).containskey(Objectprojectmapping.get(Objectname).get(JiraProjectId))){
                                    ObjectProjectMap.get(key).get(Objectprojectmapping.get(Objectname).get(JiraProjectId)).add(JiraToObjectToJiraData.get(key).get(Objectname));
                                }else{
                                    ObjectProjectMap.get(key).put(Objectprojectmapping.get(Objectname).get(JiraProjectId),new Set<String>{JiraToObjectToJiraData.get(key).get(Objectname)});
                                    
                                }
                                //Body+='"'+Objectprojectmapping.get(Objectname).get(JiraProjectId)+'":"'+(JiraToObjectToJiraData.get(key).get(Objectname)).escapeJava()+ '"';
                            }else{
                                ObjectProjectMap.put(key,new Map<String,Set<String>>{Objectprojectmapping.get(Objectname).get(JiraProjectId)=>new Set<String>{JiraToObjectToJiraData.get(key).get(Objectname)}});
                            } 
                        }
                    }
                    //FinalMapForJiraAndBody.put(key,Body);
                }   
                
            }
            
            // Fills FinalMapForJiraAndBody map to update jira Links on Jira Instance for all the related objects.
            if(!ObjectProjectMap.isEmpty()){
                
                for(String JiraKey:ObjectProjectMap.keyset()){
                    String body='';
                    for(String MappedField:ObjectProjectMap.get(JiraKey).keyset()){
                        
                        String bodytext='';
                        Set<String> str=ObjectProjectMap.get(JiraKey).get(Mappedfield);
                        for(String val:str){
                            if(bodytext==''){
                                val=val;
                                bodytext=val;  
                            }else{
                                bodytext+=val;
                            }
                        }
                        if(body==''){
                            body='"'+MappedField+'":"'+bodytext.escapeJava()+ '"';  
                        }else{
                            body+=',"'+MappedField+'":"'+bodytext.escapeJava()+ '"';
                        }
                    }
                    FinalMapForJiraAndBody.put(JiraKey,body);
                }
            }
        }
        
        
        /*this Trigger will fire to Sync jira Comments Into Salesforce*/
        if(Trigger.isInsert){
            JiraSalesforceDetail__c setting=JiraSalesforceDetail__c.getInstance('SyncLegacyJiraComment');
            if(setting!=null && setting.Value__c!=NULL && setting.Value__c!='' && setting.Value__c.ToLowerCase()=='yes'){
                for(Sobject so:trigger.new){
                    JiraIssue__c ji = (JiraIssue__c)so;
                    jiraKeytoId.put(String.valueoF(ji.IssueId__c),ji.Id);
                }
            }
        }
    }
    
    public void beforeInsert(SObject so){}
    public void afterInsert(SObject so){}
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterUpdate(SObject newObj, Sobject oldSo){}
    
    
    public  void afterDelete(SObject so){}
    
    public void andFinally(){
        if(!DeleteJiraRelation.isEmpty()){
            try{
                if(schema.sObjectType.JiraRelationship__c.isDeletable()){
                    Delete DeleteJiraRelation;
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraIssueHandler',null, null, null,null,null, null , null, null, 'Delete JiraRelationship', Error);
            }
        }
        if(!CreateJiraRelation.isEmpty()){
            try{
                if(schema.sObjectType.JiraRelationship__c.Iscreateable()){
                    insert CreateJiraRelation;
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraIssueHandler',null, null, null,null,null, null , null, null, 'Insert JiraRelationship', Error);
            }
        }
        if(!FinalMapForJiraAndBody.isEmpty()){
            JiraIssueGateway.updateObjectURLOnjira(Json.serialize(FinalMapForJiraAndBody));  
        }
        
        if(!jiraKeytoId.isEmpty()){
            JiraIssueCommentUpdate batch = new JiraIssueCommentUpdate(jiraKeytoId);
            datetime dt = system.now().addSeconds(15); 
            String day = string.valueOf(dt.day());
            String month = string.valueOf(dt.month());
            String hour = string.valueOf(dt.hour());
            String minute = string.valueOf(dt.minute());
            String second = string.valueOf(dt.second());
            String year = string.valueOf(dt.year());
            String strSchedule = second+' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            System.schedule('Jira Comment Update'+strSchedule, strSchedule, batch);
        }
        
        
    }
    public class Wrapper{
        
        Map<String,Set<String>> ObjectNameToIds= new Map<String,Set<String>>();
        Map<String,Set<String>> ObjectNameToIdsToDeleteRelation= new Map<String,Set<String>>();
        Map<String,Set<String>> ObjectNameToIdsToAddRelation= new Map<String,Set<String>>();
    }
}