@isTest
public class Test_JiraIssueRelationshipHandler {
    
  @isTest
    public static void TestScenerio1(){
        List<JiraSalesforceDetail__c> jsDetails = new List<JiraSalesforceDetail__c>();
        
        JiraSalesforceDetail__c jsDetail1 
            = new JiraSalesforceDetail__c(Name='SalesForceDomain', 
                                          Value__c = 'http://grz_sfjira-developer-edition.ap0.force.com');
        jsDetails.add(jsDetail1 );
        insert jsDetails;  
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.LoginSuccess__c=true;
        insert setting;
        
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraRelationshipTrigger';
        st.IsActive__c = true;
        insert st;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;
        
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);

        String accKey1 = createCaseNumKey(cs.id, 'GC-1057');
        String val='[http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey1+']';
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10037":"'+ ac.id +'"}}';
        Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10218":"'+ val +'"}}';
        Ji1.Project__c='DEV';
        insert ji1;
        
        
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='Development';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='Sub-Task';
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        
        Testdata.CreateStaticFields(pm.id);
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        promap.Enable_Record_Mapping__c=true;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'Labels',null,'labels', 'labels' ,true, true ,'labels',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        promap1.Enable_Record_Mapping__c=true;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null,'select' ,'customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.Salesforce_Object__c='Case';
        projectMap2.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker',null,'userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='Case';
        projectMap12.Enable_Record_Mapping__c=true;
        //jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null,'multiuserpicker', 'customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Enable_Record_Mapping__c=true;
        // jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'datepicker',null,'datepicker', 'customfield_10219' ,true, true,'datepicker' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv6);
        
        
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null, 'float','customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.Salesforce_Object__c='Idea';
        projectMapv8.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'issuelinks', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        
        jirafieldmap.add(projectMapv9);
        
        insert jirafieldmap;
        
        projectMapv9.IsReportingEnabled__c = true;
        update projectMapv9;
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e7F000002XGpK');
        Insert RP;
        
        
        
        Account ac1 = [select id ,Name from Account Where Name='test'];
        
        JiraIssue__c ji11=[select id,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10018 limit 1];
        
        String accKey = createCaseNumKey(cs1.id, 'GC-1057');
        
        String valu='[http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey+']';
        ji11.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10218":"' + valu + '"}}';
        
        update ji11;
        JiraIssueRelationshipHandler JiraRel=new JiraIssueRelationshipHandler();
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
        test.stopTest();
        JiraIssue__c Jissue =[Select id,casenos__c from JiraIssue__c where id =:ji.id ];
        System.assertEquals(Jissue.casenos__c,null);
    }
    
    @isTest
    public static void TestScenerio2(){
        List<JiraSalesforceDetail__c> jsDetails = new List<JiraSalesforceDetail__c>();
        
        JiraSalesforceDetail__c jsDetail1 
            = new JiraSalesforceDetail__c(Name='SalesForceDomain', 
                                          Value__c = 'http://grz_sfjira-developer-edition.ap0.force.com');
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='CreateLinks', 
                                          Value__c = 'YES');
        jsDetails.add(jsDetail1 );
        jsDetails.add(jsDetail2 );
        insert jsDetails;  
        
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.LoginSuccess__c=true;
        
        insert setting; 
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        
         Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'JiraRelationshipTrigger';
        st.IsActive__c = true;
        insert st;
        
        Rule_Set__c rule=Testdata.Newruleset('test', '1', true, 'DEV',  'rulename' ,1,True);
        Child_Rule_Set__c child= Testdata.Newchildruleset('STRING','suppliedemail','', 'not equal to', rule,'1',true);
        Account ac = new account(name='test');
        insert ac;
        
        Case cs =Testdata.createcase('email@test.com', String.ValueOf(ac.id), 'New', true);
        Case cs1 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        Case cs3 =Testdata.createcase('', String.valueof(ac.id), 'working', true);
        
        String accKey1 = createCaseNumKey(cs.id, 'GC-1057');
        
        String val='[http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey1+']';
        JiraIssue__c ji=Testdata.createjira('test', 'test', 10019, '1002', 'Task', 'u1', 'sds', 'high', false);
        ji.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10215":"'+ ac.id +'"}}';
        Ji.Project__c='DEV';
        insert ji;
        JiraIssue__c ji1=Testdata.createjira('test1', 'test1', 10018, '1003', 'Task', 'u1', 'sds', 'high', false);
        ji1.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10218":"'+ val +'"}}';
        Ji1.Project__c='DEV';
        insert ji1;
        
        
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='Development';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='Sub-Task';
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        
        Testdata.CreateStaticFields(pm.id);
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        //promap.Enable_Record_Mapping__c=true;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'Labels',null,'labels' , 'labels' ,true, true ,'labels',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
       // promap1.Enable_Record_Mapping__c=true;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null,'select', 'customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.Salesforce_Object__c='Case';
       // projectMap2.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker',null,'userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='Case';
        //projectMap12.Enable_Record_Mapping__c=true;
        //jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null,'multiuserpicker', 'customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Enable_Record_Mapping__c=true;
        // jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        //projectMapv4.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'Salesforce Links',null,'id', 'customfield_10218' ,true, false,'TextArea' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'datepicker',null,'datepicker', 'customfield_10219' ,true, true,'datepicker' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.Salesforce_Object__c='Case';
        //projectMapv6.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv6);
        
        
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.Salesforce_Object__c='Idea';
       // projectMapv8.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'issuelinks', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        
        jirafieldmap.add(projectMapv9);
        
        insert jirafieldmap;
        
        projectMapv9.IsReportingEnabled__c = true;
        update projectMapv9;
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e7F000002XGpK');
        Insert RP;
        
        Account ac1 = [select id ,Name from Account Where Name='test'];
        
        JiraIssue__c ji11=[select id,Summary__c,Priority__c,JsonData__c,Jira_Link__c,IssueKey__c,Reporter__c,Status__c,Assignee__c from JiraIssue__c  where Issueid__c=10018 limit 1];
        
        String accKey = createCaseNumKey(cs.id, 'GC-1057');
        String accKey2 = createCaseNumKey(cs1.id, 'GC-1057');
        
        String valu='[http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey+']';
        
        valu +='\\n [http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + accKey2+']';
        ji11.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"customfield_10218":"' + valu + '"}}';
        
        update ji11;
        
        
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji11.id, true);
        JiraRelationship__c jr1= Testdata.createjirarelation(cs1.id, ji1.id, true);
        JiraRelationship__c jr2= Testdata.createjirarelation(cs3.id, ji1.id, true);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        String obj='case';
       
        JiraRelationship__c jRel=[Select id ,CaseRelation__c from JiraRelationship__c where CaseRelation__c=:cs.id];
        delete jRel;
        Delete jr2;
      
        test.stopTest();
        JiraIssue__c Jissue =[Select id,casenos__c from JiraIssue__c where id =:ji11.id ];
        System.assertEquals(Jissue.casenos__c,null);
    }
  
    public static String createCaseNumKey(String Num, String issueKey) {
        Datetime dateGMT=System.now();
        dateGMT=dateGMT.addMinutes(1);
        string time1=String.valueof(dateGMT);
        String temp11=Num+','+time1+','+issuekey;
        temp11=temp11.replaceAll(' ','----');
        Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
        Blob clearData=Blob.valueOf(temp11);
        String caseNumKey=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
        
        return caseNumKey;
    }
}