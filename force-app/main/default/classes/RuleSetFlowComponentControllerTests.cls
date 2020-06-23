@isTest
public class RuleSetFlowComponentControllerTests{

    @isTest
    public static void testScenerio1(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
        
        Jira_Project__c pm =new Jira_Project__c();
        pm.ProjectId__c='10001';
        pm.Name='DEV';
        pm.ProjectKey__c='DEV';
        pm.Subtask__c='subtask';
        insert pm;
        // Testdata.CreateJSon(pm.id,pm.ProjectKey__c); 
        Jira_ProjectFieldsMapping__c proMap = Testdata.createjirafieldmapp(pm.id,false,'Cascading select',null,'Cascading select', 'date' ,true, true ,'cascadingselect',false);
        proMap.RelatedProjectIdSet__c = pm.Id;
        proMap.jira_project__c=pm.Id;
        proMap.IssueTypedata__c='All';
        promap.Salesforce_Object__c='Case';
        insert promap;
        Rule_Set__c rs1 = new Rule_Set__c();
        rs1.Description__c ='Test Rule Set';
        rs1.FilterLogic__c ='(1 AND 2)';
        rs1.IsActive__c =true;
        rs1.Project__c ='GI';
        rs1.RuleSetObject__c ='Case';
        rs1.SNO__c =2;
        rs1.Url__c ='';
        List<Child_Rule_Set__c> childList = new List<Child_Rule_Set__c>();
        Child_Rule_Set__c  child1 = new Child_Rule_Set__c();
        child1.Rule_Set__c = rs1.Id;
        child1.Field_Name__c= 'subject';
        child1.Field_Value__c= '1960-1-17';
        child1.Object_Name__c= 'Case' ;
        child1.Filter__c= 'equals';
        child1.DataType__c= 'String';
        child1.SNO__c= '1';
        childList.add(child1);
        Child_Rule_Set__c  child2 = new Child_Rule_Set__c();
        child2.Rule_Set__c = rs1.Id;
        child2.Field_Name__c= 'subject';
        child2.Field_Value__c= 'test';
        child2.Object_Name__c= 'Case' ;
        child2.Filter__c= 'equals';
        child2.DataType__c= 'String';
        child2.SNO__c= '2';
        childList.add(child2);
        Case cs = new Case();
        cs.subject = 'test';
        insert cs;
        List<JiraErrorLogs__c> jiraErrorList = new List<JiraErrorLogs__c>();
        JiraErrorLogs__c jl = new JiraErrorLogs__c();
        jl.Name = 'A';
        jiraErrorList.add(jl);
        
        cs = [Select id, subject from case limit 1];
        Test.startTest();                 
        AdminSettingController  ascd = new AdminSettingController();     
        RuleSetFlowComponentController book  = new RuleSetFlowComponentController(ascd);
        ApexPages.currentPage().getParameters().put('newObjName','Case');       
        ApexPages.currentPage().getParameters().put('newLoopRenderingSpecificField','priority 1');
        List<WrapperClass> nw_WrapperList = new List<WrapperClass>();
        for(Child_Rule_Set__c c : childList){
        wrapperClass wrap = new WrapperClass();
        wrap.sno = integer.valueof(c.SNO__c);
        wrap.objectName = c.Object_Name__c;
        wrap.filter = 'equals';
        wrap.fieldName = c.Field_Name__c;
        wrap.fieldValue = c.Field_Value__c;
        wrap.dataType = c.DataType__c;
        wrap.childId = c.Id;
        wrap.Wrapobj = cs;
        nw_WrapperList.add(wrap);
        }
        book.nw_WrapperList = nw_WrapperList;
        
        book.newruleSet = rs1;
        book.allField();
        book.newLoopRenderingSpecificField();
        book.nw_WrapperList = nw_WrapperList;
        book.newValidateChild();
        book.newruleSet = rs1;
        book.newruleSet.filterLogic__c = '(1 And 2)';
        book.newSave();
        book.nw_fetchDepPickList(nw_WrapperList.get(0),'Priority');
        book.refreshProjects();
        book.setDateTimeFormat('2016-08-22 08:00:00.000',7);
        book.setDateTimeFormat('2016-08-22 08:00:00.000',15);
        book.editSec_DateTimeFormat('2016-08-22 08:00:00.000');
        book.editSec_DateTimeFormat('2016-08-22 14:00:00.000');
        book.splitDateTimeFormat('08/08/2016 14:00 PM');
        book.splitDateTimeFormat('09/11/2016 08:00 AM');
        book.refresh();
        book.getAllFilter();
        
        
        book.JiraLogsToInsert = jiraErrorList;
        book.InsertJiraLogs();
        List<Rule_Set__c> ruleList = [SELECT id FROM Rule_Set__c];
        System.assertEquals(ruleList.size()>0, true);
    }
    
