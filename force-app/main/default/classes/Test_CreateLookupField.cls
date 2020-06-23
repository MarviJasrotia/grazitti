@isTest
public class Test_CreateLookupField {
    
    public Static TestMethod void TestData(){
        List<String> selectedObject=new List<string>();
        selectedObject.add('Grz_Sf__OpportunityRelation__c');
        
        set<String> sfObjects=new set<String>();
        sfObjects.add('Opportunity');
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtaskkkkkkkkkkkkkkkkkkkkk';
        insert pm;
        Boolean NotEmpty=false;
        Test.setMock(HttpCalloutMock.class, new Test_HttpResponse.HttpMetaData());
        
        CreateLookUpFieldsandGivePermissions lookup=new CreateLookUpFieldsandGivePermissions(sfObjects,'101',selectedObject);
        Test.startTest();
        ID batchprocessid = Database.executeBatch(lookup);
        if(batchprocessid!=null){
            NotEmpty=true;
        }
        Test.stopTest();
        System.assertEquals(NotEmpty,true);
    }
}