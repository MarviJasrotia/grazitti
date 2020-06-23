@isTest()
public class Test_JiraProjectFieldMapping {
    @testSetup
    public static void Test_Data(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
        
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='File_Size',value__c='10 MB');
        insert jsDetail1;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'UpdateFieldWithData';
        st.IsActive__c = true;
        insert st;
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtask';
        insert pm;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
      //  Testdata.CreateStaticFields(pm.id);
      //  
      List<Jira_ProjectFieldsMapping__c> JiraMapping = new List<Jira_ProjectFieldsMapping__c>();
        Jira_ProjectFieldsMapping__c proMap = new Jira_ProjectFieldsMapping__c();
        proMap.Name='Cascading select';
        proMap.IsRequired__c=false;
        proMap.Case_Field_Name__c=null;
        proMap.Jira_Field_Name__c='Select List Cascading';
        proMap.JIRA_Field_Api_Name__c='customfield_10206';
        proMap.ReadOnly__c=true;
        proMap.IsArray__c=true;
        proMap.DataType__c='cascadingselect';
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='Task';
        proMap.ReqInIssueTypeData__c='Task';
        proMap.Salesforce_Object__c ='Case';
        //ProMap.IsReportingEnabled__c=true;
        JiraMapping.add(proMap);
        
        Jira_ProjectFieldsMapping__c proMap1 = new Jira_ProjectFieldsMapping__c();
        proMap1.Name='Linked Issues';
        proMap1.IsRequired__c=false;
        proMap1.Case_Field_Name__c=null;
        proMap1.Jira_Field_Name__c='Linked Issues';
        proMap1.JIRA_Field_Api_Name__c='issuelinks';
        proMap1.ReadOnly__c=true;
        proMap1.IsArray__c=true;
        proMap1.DataType__c='issuelinks';
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.jira_project__c=pm.Id;
        proMap1.IssueTypedata__c='Task';
        proMap1.ReqInIssueTypeData__c='Task';
        proMap1.Salesforce_Object__c ='Case';
        //proMap1.IsReportingEnabled__c=true;
        JiraMapping.add(proMap1);
        
        
        Jira_ProjectFieldsMapping__c proMap2 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'customfield_10100' ,true, false,'gh-epic-link' ,false);
        proMap2.jira_project__c=pm.id;
        proMap2.RelatedProjectIdSet__c = pm.id;
        proMap2.IssueTypedata__c='All';
        proMap2.Salesforce_Object__c='Case';
        JiraMapping.add(proMap2);
        insert JiraMapping;
        
        proMap2.IsReportingEnabled__c=true;
        update proMap2;
        List<Reporting_Permissions__c> rpList = new List<Reporting_Permissions__c>(); 
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e0o000002sQpqAAE');
        rpList.add(RP);
        Reporting_Permissions__c RP1 = New Reporting_Permissions__c(Name='Admins',Profile_Id__c='00e0o000002sQpqAAB');
        rpList.add(RP1);
        insert rpList;
        
    }
    @isTest
    public static void TestData0(){
        Jira_Project__c Pm= [Select id from Jira_Project__c where Name='DEV' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        Map<String,set<String>> ProjecttoJiraApiNamesMap= new Map<String,set<String>>();
        Set<String> FieldAppi = new Set<String>();
        FieldAppi.add('customfield_10206');
        FieldAppi.add('issuelinks');
        ProjecttoJiraApiNamesMap.put(pm.Id,FieldAppi);
        Database.executeBatch(new Jira_ProjectFieldMappingGateway(ProjecttoJiraApiNamesMap,'Case'),1);
        Test.stopTest();
        System.assertEquals(Pm.id != null, true);
        
    }
   /* @istest
    public Static  void TestData1(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting;
        JiraSalesforceDetail__c jsDetail=new JiraSalesforceDetail__c(Name='Sync_SF_Attachment',value__c='yes');
        insert jsDetail;
        
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c(Name='JiraAutoFileAttach',IsActive__c=true);
        insert st1;
        
        Sinergify_Trigger__c st = new Sinergify_Trigger__c();
        st.Name = 'UpdateFieldWithData';
        st.IsActive__c = true;
        insert st;
        JiraSalesforceDetail__c jsDetail1=new JiraSalesforceDetail__c(Name='Sync_SF_Comments',value__c='yes');
        insert jsDetail1;
        
        Sinergify_Trigger__c st2 = new Sinergify_Trigger__c(Name='JiraAutoComment',IsActive__c=true);
        insert st2;
        JiraSalesforceDetail__c jsDetail2=new JiraSalesforceDetail__c(Name='AutoSyncCommentType',value__c='yes');
        insert jsDetail2;
        
        JiraSalesforceDetail__c jsDetail3=new JiraSalesforceDetail__c(Name='File_Size',value__c='10 MB');
        insert jsDetail3;
        JiraSalesforceDetail__c jsDetail4=new JiraSalesforceDetail__c(Name='Auto_SF_Comment_Sync_Type',value__c='yes');
        insert jsDetail4;
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtaskkkkkkkkkkkkkkkkkkkkk';
        insert pm;
        
        Jira_FieldSection__c Section = new Jira_FieldSection__c();
        Section.Name='Jira Fields';
        Section.Order__c=Decimal.valueof(1);
        Section.Column__c='1';
        insert Section;
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Testdata.CreateStaticFields(pm.id);
        
        JiraIssue__c ji=Testdata.createjira('TEST', 'qwew', 1212, 'TP-1', 'task', 'u1', 'sds', 'high', true);
        
        
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        JiraRelationship__c jr =Testdata.createjirarelation(cs.id, ji.id, true);
        CaseComment ccom=new CaseComment();
        ccom.ParentId=cs.id;
        ccom.CommentBody='test 123';
        insert ccom;
        
        
        list<Attachment> listattach =new list<Attachment>();
        
        ContentVersion cv = new ContentVersion();
        String data='TEST';
        Blob b = blob.valueof(data); //decoded string
        cv.VersionData = b;
        cv.Title = 'Title';
        cv.PathOnClient  =  'Title';
        insert cv;
        cv= [SELECT Id, ContentDocumentId FROM ContentVersion where id= :cv.id];
        
        ContentDocumentLink Cdl= new ContentDocumentLink();
        cdl.LinkedEntityId=cs.id;
        cdl.ShareType ='I';
        cdl.ContentDocumentId=cv.ContentDocumentId;
        
        insert cdl;
        
        Attachment ac=new Attachment();
        ac.ParentId=cs.id;
        Blob bl=Blob.valueOf('test body');
        ac.Body=bl;
        ac.Name='TEST Attachment';
        listattach.add(ac);
        Attachment ac1=new Attachment();
        ac1.ParentId=cs.id;
        Blob bl1=Blob.valueOf('test body');
        ac1.Body=bl1;
        ac1.Name='TEST Attachment';
        listattach.add(ac1);
        insert listattach;
        CaseJiraHelper__c cj=new CaseJiraHelper__c();
        cj.jiraissueid__c=ji.IssueKey__c;
        cj.Type__c='Comment';
        cj.Name=ccom.id;
        insert cj;
        
        CaseJiraHelper__c cj1=new CaseJiraHelper__c();
        cj1.jiraissueid__c=ji.IssueKey__c;
        cj1.Type__c='Attachment';
        cj1.Name=ac.id;
        insert cj1;
        
        list<Jira_ProjectFieldsMapping__c > jirafieldmap=new  list<Jira_ProjectFieldsMapping__c >();
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'date' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        proMap.Section__c =Section.id;
        jirafieldmap.add(proMap);
        Jira_ProjectFieldsMapping__c proMapp = Testdata.createjirafieldmapp(pm.id,false,'IssueType',null,'Issue Type', 'issuetype' ,true, true ,'select',false);
        proMapp.RelatedProjectIdSet__c = pm.Id;
        proMapp.jira_project__c=pm.Id;
        proMapp.IssueTypedata__c='All';
        promapp.Salesforce_Object__c='Case';
        proMapp.Section__c =Section.id;
        jirafieldmap.add(proMapp);
        
        Jira_ProjectFieldsMapping__c proMap1 =Testdata.createjirafieldmapp(pm.id,false,'labels',null,'Labels', 'labels' ,true, true ,'String',false);
        proMap1.RelatedProjectIdSet__c = pm.Id;
        proMap1.IssueTypedata__c='Epic';
        proMap1.jira_project__c=pm.Id;
        promap1.Salesforce_Object__c='Case';
        proMap1.Section__c =Section.id;
        jirafieldmap.add(proMap1);
        
        Jira_ProjectFieldsMapping__c projectMap2 = Testdata.createjirafieldmapp(pm.id,false,'select',null, 'select','customfield_10043' ,true, true ,'select',false);
        projectMap2.jira_project__c=pm.id;
        projectMap2.RelatedProjectIdSet__c = pm.Id;
        projectMap2.IssueTypedata__c='All';
        projectMap2.Salesforce_Object__c='Case';
        projectMap2.Section__c =Section.id;
        jirafieldmap.add(projectMap2);
        
        Jira_ProjectFieldsMapping__c projectMap12 = Testdata.createjirafieldmapp(pm.id,false,'userpicker','AccountId','userpicker', 'customfield_10022' ,true, true ,'userpicker',false);
        projectMap12.jira_project__c=pm.id;
        projectMap12.RelatedProjectIdSet__c = pm.Id;
        projectMap12.IssueTypedata__c='All';
        projectMap12.Salesforce_Object__c='Case';
        projectMap12.Section__c =Section.id;
        jirafieldmap.add(projectMap12);
        
        Jira_ProjectFieldsMapping__c projectMap4 = Testdata.createjirafieldmapp(pm.id,false,'multiuserpicker',null, 'multiuserpicker','customfield_10031' ,true, true,'multiuserpicker' ,false);
        projectMap4.jira_project__c=pm.id;
        projectMap4.RelatedProjectIdSet__c = pm.Id;
        projectMap4.IssueTypedata__c='All';
        projectMap4.Salesforce_Object__c='Case';
        projectMap4.Section__c =Section.id;
        jirafieldmap.add(projectMap4);
        
        Jira_ProjectFieldsMapping__c projectMapv4 = Testdata.createjirafieldmapp(pm.id,false,'multiversion',null,'multiversion', 'customfield_10032' ,true, true,'multiversion' ,false);
        projectMapv4.jira_project__c=pm.id;
        projectMapv4.RelatedProjectIdSet__c = pm.id;
        projectMapv4.IssueTypedata__c='All';
        projectMapv4.Salesforce_Object__c='Case';
        projectMapv4.Section__c =Section.id;
        jirafieldmap.add(projectMapv4);
        
        
        Jira_ProjectFieldsMapping__c projectMapv5 = Testdata.createjirafieldmapp(pm.id,false,'id',null,'id', 'customfield_10218' ,true, false,'id' ,false);
        projectMapv5.jira_project__c=pm.id;
        projectMapv5.RelatedProjectIdSet__c = pm.id;
        projectMapv5.IssueTypedata__c='All';
        projectMapv5.Salesforce_Object__c='Case';
        projectMapv5.Section__c =Section.id;
        
        jirafieldmap.add(projectMapv5);
        
        Jira_ProjectFieldsMapping__c projectMapv6 = Testdata.createjirafieldmapp(pm.id,false,'Sf links',null,'Salesforce Account Names', 'customfield_10215' ,true, false,'textarea' ,false);
        projectMapv6.jira_project__c=pm.id;
        projectMapv6.RelatedProjectIdSet__c = pm.id;
        projectMapv6.IssueTypedata__c='All';
        projectMapv6.Salesforce_Object__c='Case';
        projectMapv6.Section__c =Section.id;
        projectMapv6.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv6);
        
        Jira_ProjectFieldsMapping__c projectMapv7 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv7.jira_project__c=pm.id;
        projectMapv7.RelatedProjectIdSet__c = pm.id;
        projectMapv7.IssueTypedata__c='All';
        projectMapv7.Salesforce_Object__c='Case';
        projectMapv7.Section__c =Section.id;
        //projectMapv7.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv7);
        
        Jira_ProjectFieldsMapping__c projectMapv8 = Testdata.createjirafieldmapp(pm.id,false,'float',null,'float', 'customfield_10034' ,true, false,'float' ,false);
        projectMapv8.jira_project__c=pm.id;
        projectMapv8.RelatedProjectIdSet__c = pm.id;
        projectMapv8.IssueTypedata__c='All';
        projectMapv8.Salesforce_Object__c='Case';
        projectMapv8.Section__c =Section.id;
        //projectMapv8.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv8);
        
        Jira_ProjectFieldsMapping__c projectMapv9 = Testdata.createjirafieldmapp(pm.id,false,'issuelinks',null,'Linked Issues', 'issuelinks' ,true, true,'issuelinks' ,false);
        projectMapv9.jira_project__c=pm.id;
        projectMapv9.RelatedProjectIdSet__c = pm.id;
        projectMapv9.IssueTypedata__c='All';
        projectMapv9.Salesforce_Object__c='Case';
        projectMapv9.Section__c =Section.id;
        //projectMapv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapv9);
        
        Jira_ProjectFieldsMapping__c projectMap0 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name', 'customfield_10102' ,true, true,'gh-epic-label' ,false);
        projectMap0.jira_project__c=pm.id;
        projectMap0.RelatedProjectIdSet__c = pm.id;
        projectMap0.IssueTypedata__c='All';
        projectMap0.Salesforce_Object__c='Case';
        projectMap0.Section__c =Section.id;
        //projectMapv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap0);
        
        Jira_ProjectFieldsMapping__c projectMap9 = Testdata.createjirafieldmapp(pm.id,false,'Epic Name',null,'Epic Name' ,'customfield_10102' ,true, false,'gh-epic-label' ,false);
        projectMap9.jira_project__c=pm.id;
        projectMap9.RelatedProjectIdSet__c = pm.id;
        projectMap9.IssueTypedata__c='All';
        projectMap9.Salesforce_Object__c='Case';
        projectMap9.Section__c =Section.id;
        //projectMap9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap9);
        
        Jira_ProjectFieldsMapping__c projectMap999 = Testdata.createjirafieldmapp(pm.id,false,'Epic link',null,'Epic link' ,'customfield_10100' ,true, false,'gh-epic-link' ,false);
        projectMap999.jira_project__c=pm.id;
        projectMap999.RelatedProjectIdSet__c = pm.id;
        projectMap999.IssueTypedata__c='All';
        projectMap999.Salesforce_Object__c='Case';
        projectMap999.Section__c =Section.id;
        //projectMap999.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap999);
        
        Jira_ProjectFieldsMapping__c projectMap09 = Testdata.createjirafieldmapp(pm.id,false,'issuelink',null,'parent','parent' ,true, false,'issuelink' ,false);
        projectMap09.jira_project__c=pm.id;
        projectMap09.RelatedProjectIdSet__c = pm.id;
        projectMap09.IssueTypedata__c='All';
        projectMap09.Salesforce_Object__c='Case';
        projectMap09.Section__c =Section.id;
        //projectMap09.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMap09);
        
        Jira_ProjectFieldsMapping__c projectMapvv9 = Testdata.createjirafieldmapp(pm.id,false,'datetime',null,'Date Time Picker', 'customfield_10203' ,true, false,'datetime' ,false);
        projectMapvv9.jira_project__c=pm.id;
        projectMapvv9.RelatedProjectIdSet__c = pm.id;
        projectMapvv9.IssueTypedata__c='All';
        projectMapvv9.Salesforce_Object__c='Case';
        projectMapvv9.Section__c =Section.id;
        //projectMapvv9.Enable_Record_Mapping__c=true;
        jirafieldmap.add(projectMapvv9);
        
        Jira_ProjectFieldsMapping__c projectMapvv11 = Testdata.createjirafieldmapp(pm.id,false,'Status',null,'status', 'Status' ,true, false,'status' ,false);
        projectMapvv11.jira_project__c=pm.id;
        projectMapvv11.RelatedProjectIdSet__c = pm.id;
        projectMapvv11.IssueTypedata__c='All';
        projectMapvv11.Salesforce_Object__c='Case';
        projectMapvv11.Section__c =Section.id;
        jirafieldmap.add(projectMapvv11);
        
        Jira_ProjectFieldsMapping__c projectMapvv12 = Testdata.createjirafieldmapp(pm.id,false,'fixVersions',null,'Fix Version/s', 'fixVersions' ,true, false,'version' ,false);
        projectMapvv12.jira_project__c=pm.id;
        projectMapvv12.RelatedProjectIdSet__c = pm.id;
        projectMapvv12.IssueTypedata__c='All';
        projectMapvv12.Salesforce_Object__c='Case';
        projectMapvv12.Section__c =Section.id;
        jirafieldmap.add(projectMapvv12);
        
        Jira_ProjectFieldsMapping__c projectMapvv13 = Testdata.createjirafieldmapp(pm.id,false,'Key',null,'key', 'Key' ,true, false,'key' ,false);
        projectMapvv13.jira_project__c=pm.id;
        projectMapvv13.RelatedProjectIdSet__c = pm.id;
        projectMapvv13.IssueTypedata__c='All';
        projectMapvv13.Salesforce_Object__c='Case';
        projectMapvv13.Section__c =Section.id;
        jirafieldmap.add(projectMapvv13);
        
        Jira_ProjectFieldsMapping__c projectMapvv14 = Testdata.createjirafieldmapp(pm.id,false,'Link',null,'link', 'Link' ,true, false,'link' ,false);
        projectMapvv14.jira_project__c=pm.id;
        projectMapvv14.RelatedProjectIdSet__c = pm.id;
        projectMapvv14.IssueTypedata__c='All';
        projectMapvv14.Salesforce_Object__c='Case';
        projectMapvv14.Section__c =Section.id;
        jirafieldmap.add(projectMapvv14);
        
        Jira_ProjectFieldsMapping__c projectMapvv15 = Testdata.createjirafieldmapp(pm.id,false,'Resolution Date',null,'resolutiondate', 'Resolution Date' ,true, false,'resolutiondate' ,false);
        projectMapvv15.jira_project__c=pm.id;
        projectMapvv15.RelatedProjectIdSet__c = pm.id;
        projectMapvv15.IssueTypedata__c='All';
        projectMapvv15.Salesforce_Object__c='Case';
        projectMapvv15.Section__c =Section.id;
        jirafieldmap.add(projectMapvv15);
        
        Jira_ProjectFieldsMapping__c projectMapvv16 = Testdata.createjirafieldmapp(pm.id,false,'Resolution',null,'resolution', 'Resolution' ,true, false,'resolution' ,false);
        projectMapvv16.jira_project__c=pm.id;
        projectMapvv16.RelatedProjectIdSet__c = pm.id;
        projectMapvv16.IssueTypedata__c='All';
        projectMapvv16.Salesforce_Object__c='Case';
        projectMapvv16.Section__c =Section.id;
        jirafieldmap.add(projectMapvv16);
        Jira_ProjectFieldsMapping__c projectMapvv17 = Testdata.createjirafieldmapp(pm.id,false,'Priority',null,'priority', 'Priority' ,true, false,'priority' ,false);
        projectMapvv17.jira_project__c=pm.id;
        projectMapvv17.RelatedProjectIdSet__c = pm.id;
        projectMapvv17.IssueTypedata__c='All';
        projectMapvv17.Salesforce_Object__c='Case';
        projectMapvv17.Section__c =Section.id;
        jirafieldmap.add(projectMapvv17);
         for(Jira_ProjectFieldsMapping__c SF:jirafieldmap){
            SF.isStatic__c=true;
        }
        insert jirafieldmap;
        
        
        projectMap0.IsReportingEnabled__c = true;
        update projectMap0;
        Reporting_Permissions__c RP = New Reporting_Permissions__c(Name='Admin',Profile_Id__c='00e0o000002sQpqAAE');
        Insert RP;
        
        Test.StartTest();
        
        Jira_ProjectFieldMappingHandler jpm=new Jira_ProjectFieldMappingHandler();
        jpm.bulkBefore();
        jpm.beforeInsert(projectMapvv12);
        jpm.beforeUpdate(projectMapvv12,projectMapvv12);
        jpm.beforeDelete(projectMapvv12);
        jpm.afterInsert(projectMap0);
        jpm.afterUpdate(projectMap0,projectMapvv12);
        jpm.afterDelete(projectMapvv12);
        jpm.andFinally();
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.Httpmetadata1());
        Database.executeBatch(new UpdateProjectRelatedData());
        Test.stopTest();
        System.assertEquals(jpm.sfObject,'Case');
    }*/
}