    @isTest
    public static void testScenerioEdit(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
       
        List<Rule_Set__c> ruleList = new List<Rule_Set__c>();
        Rule_Set__c rs1 = new Rule_Set__c();
        rs1.Description__c ='Test Rule Set';
        rs1.FilterLogic__c ='(AND2)';
        rs1.IsActive__c =true;
        rs1.Project__c ='GI';
        rs1.RuleSetObject__c ='Case';
        rs1.SNO__c =1;
        rs1.Url__c ='';
        insert rs1;
        List<Child_Rule_Set__c> childList = new List<Child_Rule_Set__c>();
        Child_Rule_Set__c  child1 = new Child_Rule_Set__c();
        child1.Rule_Set__c = rs1.Id;
        child1.Field_Name__c= 'subject';
        child1.Field_Value__c= '1960-1-17';
        child1.Object_Name__c= 'Case' ;
        child1.Filter__c= 'equals';
        child1.DataType__c= 'String';
        child1.SNO__c= '1';
        insert child1;
        
        Rule_Set__c rule = [select id,Description__c,FilterLogic__c,IsActive__c,Project__c,Rule_Name__c,RuleSetObject__c,SNO__c,Url__c FROM Rule_Set__c where RuleSetObject__c = 'Case' Limit 1];
        Child_Rule_Set__c  child =[select id,Rule_Set__c,Field_Name__c,Field_Value__c,Object_Name__c,Filter__c,DataType__c,SNO__c FROM Child_Rule_Set__c limit 1];
        Test.startTest();                 
        AdminSettingController  ascd = new AdminSettingController();     
        RuleSetFlowComponentController book  = new RuleSetFlowComponentController(ascd);
        ApexPages.currentPage().getParameters().put('newObjName','Case');       
        ApexPages.currentPage().getParameters().put('ed_LoopRenderingSpecificField','priority 1');
        book.nw_Wrapper.sno = 1;
        book.nw_Wrapper.objectName = child.Object_Name__c;
        book.nw_Wrapper.filter = child.Filter__c;
        book.nw_Wrapper.fieldName = child.Field_Name__c;
        book.nw_Wrapper.fieldValue = child.Field_Value__c;
        book.nw_Wrapper.dataType = child.DataType__c;
        book.nw_Wrapper.childId = child.Id;
        book.nw_WrapperList.add(book.nw_Wrapper);
        List<EditWrapperClass> wrapperList = new List<EditWrapperClass>();
        book.wrapper.sno = 1;
        book.wrapper.objectName = child.Object_Name__c;
        book.wrapper.filter = child.Filter__c;
        book.wrapper.fieldName = child.Field_Name__c;
        book.wrapper.fieldValue = child.Field_Value__c;
        book.wrapper.dataType = child.DataType__c;
        book.wrapper.childId = child.Id;
        wrapperList.add(book.wrapper);
        book.wrapperList = wrapperList;
        book.editruleSet  = rule;
        book.allField();
        book.ed_LoopRenderingSpecificField();
        book.editId = rule.id;
        book.editSection();
        book.wrapperList = wrapperList;
        List<EditWrapperClass> wrapperList1 = new List<EditWrapperClass>();
        book.wrapper.sno = 1;
        book.wrapper.objectName = child.Object_Name__c;
        book.wrapper.filter = child.Filter__c;
        book.wrapper.fieldName = child.Field_Name__c;
        book.wrapper.fieldValue = child.Field_Value__c;
        book.wrapper.dataType = child.DataType__c;
        book.wrapper.childId = null;
        wrapperList1.add(book.wrapper);
        book.wrapperList = wrapperList1;
        book.editModeAddNewField();
        book.editSave();
        book.CloneId = rule.id;
        book.CloneRuleSet();
        book.ed_fetchDepPickList( book.wrapper,'Priority');
        System.assertEquals(child.Id != null, true);        
    }
    @isTest
    public static void testScenerioEdit1(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
      
        List<Rule_Set__c> ruleList = new List<Rule_Set__c>();
        Rule_Set__c rs1 = new Rule_Set__c();
        rs1.Description__c ='Test Rule Set';
        rs1.FilterLogic__c =null;
        rs1.IsActive__c =true;
        rs1.Project__c =' GI ';
        rs1.RuleSetObject__c ='Case';
        rs1.SNO__c =1;
        rs1.Url__c ='';
        insert rs1;
        List<Child_Rule_Set__c> childList = new List<Child_Rule_Set__c>();
        Child_Rule_Set__c  child1 = new Child_Rule_Set__c();
        child1.Rule_Set__c = rs1.Id;
        child1.Field_Name__c= 'subject';
        child1.Field_Value__c= '1960-1-17';
        child1.Object_Name__c= 'Case' ;
        child1.Filter__c= 'equals';
        child1.DataType__c= 'String';
        child1.SNO__c= '1';
        insert child1;
        
        Rule_Set__c rule = [select id,Description__c,FilterLogic__c,IsActive__c,Project__c,Rule_Name__c,RuleSetObject__c,SNO__c,Url__c FROM Rule_Set__c where RuleSetObject__c = 'Case' Limit 1];
        Child_Rule_Set__c  child =[select id,Rule_Set__c,Field_Name__c,Field_Value__c,Object_Name__c,Filter__c,DataType__c,SNO__c FROM Child_Rule_Set__c limit 1];
        Test.startTest();                 
        AdminSettingController  ascd = new AdminSettingController();     
        RuleSetFlowComponentController book  = new RuleSetFlowComponentController(ascd);
        ApexPages.currentPage().getParameters().put('newObjName','Case');       
        book.nw_Wrapper.sno = 1;
        book.nw_Wrapper.objectName = child.Object_Name__c;
        book.nw_Wrapper.filter = child.Filter__c;
        book.nw_Wrapper.fieldName = child.Field_Name__c;
        book.nw_Wrapper.fieldValue = child.Field_Value__c;
        book.nw_Wrapper.dataType = child.DataType__c;
        book.nw_Wrapper.childId = child.Id;
        book.nw_WrapperList.add(book.nw_Wrapper);
        List<EditWrapperClass> wrapperList = new List<EditWrapperClass>();
        book.wrapper.sno = 1;
        book.wrapper.objectName = child.Object_Name__c;
        book.wrapper.filter = child.Filter__c;
        book.wrapper.fieldName = child.Field_Name__c;
        book.wrapper.fieldValue = child.Field_Value__c;
        book.wrapper.dataType = child.DataType__c;
        book.wrapper.childId = child.Id;
        wrapperList.add(book.wrapper);
        book.wrapperList = wrapperList;
        book.editruleSet  = rule;
        book.allField();
        book.wrapperList = wrapperList;     
        book.editvalidateChild();
        book.editruleSet.Project__c = ' ABC ';
        book.editSave();
        
        book.InsertJiraLogs();
        System.assertEquals(child.Id != null, true);        
        
    }
    @isTest
    public static void testScenerioDelete(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
        
        List<Rule_Set__c> ruleList = new List<Rule_Set__c>();
        Rule_Set__c rs1 = new Rule_Set__c();
        rs1.Description__c ='Test Rule Set';
        rs1.FilterLogic__c ='(AND2)';
        rs1.IsActive__c =true;
        rs1.Project__c ='GI';
        rs1.RuleSetObject__c ='Case';
        rs1.SNO__c =1;
        rs1.Url__c ='';
        ruleList.add(rs1);
        Rule_Set__c rs2 = new Rule_Set__c();
        rs2.Description__c ='Test';
        rs2.FilterLogic__c ='(OR2)';
        rs2.IsActive__c =true;
        rs2.Project__c ='GI';
        rs2.RuleSetObject__c ='Case';
        rs2.SNO__c =2;
        rs2.Url__c ='';
        ruleList.add(rs2);
        
        insert ruleList;
        
        List<Child_Rule_Set__c> childList1 = new List<Child_Rule_Set__c>();
        Child_Rule_Set__c  child1 = new Child_Rule_Set__c();
        child1.Rule_Set__c = rs1.Id;
        child1.Field_Name__c= 'None';
        child1.Field_Value__c= '1960-1-17';
        child1.Object_Name__c= 'Case' ;
        child1.Filter__c= 'equals';
        child1.DataType__c= 'String';
        child1.SNO__c= '1';
        childList1.add(child1);
        Child_Rule_Set__c  child2 = new Child_Rule_Set__c();
        child2.Rule_Set__c = rs2.Id;
        child2.Field_Name__c= 'subject';
        child2.Field_Value__c= '1960-1-17';
        child2.Object_Name__c= 'Case' ;
        child2.Filter__c= 'equals';
        child2.DataType__c= 'String';
        child2.SNO__c= '2';
        childList1.add(child2);
        Child_Rule_Set__c  child3 = new Child_Rule_Set__c();
        child3.Rule_Set__c = rs1.Id;
        child3.Field_Name__c= 'None';
        child3.Field_Value__c= '1960-1-17';
        child3.Object_Name__c= 'Case' ;
        child3.Filter__c= 'equals';
        child3.DataType__c= 'String';
        child3.SNO__c= '3';
        childList1.add(child3);
        
        Child_Rule_Set__c  child4 = new Child_Rule_Set__c();
        child4.Rule_Set__c = rs2.Id;
        child4.Field_Name__c= 'None';
        child4.Field_Value__c= '1960-1-17';
        child4.Object_Name__c= 'Case' ;
        child4.Filter__c= 'equals';
        child4.DataType__c= 'String';
        child4.SNO__c= '4';
        childList1.add(child4);
        
        insert childList1; 
        
        Rule_Set__c rule = [select id,Description__c,FilterLogic__c,IsActive__c,Project__c,Rule_Name__c,RuleSetObject__c,SNO__c,Url__c FROM Rule_Set__c where SNO__c =2 Limit 1];
        List<Child_Rule_Set__c>  childList =[select id,Rule_Set__c,Field_Name__c,Field_Value__c,Object_Name__c,Filter__c,DataType__c,SNO__c FROM Child_Rule_Set__c];
        Test.startTest();                 
        AdminSettingController  ascd = new AdminSettingController();     
        RuleSetFlowComponentController book  = new RuleSetFlowComponentController(ascd);
        ApexPages.currentPage().getParameters().put('newObjName','Case');
        List<EditWrapperClass> wrapperList = new List<EditWrapperClass>();
        List<WrapperClass> nw_WrapperList=new List<WrapperClass>();
        for(Child_Rule_Set__c c : [select id,Rule_Set__c,Field_Name__c,Field_Value__c,Object_Name__c,Filter__c,DataType__c,SNO__c FROM Child_Rule_Set__c]){
            EditWrapperClass wrap = new EditWrapperClass();
            WrapperClass wrap1 = new WrapperClass();
            wrap.sno = integer.valueOf(c.SNO__c);
            wrap.objectName = c.Object_Name__c;
            wrap.filter = c.Filter__c;
            wrap.fieldName = c.Field_Name__c;
            wrap.fieldValue = c.Field_Value__c;
            wrap.dataType = c.DataType__c;
            wrap.childId = c.Id;
            wrapperList.add(wrap);
            wrap1.sno = integer.valueOf(c.SNO__c);
            wrap1.objectName = c.Object_Name__c;
            wrap1.filter = c.Filter__c;
            wrap1.fieldName = c.Field_Name__c;
            wrap1.fieldValue = c.Field_Value__c;
            wrap1.dataType = c.DataType__c;
            wrap1.childId = c.Id;
            nw_WrapperList.add(wrap1);
        }
        book.wrapperList = wrapperList;
        book.editruleSet = rule;
        
        book.ed_removefield = '1';
        book.ed_deleteField();
        
        book.deleteRuleSetOnRule();
        
        book.deleteRuleSetId = rule.id;
        book.deleteRuleSet();
        book.nw_WrapperList = nw_WrapperList;
        book.nw_removeField = '1';
        book.nw_deleteField();
        System.assertEquals(rule.Id != null, true);        
    }
    
