@isTest public class Test_ValidationChecker {
    
    @isTest public static void TestScenerio1(){
        
         JiraSalesforceDetail__c jsd=new JiraSalesforceDetail__c();
        jsd.Name = 'Sync_SF_Attachment';
        jsd.Value__c = 'yes';
        insert jsd;
         
        Sinergify_Trigger__c st1 = new Sinergify_Trigger__c();
        st1.Name = 'JiraAutoFileAttach';
        st1.IsActive__c = true;
        insert st1;
       
        
        jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtaskkkkkkkkkkkkkkkkkkkkk';
        insert pm;
       
        Testdata.CreateJSon(pm.id,pm.ProjectKey__c);
        
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Select List Cascading', 'customfield_10037' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        insert promap;
        
        Case cs =Testdata.createcase('email@test.com', Null, 'New', true);
        Validation__c v= new Validation__c();
        v.FieldNames__c='subject';
        v.name='subject';
        v.object__C='Case';
        insert v;
        ValidationChecker.checker(cs.id);
        PageReference pagref=page.Adminsetting;
        Test.setCurrentPage(pagref);
        ApexPages.currentPage().getParameters().put('movetodata','subject;Status;Account');
        ApexPages.currentPage().getParameters().put('movefromdata','description;status');
        ValidationCaseFields valid= new ValidationCaseFields();
        valid.movefromselected();
        valid.movetoselected();
        valid.save();
        System.assertEquals(Valid.mapsize,true);
        
    }
}