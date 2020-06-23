({
	getDoItData : function(component,event) {
		console.log('helper');  
        var action = component.get('c.getjiraissues');
        action.setParams({
           "recordId" : component.get("v.recordId")
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                component.set("v.mydata",result.sobList);
                var v=component.get("v.mydata");
                component.set("v.mycolumns",result.ldwList);
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            component.set("v.loading",false);

        }); 
        
        $A.enqueueAction(action);
        component.set("v.loading",true);

	},
    
    ViewJiraIssue:function(component, event){
        var rows = event;
        var caseID=component.get("v.recordId");
        var name=rows.Id;
        var workspaceAPI = component.find("workspace");
        workspaceAPI
        .isConsoleNavigation()
        .then(function(isConsole) {
            if (isConsole) {
                workspaceAPI.openTab({
                    url: '/lightning/r/case/'+caseID+'/view',
                    focus: true
                }).then(function(response) {
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url: '/apex/Grz_Sf__ViewJira?jirakey='+rows.Name+'&genericObjectID='+caseID+'&id='+rows.Id,
                        focus: true
                    });
                }) 
            }else
            {
                window.open('/apex/Grz_Sf__ViewJira?jirakey='+rows.Name+'&genericObjectID='+caseID+'&id='+rows.Id);        
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    removeJira : function(component, event){
        var rows = event;
        var objId=component.get("v.recordId");
        var action=component.get("c.unlinkjira")
        
        action.setParams({
            'genericObjectID':component.get("v.recordId"),
            'jiraId':rows.Id  
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //window.open('/'+objId,"_Top");
                this.getDoItData(component,event);
            }else{
                component.set("v.loading",false);
            }
        });
        $A.enqueueAction(action);
        component.set("v.loading",true);
 
    },
})