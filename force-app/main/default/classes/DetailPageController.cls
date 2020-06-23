public with Sharing class DetailPageController {
    public String lang{get;set;}
    public List<JiraErrorLogs__c> JiraLogsToInsert;
    public String OrgNamSpace{get;set;}
    public String Sfdomain{get;set;}
    String fsName,sobjectType;
    Map<String,Jira_ProjectFieldsMapping__c> jiarecordMappedFields=new Map<String,Jira_ProjectFieldsMapping__c>();
    Map<String,String> map1=new Map<String,String>();
    Map<String,String> JiraProjectmap=new Map<String,String>();
    Id id;
    Map<String,Map<String,string>> ObjectProjectMapping = new Map<String,Map<String,string>>();
    
    transient FieldSet fs;
    public  String str;
    public Id CaseId {get;set;}
    public String ObjectName {get;set;}
    public Boolean flag{get;set;}
    public List<String> Fields{get;set;}
    public map<String,String> FieldMap{get;set;} 
    public Boolean renew{get;set;}
    public Boolean LimitOver{get;set;}
    Date SystemDate;
    Date DateInLink;
    Integer Linkhour;
    Integer Linkmin;
    Integer LinkSec;
    Integer SystemHour;
    Integer SystemMin;
    Integer SystemSec;
    String Links='';
    String RecordId1;
    String JiraLinkValues;
    String jiraField;
    String issuekey;
    Map<String,String> ProjectKeyTOProjectId = new Map<String,String>();
    
    String ExpireTime;
    list<string> RecordId;
    string linkExpiringTime;
    
    public DetailPageController() {
        lang=userinfo.getLanguage();
        JiraLogsToInsert = new List<JiraErrorLogs__c>();
        flag=true;
        renew=false;
        RecordId1='';
        JiraLinkValues='';
        jiraField='';
        issuekey='';
        ExpireTime='';
        String NmSpcPackage1=System.Label.SinergifyNameSpace;
        
        Map<String, JiraSalesforceDetail__c> domain = JiraSalesforceDetail__c.getAll();        
        
        if(domain.containsKey('SalesForceDomain'))
            sfdomain=domain.get('SalesForceDomain').Value__c;
        
        if(domain.containsKey('TimeStamp'))
            linkExpiringTime=domain.get('TimeStamp').Value__c;
        
        RecordId=new list<string>();
        Fields = new List<String>();
        FieldMap = new map<String,String>();
        RecordId1=ApexPages.currentPage().getParameters().get('id');
        if(RecordId1==null || RecordId1==''){
            return;
        }
        try{
            RecordId1=RecordId1.replaceAll(' ','+');
            Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
            Blob data = EncodingUtil.base64Decode(RecordId1);
            Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', encryptionKey , data);
            String RecordId2 = decryptedBlobData.toString();
            RecordId2=RecordId2.replaceAll('----',' ');
            RecordId.addall(RecordId2.normalizespace().split(','));
            caseId=RecordId[0];
            String IdValue=caseId.getSObjectType().getDescribe().getName();
            if(Organization.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.Organization.fields.NamespacePrefix.isAccessible()){
                String OrgNameSpace =[SELECT Id, NamespacePrefix  FROM Organization LIMIT 1].NamespacePrefix;
                if(OrgNameSpace!=null&&OrgNameSpace!=''){
                    OrgNamSpace=OrgNameSpace+'__'; 
                }
            }
            if(IdValue.Contains('Grz_Sf__')||IdValue.Contains('grz_sf__'))
            {
                IdValue=IdValue.replace('Grz_Sf__','');
                IdValue=IdValue.replace('grz_sf__','');
            }
            if(IdValue.Contains('__c')||IdValue.Contains('__C'))
            {
                IdValue=IdValue.removeEnd('__c');
                IdValue=IdValue.removeEnd('__C');
            }
            if(IdValue.contains('__'))
            {
                IdValue=IdValue.substring(IdValue.indexof('__')+2,IdValue.length() );
                
            }
            ObjectName=IdValue;
            ExpireTime=RecordId[1];
            List<String> DateTimeInLink = new List<String>();
            DateTimeInLink.addall(RecordId[1].split(' '));
            dateInLink = Date.valueof(DateTimeInLink[0]);
            String TimeInLink = DateTimeInLink[1];
            List<String> TimeStampInlink = new List<String>();
            TimeStampInlink.addall(TimeInLink.split(':'));
            Linkhour = Integer.valueof(TimeStampInlink[0]);
            Linkmin = Integer.valueof(TimeStampInlink[1]);
            Linksec = Integer.valueof(TimeStampInlink[2]);
            
            issuekey=RecordId[2];
            List<String> LinkField=new List<String>();
            jiraField='';
            JiraLinkValues='';
            if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() && !JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                return;
            }
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
            for(Jira_Project__c project : [Select id , ProjectKey__c from Jira_Project__c Limit 1000] ){
                ProjectKeyTOProjectId.put(project.ProjectKey__c,project.id);
            }
            JiraIssue__c ji=[Select id,jsondata__c,Project__c,issuekey__c,Name from JiraIssue__c where IssueKey__c=:issuekey];
            if(ProjectKeyTOProjectId.containskey(ji.Project__c)){
                JiraProjectmap.put(ji.Name,ProjectKeyTOProjectId.get(ji.Project__c));
            }
            for(String obj:ObjectProjectMapping.keySet()){
                for(String Proj:ObjectProjectMapping.get(obj).keyset()){
                    if(JiraProjectmap.get(ji.Name)==Proj){
                        String mappedfield=ObjectProjectMapping.get(obj).get(Proj);
                        if(Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isAccessible()){
                            Map<String,object> JiraData=(Map<String,Object>) JSON.deserializeUntyped(ji.JsonData__c);
                            Map<String,object> JirafieldMap=(Map<String,Object>) JiraData.get('fields');
                            JiraLinkValues+=String.ValueOf(JirafieldMap.get(mappedfield));
                            if(map1.containsKey(mappedfield)){
                                map1.get(String.ValueOf(JirafieldMap.get(mappedfield)));
                                
                            }else{
                                map1.put(mappedfield,String.ValueOf(JirafieldMap.get(mappedfield)));
                                  
                            }
                        }}
                }
            }
            
            DateTime dt=system.now();
            String DateTimeInSystem = dt.format('yyyy-MM-dd HH:mm:ss','(GMT +00:00) Greenwich Mean Time(Europe/London)');
            List<String> DateTimeInSystem1 = new List<String>();
            DateTimeInSystem1.addall(DateTimeInSystem.split(' '));
            SystemDate = Date.valueof(DateTimeInSystem1[0]);
            String SystemTime = DateTimeInSystem1[1];
            List<String> SystemTimeStamp = new List<String>();
            SystemTimeStamp.addAll(SystemTime.split(':'));
            Systemhour = Integer.valueOf(SystemTimeStamp[0]);
            Systemmin = Integer.valueOf(SystemTimeStamp[1]);
            Systemsec = Integer.valueOf(SystemTimeStamp[2]);
            
            if(!(RecordId[0].length() == 15 || RecordId[0].length() == 18)) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning, System.label.DetailPageController_Label1);
                ApexPages.addMessage(msg); 
                flag=false;
            }else{
                
                if (SystemDate>DateInLink && !JiraLinkValues.contains(RecordId1)) { 
                    flag = false; 
                }
                else if (SystemDate>DateInLink && JiraLinkValues.contains(RecordId1)) { 
                    flag = true;
                    renew = true;
                } else if (SystemDate<DateInLink) {
                    flag = true;
                }
                else if (SystemDate == DateInLink) {
                 
                    if (SystemHour>LinkHour && !JiraLinkValues.contains(RecordId1)) {
                        flag = false;
                    } else if (SystemHour>LinkHour && JiraLinkValues.contains(RecordId1)) {
                        flag = true;
                        renew = true;
                    } else if (SystemHour<LinkHour) {
                        flag = true;
                    } else if (SystemHour == LinkHour) {
                        if (SystemMin>LinkMin && !JiraLinkValues.contains(RecordId1)) {
                            flag = false;
                        } else if (SystemMin>LinkMin && JiraLinkValues.contains(RecordId1)) {
                            flag = true;
                            renew = true;
                        } else if (SystemMin<LinkMin) {
                            flag = true;
                        } else if (SystemMin == LinkMin) {
                            if (SystemSec>LinkSec && !JiraLinkValues.contains(RecordId1)) {
                                flag = false;
                            } else if (SystemSec>LinkSec && JiraLinkValues.contains(RecordId1)) {
                                flag = true;
                                renew = true;
                            } else if (SystemSec<LinkSec) {
                                flag = true;
                            } else if (SystemSec == LinkSec) {
                                flag = true;
                            }
                        }
                    }
                }
                
                
                if(renew==true){
                    String body1='';
                    for(String LinkFieldValues:map1.keySet()){
                        if(map1.get(LinkFieldValues)!=null)
                        {
                            jiraField=String.ValueOf(map1.get(LinkFieldValues));
                            JiraField=JiraField.normalizeSpace();
                        }
                        String[] records=new string[]{};
                            Set<String> newrecordsId=new Set<String>();
                        if(JiraField!=null && JiraField!='')
                        {
                            JiraField=JiraField.replaceAll('\n',' ');
                            JiraField=JiraField.replaceAll('\r',' ');
                            records=JiraField.split(' ');
                            for(String strr:Records)
                            {
                                if(strr.contains('id=') ){
                                    try{
                                        strr=strr.remove(']');
                                        String[] strr1=strr.split('id=');
                                        String s1=strr1[1];
                                        Blob encryptionKey1 = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                                        Blob data1 = EncodingUtil.base64Decode(s1);
                                        Blob decryptedBlobData1 = Crypto.decryptWithManagedIV('AES128', encryptionKey1 , data1);
                                        String value1 = decryptedBlobData1.toString();
                                        String[] Ids=value1.normalizespace().split(',');
                                        newrecordsId.add(Ids[0].left(15).normalizeSpace());
                                        
                                    }catch(Exception ex)
                                    {
                                        flag=true;   
                                    }
                                }else{
                                }
                            }
                        }
                        
                        
                        
                        if(sfdomain!=''){
                            String RecIds1='';
                            if(NewrecordsId.size()>0){
                                for(String Objnum : NewrecordsId){
                                    String Query='';
                                    String sObjName='';
                                    objnum=objnum.removeStart('{');
                                    objnum=objnum.removeEnd('}');
                                    objnum=objnum.remove(',');
                                    objnum =objnum.normalizeSpace();
                                    ID id1=objnum;
                                    
                                    Schema.SObjectType objType=id1.getSobjectType();
                                    if(String.valueof(objType)=='Case' || String.valueof(objType)=='case')
                                    {
                                        query='select id,CaseNumber from '+objType+' where id=:id1';
                                    }else if(String.valueof(objType)=='idea' || String.valueof(objType)=='Idea')
                                    {
                                        query='select id,Title from '+objType+' where id=:id1';
                                    }else
                                    {
                                        query='select id,Name from '+objType+' where id=:id1';
                                    }
                                    Sobject obj=Database.query(query);
                                    Map<String,Object> FieldMap1 = (Map<String,Object>)Json.deserializeUntyped(Json.serialize(obj));
                                    String Name='';
                                    
                                    if(fieldMap1.containskey('Name')){
                                        Name=String.valueOf(FieldMap1.get('Name'));
                                    }else if(String.valueof(objType).tolowerCase()=='case'){
                                        Name=String.valueOf(FieldMap1.get('CaseNumber'));
                                    }else if(String.valueof(objType).tolowerCase()=='idea'){
                                        Name=String.valueOf(FieldMap1.get('Title'));
                                    }
                                    Datetime dateGMT=System.now();
                                    if(linkExpiringTime!=NULL){
                                        dateGMT=dateGMT.addMinutes(integer.valueOF(linkExpiringTime));
                                    }else{
                                        dateGMT=dateGMT.addMinutes(1);
                                    }
                                    String formatedDt = dateGMT.format('yyyy-MM-dd HH:mm:ss','Greenwich Mean Time(Europe/London)');
                                    String temp11=objnum+','+formatedDt+','+issuekey;
                                    temp11=temp11.replaceAll(' ','----');
                                    Blob encryptionKey2 = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
                                    Blob clearData2=Blob.valueOf(temp11);
                                    String objnum1=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey2, clearData2));
                                    RecIds1 += '\\n'+ Name + ' [view|' + sfdomain+ '/apex/'+NmSpcPackage1+'__detailPage?id=' + objnum1 + '] \\r\\n'; 
                                    
                                }
                                
                                RecIds1 = '"' + RecIds1 + '"';
                                if(Links==''&&links==null){
                                    Links='"'+ LinkFieldValues +'":' + RecIds1 +' , ';
                                }else
                                {
                                    Links+='"'+ LinkFieldValues +'":' + RecIds1 +' , '; 
                                }
                            }
                        }
                    }
                    links=links.removeEnd(' , ');
                    body1='{"fields":{'+ Links +'}}';
                    HttpRequest req = new HttpRequest();
                    req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+issuekey, 'PUT' ,'application/json');
                    req.setBody(body1);
                    
                    Http gethttp = new Http();
                    HTTPResponse res;
                    res = gethttp.send(req); 
                    if(res.getStatusCode() == 204){
                    }else{
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('DetailPageController', req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'DetailPageController', res.getbody()));   
                        
                    }
                }
            }
        }catch(Exception ex)
        {
            String Errormsg=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('DetailPageController',null, null, null, null,null, null , null, null, 'DetailPageController', Errormsg));
            
            flag=false;
        }
       if(flag==false) 
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning,System.label.DetailPageController_Label2 +' '+ExpireTime+' '+ System.label.DetailPageController_Label3);
            ApexPages.addMessage(msg);  
            
        }
        
        
    }
    public void InsertJiraLogs(){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
}