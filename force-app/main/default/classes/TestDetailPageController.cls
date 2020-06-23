@isTest
public class TestDetailPageController {
    @testSetup
    public static void testdata(){
        Jira_login__c jira= Testdata.createjirasetting('display',true, 'test.com', 'JIRA', 'password', 'license', true, 'username', false);
        jira.Default_Jira_Project__c='DP';
        jira.LoginSuccess__c=true;
        insert jira;
        
        Sinergify_Trigger__c stc = new Sinergify_Trigger__c(Name='JiraAutoFileAttach', IsActive__c = true);
        insert stc;
        
        List<JiraSalesforceDetail__c> jsDetails = new List<JiraSalesforceDetail__c>();
        
        JiraSalesforceDetail__c jsDetail1 
            = new JiraSalesforceDetail__c(Name='SalesForceDomain', 
                                          Value__c = 'http://grz_sf__sfjira-developer-edition.ap0.force.com');
        jsDetails.add(jsDetail1 );
        JiraSalesforceDetail__c jsDetail2 
            = new JiraSalesforceDetail__c(Name='TimeStamp', 
                                          Value__c = '111111');
        jsDetails.add(jsDetail2 );
        JiraSalesforceDetail__c jsDetail3 
            = new JiraSalesforceDetail__c(Name='Sync_SF_Attachment', 
                                          Value__c = 'yes');
        jsDetails.add(jsDetail3 );
        
        insert jsDetails; 
        Jira_Project__c proj=TestData.createjiraProject('101','Test','DP');
        Testdata.CreateJSon(proj.id,proj.ProjectKey__c); 
        Jira_Project__c proj1=TestData.createjiraProject('102','Test','TP');
        Testdata.CreateJSon(proj1.id,proj1.ProjectKey__c); 
        
        Testdata.CreateStaticFields(proj.id);
        Testdata.CreateStaticFields(proj1.id);
        List<Jira_ProjectFieldsMapping__c> jpList = new List<Jira_ProjectFieldsMapping__c>();
        Jira_ProjectFieldsMapping__c jiramapping=new Jira_ProjectFieldsMapping__c();
        jiramapping.Enable_Record_Mapping__c=true;
        jiramapping.Salesforce_Object__c='Idea';
        jiramapping.DataType__c='gh-epic-link';
        jiramapping.JIRA_Field_Api_Name__c='Customfield_10502';
        jiramapping.Jira_Project__c=proj.Id;
        jpList.add(jiramapping);
        Jira_ProjectFieldsMapping__c jiramapping1=new Jira_ProjectFieldsMapping__c();
        jiramapping1.Enable_Record_Mapping__c=true;
        jiramapping1.Salesforce_Object__c='Idea';
        jiramapping1.DataType__c='gh-epic-link';
        jiramapping1.JIRA_Field_Api_Name__c='Customfield_10502';
        jiramapping1.Jira_Project__c=proj1.Id;
        jpList.add(jiramapping1);
        insert jpList;
    }
    @isTest
    public static  void DetailPageTest(){
        Account acc =new Account();
        acc.name='New Test Acc';
        insert acc; 
        
        
        Case cs = Testdata.createcase('testemail@test.com', acc.Id, 'In Progress', true);
        
        cs  = [SELECT Id, CaseNumber FROM Case WHERE Id = :cs.Id];
        String caseNumKey = createCaseNumKey(cs.Id, 'GC-1057');
        
        JiraIssue__c ji = createJiraIssue('GC-1057', caseNumKey,cs.CaseNumber);
        ji.Project__c = 'DP';
        insert ji;
        
        test.startTest();
        apexpages.currentpage().getparameters().put('id' , caseNumKey);
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        DetailPageController controller = new DetailPageController() ;
        test.stopTest();
        System.assertEquals(!controller.renew,true);
        
    }
    @istest
    public static void DetailPageTest1(){
        Account acc =new Account();
        acc.name='New Test Acc';
        insert acc; 
        
        
        Case cs = Testdata.createcase('testemail@test.com', acc.Id, 'In Progress', true);
        
        cs  = [SELECT Id, CaseNumber FROM Case WHERE Id = :cs.Id];
        String caseNumKey = createCaseNumKey0(cs.Id, 'GC-1057');
        
        JiraIssue__c ji = createJiraIssue('GC-1057', caseNumKey,cs.CaseNumber);
        ji.Project__c = 'DP';
        insert ji;
        
        test.startTest();
        apexpages.currentpage().getparameters().put('id' , caseNumKey);
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        DetailPageController controller = new DetailPageController() ;
        test.stopTest();
        System.assertEquals(!controller.renew,false);
        
    } @istest
    public static void DetailPageTest2(){
        Account acc =new Account();
        acc.name='New Test Acc';
        insert acc; 
        
        
        Case cs = Testdata.createcase('testemail@test.com', acc.Id, 'In Progress', true);
        
        cs  = [SELECT Id, CaseNumber FROM Case WHERE Id = :cs.Id];
        String caseNumKey = createCaseNumKey1(cs.Id, 'GC-1057');
        
        JiraIssue__c ji = createJiraIssue('GC-1057', caseNumKey,cs.CaseNumber);
        ji.Project__c = 'DP';
        insert ji;
        
        test.startTest();
        apexpages.currentpage().getparameters().put('id' , caseNumKey);
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        DetailPageController controller = new DetailPageController() ;
        test.stopTest();
        System.assertEquals(!controller.renew,false);
        
    }
    public static String createCaseNumKey0(String caseNum, String issueKey) {
        Datetime dateGMT=System.now();
        //dateGMT=dateGMT.addMinutes();
        string time1=String.valueof(dateGMT);
        String temp11=caseNum+','+time1+','+issuekey;
        temp11=temp11.replaceAll(' ','----');
        Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
        Blob clearData=Blob.valueOf(temp11);
        String caseNumKey=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
        return caseNumKey;
    }
    public static String createCaseNumKey(String caseNum, String issueKey) {
        Datetime dateGMT=System.now();
        dateGMT=dateGMT.addMonths(7);
        dateGMT=dateGMT.addhours(7);
        string time1=String.valueof(dateGMT);
        String temp11=caseNum+','+time1+','+issuekey;
        temp11=temp11.replaceAll(' ','----');
        Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
        Blob clearData=Blob.valueOf(temp11);
        String caseNumKey=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
        return caseNumKey;
    }
     public static String createCaseNumKey1(String caseNum, String issueKey) {
        Datetime dateGMT=System.now();
        dateGMT=dateGMT.addMonths(-7);
        dateGMT=dateGMT.addhours(7);
        string time1=String.valueof(dateGMT);
        String temp11=caseNum+','+time1+','+issuekey;
        temp11=temp11.replaceAll(' ','----');
        Blob encryptionKey = BLob.valueOf(EncodingUtil.convertToHex(BLob.valueOf('GRSJ@198')));
        Blob clearData=Blob.valueOf(temp11);
        String caseNumKey=EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', encryptionKey, clearData));
        return caseNumKey;
    }
    
    public static JiraIssue__c createJiraIssue(String name, String caseNumKey,String CaseVal) {
        JiraIssue__c ji = new JiraIssue__c();
        ji.Name=name;
        String val='http://grz_sfjira-developer-edition.ap0.force.com/apex/Grz_Sf__detailPage?id=' + caseNumKey;
        
        ji.JsonData__c='{"key":"GC-1057","id":"11765","fields":{"Customfield_10502":"' + val + '"}}';
        ji.IssueId__c=121212;
        ji.IssueKey__c=name; 
        ji.IssueType__c='Task';
        return ji;
    }
    
}