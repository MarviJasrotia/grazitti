public with Sharing class JiraIssueRelationshipHandler implements Itrigger {
    Map<String,Map<String,String>> ObjectProjectMap=new Map<String,Map<String,String>>();
    Map<String,Jira_ProjectFieldsMapping__c> recordMappedFields=new Map<String,Jira_ProjectFieldsMapping__c>();
    String OrgNameSpace;
    Map<String, JiraSalesforceDetail__c> JiraSalesforceDetail;
    
    Map<String,String> fieldDataType=new Map<String,String>();
    Map<String,Map<String,Set<String>>> JiraToObjectToObjectIds=new Map<String,Map<String,Set<String>>>();
    Map<String,Map<String,Set<String>>> UpdateJiraToObjectToObjectIds=new Map<String,Map<String,Set<String>>>();
    List<JiraRelationship__c> jiraRelationList=new List<JiraRelationship__c>();  
    Set<String> JiraIds=new Set<String> ();  
    Map<String,String> Jira1=new Map<String,String>();
    Map<String,String> ProjectKeyTOProjectId = new Map<String,String>();
    
    public void bulkBefore(){}
    public void beforeInsert(SObject so){}
    
    public void bulkAfter(){
        String NmSpcPackage1=System.Label.SinergifyNameSpace;
        //FETCH THE PROJECT FIELD MAPPING WHICH ARE MAPPED AS JIRA FIELD
        if(!JiraRelationship__c.sObjectType.getDescribe().isAccessible() || !JiraIssue__c.sObjectType.getDescribe().isAccessible())
        {return;}
        for(Jira_ProjectFieldsMapping__c fieldMapped : [SELECT id,Salesforce_Object__c,Enable_Record_Mapping__c,JIRA_Field_Api_Name__c,
                                                        Jira_Project__r.ProjectKey__c FROM Jira_ProjectFieldsMapping__c WHERE 
                                                        Enable_Record_Mapping__c=True]){
                                                            if(ObjectProjectMap.containsKey(fieldMapped.Salesforce_Object__c)){
                                                                ObjectProjectMap.get(fieldMapped.Salesforce_Object__c).put(fieldmapped.Jira_Project__c,fieldmapped.JIRA_Field_Api_Name__c);
                                                                
                                                            }else{
                                                                ObjectProjectMap.put(fieldMapped.Salesforce_Object__c,New Map<String,String>{fieldmapped.Jira_Project__c=>fieldmapped.JIRA_Field_Api_Name__c});
                                                            }
                                                            // if(!recordMappedFields.containsKey(fieldMapped.Salesforce_Object__c) && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Salesforce_Object__c.isAccessible()){
                                                            //     recordMappedFields.put(fieldMapped.Salesforce_Object__c,fieldMapped);  
                                                            //  }
                                                        }
        
        if(ObjectProjectMap.isEmpty()){
            return;
        }
        
        //Map of projectKeys with projectIds
        for(Jira_Project__c project : [Select id , ProjectKey__c from Jira_Project__c Limit 1000] ){
            ProjectKeyTOProjectId.put(project.ProjectKey__c,project.id);
        }
        
        if(Schema.sObjectType.Organization.fields.NamespacePrefix.isAccessible()){
            OrgNameSpace =[SELECT Id, NamespacePrefix  FROM Organization LIMIT 1].NamespacePrefix;
        }
        if(OrgNameSpace==null){
            OrgNameSpace=''; 
        }else{
            OrgNameSpace+='__';
        }
        JiraSalesforceDetail = JiraSalesforceDetail__c.getAll();        
        string sfdomain='';
        if(JiraSalesforceDetail.containsKey('SalesForceDomain')){
            sfdomain=JiraSalesforceDetail.get('SalesForceDomain').Value__c;
        }
        
        Map<String,Schema.SobjectField> jiraRealtionfieldMap=new Map<String,schema.SobjectField>();
        Map<String,Schema.SobjectType> schemaMap=Schema.getGlobalDescribe();
        jiraRealtionfieldMap=SchemaMap.get(NmSpcPackage1+'__JiraRelationship__c').getDescribe().fields.getMap();
        //jiraRealtionfieldMap=SchemaMap.get('JiraRelationship__c').getDescribe().fields.getMap();
   
        for(Schema.SobjectField field : jiraRealtionfieldMap.values()){
            if(String.valueOF(field.getDescribe().getType()).tolowercase()=='reference' && 
               String.valueOf(field).contains('Relation__c') &&
               jiraRealtionfieldMap.get(string.valueOf(field)).getDescribe().getReferenceTo().size()>0){
                   fieldDataType.put(string.valueOf(field),string.valueOf(jiraRealtionfieldMap.get(string.valueOf(field)).getDescribe().getReferenceTo()[0]));
               }
        }
        
    
        
        
        // if(sfdomain!='' && sfdomain!=null){
        if(Trigger.IsInsert){
            for(Sobject so :Trigger.New){
                JiraRelationship__c jr=(JiraRelationship__c)so;
                jiraRelationList.add(jr);
            }   
        }
        if(Trigger.IsDelete){
            for(Sobject so :Trigger.old){
                JiraRelationship__c jr=(JiraRelationship__c)so;
                jiraRelationList.add(jr);
                JiraIds.add(jr.JiraIssue__c);
                
            }   
        }
        
        //    }
        
        if(!jiraRelationList.isEmpty() && Trigger.IsInsert){
            for(JiraRelationship__c JRel: jiraRelationList){
                for(String fieldName:fieldDataType.keySet()){
                  
                    if(JRel.get(fieldName)!=null){
                        String objectName=fieldDataType.get(fieldName);
                        if(ObjectProjectMap.containsKey(objectName)){
                           
                            if(JiraToObjectToObjectIds.containsKey(JRel.JiraIssue__c)){
                                if(JiraToObjectToObjectIds.get(JRel.JiraIssue__c).containsKey(objectName)){ 
                                    JiraToObjectToObjectIds.get(JRel.JiraIssue__c).get(objectName).add((JRel.get(fieldName).toString()).left(15).normalizeSpace());
                                }else{
                                    JiraToObjectToObjectIds.get(JRel.JiraIssue__c).put(objectName,new Set<String>{(JRel.get(fieldName).toString()).left(15).normalizeSpace()});
                                }
                            }else{
                                JiraToObjectToObjectIds.put(JRel.JiraIssue__c, new Map<String,Set<String>>{objectName=>new Set<String>{(JRel.get(fieldName).toString()).left(15).normalizeSpace()}});
                            }
                        }
                    }
                }
            }
        }
        for(JiraIssue__c Jira:[SELECT Id, Name,Project__c, IssueKey__c, JsonData__c FROM JiraIssue__c where id in:JiraToObjectToObjectIds.keySet()]){
            Map<String,Set<String>> ObjectTorecordMap= new Map<String,Set<String>>();
            if(JiraToObjectToObjectIds.containsKey(Jira.id) && JiraToObjectToObjectIds.get(Jira.id)!=null){
                Map<String,object> newJiraData=(Map<String,Object>) JSON.deserializeUntyped(Jira.JsonData__c);
                Map<String,object> newJirafieldMap=(Map<String,Object>) newJiraData.get('fields');
                ObjectTorecordMap=JiraToObjectToObjectIds.get(Jira.id);
                String ProjId=ProjectKeyTOProjectId.get(Jira.Project__c);
                
                for(String ObjectName : ObjectProjectMap.keyset()){
                    if(!ObjectTorecordMap.containsKey(ObjectName) ||
                       ObjectTorecordMap.get(ObjectName)==null &&
                       ObjectTorecordMap.get(ObjectName).isEmpty()){
                           continue;
                       }
                    for(String ProjName:ObjectProjectMap.get(ObjectName).keyset()){
                        
                        if(ProjId.equalsIgnoreCase(ProjName)){
                            String jpm=ObjectProjectMap.get(ObjectName).get(ProjName);
                            
                            Set<String> newrecordsId=new Set<String>();
                            Set<String> newrecordsIds=new Set<String>();
                            if(newJirafieldMap.containsKey(jpm) 
                               && newJirafieldMap.get(jpm)!=NULL){
                                   
                                   String recordsId=String.ValueOf(newJirafieldMap.get(jpm));
                                   List<String>  records= new List<String>();
                                   //records=recordsId.split('\r\n');
                                   records=recordsId.split('\r\n');
                                   Pattern p = Pattern.compile('(\\?id.*])'); 
                                   //regex to obtain id part out of Object Name and Object Id.
                                   Pattern p1=pattern.compile('\\[(.*?)\\]');
                                   for(String Recd:Records){
                                       // if(Recd.normalizeSpace()==''){
                                       //      continue;
                                       //  }
                                       try{
                                           String RecId= Id.valueof(Recd.normalizeSpace());
                                           newrecordsId.add(RecId.left(15).normalizeSpace());
                                           newrecordsIds.add(RecId.left(15).normalizeSpace());
                                           
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
                                               newrecordsIds.add(Recd.split(',')[0].left(15).normalizeSpace());
                                           }else 
                                           {
                                               if(Recd.containsIgnoreCase('[')){
                                                   Matcher mo = p1.matcher(Recd); 
                                                   while (mo.find()){
                                                       String match=mo.group();
                                                      
                                                       match = match.removeStart('[');
                                                       match = match.removeEnd(']');
                                                       Recd=match;
                                                       newrecordsId.add(Recd.left(15).normalizeSpace());
                                                       NewrecordsIds.add(Recd.left(15).normalizeSpace());
                                                   }  
                                               }
                                           }
                                       }
                                   }
                               }
                            if(!newrecordsIds.containsAll(ObjectTorecordMap.get(ObjectName))){
                                newrecordsId.addAll(ObjectTorecordMap.get(ObjectName));
                                if(UpdateJiraToObjectToObjectIds.containsKey(Jira.Name)){
                                    if(UpdateJiraToObjectToObjectIds.get(Jira.Name).containsKey(jpm)){
                                        UpdateJiraToObjectToObjectIds.get(Jira.Name).get(jpm).addAll(newrecordsId);
                                    }else{
                                        UpdateJiraToObjectToObjectIds.get(Jira.Name).put(jpm,newrecordsId);
                                    }
                                }else{
                                    UpdateJiraToObjectToObjectIds.put(Jira.Name,new map<String,Set<String>>{jpm=>newrecordsId});
                                }
                                
                                
                                
                            }
                        }}} 
            }
        }
        
        if(!JiraIds.isEmpty() && Trigger.IsDelete){
            
            for(JiraRelationship__c JRel: jiraRelationList){
                for(String fieldName:fieldDataType.keySet()){
                    if(JRel.get(fieldName)!=null){
                        String objectName=fieldDataType.get(fieldName);
                        if(ObjectProjectMap.containsKey(objectName)){
                            if(JiraToObjectToObjectIds.containsKey(JRel.JiraIssue__c)){
                                if(JiraToObjectToObjectIds.get(JRel.JiraIssue__c).containsKey(objectName)){ 
                                    JiraToObjectToObjectIds.get(JRel.JiraIssue__c).get(objectName).add((JRel.get(fieldName).toString()).left(15).normalizeSpace());
                                }else{
                                    JiraToObjectToObjectIds.get(JRel.JiraIssue__c).put(objectName,new Set<String>{(JRel.get(fieldName).toString()).left(15).normalizeSpace()});
                                }
                            }else{
                                JiraToObjectToObjectIds.put(JRel.JiraIssue__c, new Map<String,Set<String>>{objectName=>new Set<String>{(JRel.get(fieldName).toString()).left(15).normalizeSpace()}});
                            }
                        }
                    }
                }
            }
            
            for(JiraIssue__c Jira:[SELECT Id, Name, IssueKey__c,Project__c, JsonData__c FROM JiraIssue__c where id in:JiraToObjectToObjectIds.keySet()]){
                Map<String,Set<String>> ObjectTorecordMap= new Map<String,Set<String>>();
                if(JiraToObjectToObjectIds.containsKey(Jira.id) && JiraToObjectToObjectIds.get(Jira.id)!=null){
                    Map<String,object> newJiraData=(Map<String,Object>) JSON.deserializeUntyped(Jira.JsonData__c);
                    Map<String,object> newJirafieldMap=(Map<String,Object>) newJiraData.get('fields');
                    ObjectTorecordMap=JiraToObjectToObjectIds.get(Jira.id);
                    String ProjId=ProjectKeyTOProjectId.get(Jira.Project__c);
                    
                    for(String ObjectName : ObjectProjectMap.keyset()){
                        if(!ObjectTorecordMap.containsKey(ObjectName) ||
                           ObjectTorecordMap.get(ObjectName)==null &&
                           ObjectTorecordMap.get(ObjectName).isEmpty()){
                               continue;
                           }
                        for(String ProjName:ObjectProjectMap.get(ObjectName).keyset()){
                            if(ProjId.equalsIgnoreCase(ProjName)){
                                String jpm=ObjectProjectMap.get(ObjectName).get(ProjName);
                                Set<String> newrecordsId=new Set<String>();
                                Set<String> newrecordsIds=new Set<String>();
                                
                                if(newJirafieldMap.containsKey(jpm) 
                                   && newJirafieldMap.get(jpm)!=NULL){
                                       String recordsId=String.ValueOf(newJirafieldMap.get(jpm));
                                       List<String>  records= new List<String>();
                                       //records=recordsId.split('\r\n');
                                       records=recordsId.split('\r\n');
                                       Pattern p = Pattern.compile('(\\?id.*])'); 
                                       //regex to obtain id part out of Object Name and Object Id.
                                       Pattern p1=pattern.compile('\\[(.*?)\\]');
                                       for(String Recd:Records){
                                           // if(Recd.normalizeSpace()==''){
                                           //      continue;
                                           //  }
                                           try{
                                               String RecId= Id.valueof(Recd.normalizeSpace());
                                               newrecordsId.add(RecId.left(15).normalizeSpace());
                                               newrecordsIds.add(RecId.left(15).normalizeSpace());
                                               
                                           }catch(Exception ex){
                                               if(!Recd.containsIgnoreCase('?id=') && !Recd.containsIgnoreCase('[') ){
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
                                                   newrecordsIds.add(Recd.split(',')[0].left(15).normalizeSpace());
                                               }else{
                                                   if(Recd.containsIgnoreCase('[')){
                                                       Matcher mo = p1.matcher(Recd); 
                                                       while (mo.find()){
                                                           String match=mo.group();
                                                       
                                                           match = match.removeStart('[');
                                                           match = match.removeEnd(']');
                                                           Recd=match;
                                                           newrecordsId.add(Recd.left(15).normalizeSpace());
                                                           NewrecordsIds.add(Recd.left(15).normalizeSpace());
                                                       }  
                                                   }
                                               }  
                                           }
                                       }
                                   }
                                if(newrecordsIds.containsAll(ObjectTorecordMap.get(ObjectName))){
                                    // newrecordsId.addAll(ObjectTorecordMap.get(ObjectName));
                                    newrecordsId.removeall(ObjectTorecordMap.get(ObjectName));
                                    if(UpdateJiraToObjectToObjectIds.containsKey(Jira.Name)){
                                        if(UpdateJiraToObjectToObjectIds.get(Jira.Name).containsKey(jpm)){
                                            UpdateJiraToObjectToObjectIds.get(Jira.Name).get(jpm).addAll(newrecordsId);
                                        }else{
                                            UpdateJiraToObjectToObjectIds.get(Jira.Name).put(jpm,newrecordsId);
                                        }
                                    }else{
                                        UpdateJiraToObjectToObjectIds.put(Jira.Name,new map<String,Set<String>>{jpm=>newrecordsId});
                                    }
                                    
                                    
                                    
                                }
                            }}  }
                }
            }  
            
            
        }
        
        
    }
    public void afterInsert(SObject so){
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterUpdate(SObject newObj, Sobject oldSo){}
    
    public void afterDelete(SObject so){
        
    }
    
    public void andFinally(){
        if(UpdateJiraToObjectToObjectIds.size() > 0 && !system.isbatch() && !test.isRunningTest()){
            try{
                database.executeBatch(new UpdateJiraFromRelationBatch(UpdateJiraToObjectToObjectIds), 20);
            }catch(dmlexception ex){
                String Error=ex.getCause()+'\n'+ex.getLineNumber()+'\n'+ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraIssueRelationShipHandler',null ,null, null, null , null, null, null, null, 'Finally', Error);
                
            }
        }
    }
}