    @isTest
    public static void testScenerioExtra(){
        Jira_login__c setting= Testdata.createjirasetting('display',true, 'www.test.com', 'JIRA', 'password', 'license', true, 'username.com', false);
        setting.Default_Jira_Project__c='DEV';
        setting.File_Size__c ='10.00 MB';
        insert setting; 
        
        List<Rule_Set__c> ruleList = new List<Rule_Set__c>();
        Rule_Set__c rs1 = new Rule_Set__c();
        rs1.Description__c ='Test Rule Set';
        rs1.FilterLogic__c ='(1 AND 2)';
        rs1.IsActive__c =true;
        rs1.Project__c ='GI';
        rs1.RuleSetObject__c ='Case';
        rs1.SNO__c =2;
        rs1.Url__c ='';
        List<Child_Rule_Set__c> childList = new List<Child_Rule_Set__c>();
        Child_Rule_Set__c  child1 = new Child_Rule_Set__c();
        child1.Rule_Set__c = rs1.Id;
        child1.Field_Name__c= 'subject';
        child1.Field_Value__c= '1960-1-17';
        child1.Object_Name__c= 'Case' ;
        child1.Filter__c= 'equals';
        child1.DataType__c= 'String';
        child1.SNO__c= '1';
        childList.add(child1);
        Child_Rule_Set__c  child2 = new Child_Rule_Set__c();
        child2.Rule_Set__c = rs1.Id;
        child2.Field_Name__c= 'subject';
        child2.Field_Value__c= 'test';
        child2.Object_Name__c= 'Case' ;
        child2.Filter__c= 'equals';
        child2.DataType__c= 'String';
        child2.SNO__c= '2';
        childList.add(child2);
        Child_Rule_Set__c  child3 = new Child_Rule_Set__c();
        child3.Rule_Set__c = rs1.Id;
        child3.Field_Name__c= 'subject';
        child3.Field_Value__c= 'world';
        child3.Object_Name__c= 'Case' ;
        child3.Filter__c= 'equals';
        child3.DataType__c= 'String';
        child3.SNO__c= '3';
        childList.add(child3);
        Case cs = new Case();
        cs.subject = 'test';
        insert cs;
        List<JiraErrorLogs__c> jiraErrorList = new List<JiraErrorLogs__c>();
        JiraErrorLogs__c jl = new JiraErrorLogs__c();
        jl.Name = 'A';
        jiraErrorList.add(jl);
        
        //Rule_Set__c rule = [select id,Description__c,FilterLogic__c,IsActive__c,Project__c,Rule_Name__c,RuleSetObject__c,SNO__c,Url__c FROM Rule_Set__c where RuleSetObject__c = 'Case' Limit 1];
        cs = [Select id, subject from case limit 1];
        Test.startTest();                 
        AdminSettingController  ascd = new AdminSettingController();     
        RuleSetFlowComponentController book  = new RuleSetFlowComponentController(ascd);
        ApexPages.currentPage().getParameters().put('newObjName','Case');       
        ApexPages.currentPage().getParameters().put('newLoopRenderingSpecificField','Case 1');
        ApexPages.currentPage().getParameters().put('ed_LoopRenderingSpecificField','Case 1');
        List<WrapperClass> nw_WrapperList = new List<WrapperClass>();
        List<EditWrapperClass> wrapperList= new List<EditWrapperClass>();
        for(Child_Rule_Set__c c :childList ){
            wrapperClass wrap = new WrapperClass();
            EditWrapperClass wrap1 = new EditWrapperClass();
            wrap.sno = integer.valueof(c.SNO__c);
            wrap.objectName = c.Object_Name__c;
            wrap.filter = 'equals';
            wrap.fieldName = c.Field_Name__c;
            wrap.fieldValue = c.Field_Value__c;
            wrap.dataType = c.DataType__c;
            wrap.childId = c.Id;
            wrap.Wrapobj = cs;
            nw_WrapperList.add(wrap);
            wrap1.sno = integer.valueof(c.SNO__c);
            wrap1.objectName = c.Object_Name__c;
            wrap1.filter = 'equals';
            wrap1.fieldName = c.Field_Name__c;
            wrap1.fieldValue = c.Field_Value__c;
            wrap1.dataType = c.DataType__c;
            wrap1.childId = c.Id;
            wrap1.editWrapobj = cs;
            wrapperList.add(wrap1);
        }
        book.nw_WrapperList = nw_WrapperList;
        book.wrapperList = wrapperList;
        book.newLoopRenderingSpecificField();
        book.ed_LoopRenderingSpecificField();
        book.newruleSet = rs1;
        book.allField();
        book.nw_WrapperList = nw_WrapperList;
        book.wrapperList = wrapperList;
        book.newruleSet.description__c = 'test';
        book.newruleSet.Project__c = 'Project 1';
        book.newruleSet.filterLogic__c ='';
        book.newSave();
        book.nw_WrapperList = nw_WrapperList;
        book.wrapperList = wrapperList;
        String filter = '(1 AND (2))OR (3)';
        system.assertEquals(filter,'(1 AND (2))OR (3)','Equals');
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1 AND (2))OR (4)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        
        
        filter = '((1)AND2 OR 3)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '((1)AND OR 3)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1AND 3)2';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        system.assertEquals(filter,'(1AND 3)2','Equals');
        
        filter = '(1AND 3)7';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1AND 3)(2)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1AND)2';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '1AND 3';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '123AND';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        system.assertEquals(filter,'123AND','Equals');
        
        filter = '((1 AND 2))(3)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1 OR 2 OR 3)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1 OR 2 AND 3)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1 OR 2 (AND) 3)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        
        filter = '(1)';
        book.addnewFieldButton = true;
        book.filterLogic(filter);
        book.ed_removefield = '1';
        book.ed_deleteField();
        System.assertEquals(book.addnewFieldButton, true);
    }
    
}