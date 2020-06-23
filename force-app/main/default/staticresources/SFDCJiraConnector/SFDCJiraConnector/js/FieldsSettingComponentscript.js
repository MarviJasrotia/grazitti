function inputLimiter(e,allow) {
            var AllowableCharacters = '';
            
            if (allow == 'Letters'){AllowableCharacters=' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';}
            if (allow == 'Numbers'){AllowableCharacters='1234567890';}
            if (allow == 'NameCharacters'){AllowableCharacters=' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-.\'';}
            if (allow == 'NameCharactersAndNumbers'){AllowableCharacters='1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-\'';}
            if (allow == 'Currency'){AllowableCharacters='1234567890.';}
            
            var k = document.all?parseInt(e.keyCode): parseInt(e.which);
            if (k!=13 && k!=8 && k!=0){
                if ((e.ctrlKey==false) && (e.altKey==false)) {
                    return (AllowableCharacters.indexOf(String.fromCharCode(k))!=-1);
                } else {
                    return true;
                }
            } else {
                return true;
            }
        } 
		function ProjectIdToName(data){
        
        var Projectkey='{!ProjectIdkey}'; 
        var Projectkey=JSON.parse(Projectkey);
        var Projectname='';
        var choosendProject=data.split(',');
        for(var p=0;p<choosendProject.length;p++){
            if(Projectkey[choosendProject[p]]!=null)
                Projectname=Projectname+Projectkey[choosendProject[p]].Name+',';    
        }
        
        if(Projectname.slice(-1)==','){
            Projectname=Projectname.slice(0, -1);
        }
        return Projectname;
    }
    
    $( document ).ready(function() {
        console.log('--->'+'{!$Component.testttt}');
        console.log('--->'+document.getElementById('{!$Component.testttt}'));
        var showObj = document.getElementById('proLabel');
        var e = document.getElementById('{!$Component.testttt}');
        var strUser = e.options[e.selectedIndex].text;
        showObj.innerText = strUser;
        //$('#projli li:first-child').addClass('active');
        //$('#projfield div:first-child').addClass('in');
        //$('#projfield div:first-child').addClass('active');
    });
    
    
    
    $(document).on('click', function(evt) {
        if(!evt.target.classList.contains('projdivholder') &&  !evt.target.classList.contains('plus') && !evt.target.classList.contains('prodiv')){
            $('.projdivholder').css('display','none'); 
        }
    });
    var saveindex;
    
    function save(index,idset){
        saveindex=index;
        var pro=index.split('_');
        pro=pro[2];
        var row='#row'+idset;
        var input='#row'+idset +' input';
        var inputselect='#row'+idset +' select';
        
        var success=true;
        var inputset=$(input);
        var selectset=$(inputselect);
        var section=idset.split('_');
        console.log('value-->'+inputset[0].value);
        if(section[0] == 'req' && inputset[0].value == ''){
            $(inputset[0]).css("box-shadow","rgb(0, 0, 0) 0 0px 5px 0");
            success=false;    
        }
        if(section[0]!= 'req' ){
            for(var i=0;i<inputset.length;i++){
                if((pro=='All' && (i==0 || i==2))||(pro!='All' && i==0)){
                    if(  inputset[i].value==''){
                        $(inputset[i]).css("box-shadow","rgb(0, 0, 0) 0 0px 5px 0");
                        success=false;       
                    }
                }
            }
            
            for(var i=0;i<selectset.length;i++){
                
                if((pro=='All' && (i==0 || i==1))||(pro!='All' && i==0)){ 
                    if(selectset[i].value==''){
                        $(selectset[i]).css("box-shadow","rgb(0, 0, 0) 0 0px 5px 0");   
                        success=false;       
                    }
                }
            }
        }
        
        if(success){
            showProcessing
            savefield(index);
        }else{
            alert('Please fill all the values ');
        }
    }
    
    function CommonClick(proj){
       
        var index= document.getElementById('CommonSave').value;
        var success=true;
        var op = document.getElementById('rowop_0');
        var add = document.getElementById('rowwom_0');
        if(op != null){
            if(document.getElementById("rowop_0").querySelectorAll("input")[0] != 'undefined'){
                var op1= document.getElementById("rowop_0").querySelectorAll("input")[0].value;
                op1 = op1.trim();
            }
            if(document.getElementById("rowop_0").querySelectorAll("input")[1] != 'undefined'){
                var op2 = document.getElementById("rowop_0").querySelectorAll("input")[1].value;
                op2 = op2.trim();
            }
            if(document.getElementById("rowop_0").querySelectorAll("select")[0] != 'undefined'){
                var op3 = document.getElementById("rowop_0").querySelectorAll("select")[0].value;
                op3 = op3.trim();
            }
            if(document.getElementById("rowop_0").querySelectorAll("select")[1] != 'undefined'){
                var op4 = document.getElementById("rowop_0").querySelectorAll("select")[1].value;
                op4 = op4.trim();
            }
            
            if(proj == 'All'){
                if(op1.length != 0 && op2.length != 0 && op3.length != 0 && op4 != 'None'){
                    index = index + 'op_0_'+'{!selectpro}';
                }else if(op1.length == 0 && op2.length == 0 && op3.length == 0 && op4 == 'None'){
                    success=true;
                }else if(op1.length == 0 || op2.length == 0 || op3.length == 0 || op4 == 'None'){
                    success=false;
                }
                if(!success){
                    alert('Please fill all the values ');
                }
            }else{
                if(op1.length != 0 && op3.length != 0 && op4.length != 0){
                    index = index + 'op_0_'+proj;
                }else if(op1.length == 0 && op2.length == 0 && op4.length == 0){
                    success=true;
                }else if(op1.length == 0 || op2.length == 0 || op4.length == 0){
                    success=false;
                }
                if(!success){
                    alert('Please fill all the values ');
                }
            }
        }
        if(add != null){
            if(document.getElementById("rowwom_0").querySelectorAll("input")[0] != 'undefined'){
                var add1= document.getElementById("rowwom_0").querySelectorAll("input")[0].value;
                add1 = add1.trim();
                console.log(add1);
            }
            
            if(document.getElementById("rowwom_0").querySelectorAll("select")[0] != 'undefined'){
                var add2 = document.getElementById("rowwom_0").querySelectorAll("select")[0].value;
                add2 = add2.trim();
                console.log(add2);
            }
            
            if(proj == 'All'){
                if(add1.length != 0 && add2.length != 0){
                    index = index + 'wom_0_'+proj;
                }else if(add1.length == 0 && add2.length == 0){
                    success=true;
                }else if(add1.length == 0 || add2.length == 0){
                    success=false;
                }
                if(!success){
                    alert('Please fill all the values ');
                }
            }else{
                if(add1.length != 0 && add2.length != 0){
                    index = index + 'wom_0_'+proj;
                }else if(add1.length == 0 && add2.length == 0){
                    success=true;
                }else if(add1.length == 0 || add2.length == 0){
                    success=false;
                }
                if(!success){
                    alert('Please fill all the values ');
                }
            }
            
            
        }
        console.log('Optional-->'+document.getElementById('rowop_0'));
        console.log('Optional-->'+document.getElementById('rowwom_0'));
        
        var data=index.split(',');
        
        for(var j=0;j<data.length;j++){
            
            var idset=data[j].substring(0,data[j].lastIndexOf('_'));
            
            var row='#row'+idset;
            var input='#row'+idset +' input';
            var inputselect='#row'+idset +' select';
            
            
            var inputset=$(input);
            var selectset=$(inputselect);
            var section=idset.split('_');
            console.log('section--'+section[0]);
            console.log('inputset--'+inputset[0]);
            
            if(section[0] == 'req' && inputset[0].value == ''){
                $(inputset[0]).css("box-shadow","rgb(0, 0, 0) 0 0px 5px 0");
                success=false;    
            }
            /*if(section[0]!= 'req'){
                for(var i=0;i<inputset.length;i++){
                    if(i==0 || i==2){
                        if(  inputset[i].value==''){
                            $(inputset[i]).css("box-shadow","rgb(0, 0, 0) 0 0px 5px 0");
                            success=false;       
                        }
                    }
                }
                
                for(var k=0;k<selectset.length;k++){
                    if(k==0 || k==1){
                        
                        if(selectset[k].value==''){
                            $(selectset[k]).css("box-shadow","rgb(0, 0, 0) 0 0px 5px 0");   
                            success=false;       
                        }
                    }
                }
            }*/
            if(!success){
                alert('Please fill all the values ');
                break;
            }
        }
        if(success){
            // showProcessing
            savefield(index);
            getProjectField();
        showProcessing();
        }
    }
    
    function savecomplete(){
        var index=saveindex;
        
        var index=index.substring(0,index.lastIndexOf('_'));
        var row='#row'+index+' input '+', #row'+index+' select';
        $('#sav'+index).removeClass("show");
        $('#sav'+index).addClass("hide");
        $('#edit'+index).addClass("show");
        $('#edit'+index).removeClass("hide");
        $(row).attr('disabled','true');
        getProjectField();
        showProcessing()
    }
    
    function ReflectReadOnly(current){
                  
         console.log(current);
         var index= current.accessKey;
         index = index.split('_');
         index ='req_'+index[1];
         var checkinput='#check'+index +' input';
         var checkdiv='#check'+index;
         if(current.value!=''){
             $(checkdiv).css('pointer-events','auto');
             
         }else{
             $(checkdiv).css('pointer-events','none');
             $(checkinput).prop('checked',false);
             $(checkdiv).css('background-image','url("")');
         }
     }
    
    function edit(index,projectinput,proindex,sfFieldVal){
        var pro='pro_'+index;
        var plus='#plus_'+index;
        $(plus).css('pointer-events','auto');
        document.getElementById('CommonSave').value+=proindex+',';
        var row='#row'+index+' input '+', #row'+index+' select';
        $(row).removeAttr('disabled');
        document.getElementById(projectinput).disabled=true;;
        $(row).css('background-color','white');
        $(row).css('border','1px solid #aee0f5');
        $(row).css('box-shadow','0px 0px 5px 0px rgba(126, 209, 243, 1)');
        $('#sav'+index).addClass("show");
        $('#sav'+index).removeClass("hide");
        $('#edit'+index).addClass("hide"); 
        // $(row).css('background-color','black');
        var checkinput='#check'+index+' input';
        var reqcheckinput='#reqcheck'+index+' input';
        var reqcheck='#reqcheck'+index
        var check='#check'+index
        var reportcheckinput='#checkReporting'+index+' input';
        var reportcheck='#checkReporting'+index
        console.log(sfFieldVal.length);
        if(sfFieldVal.length != 0){
            $(check).parent().css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/checkbox-blue-border.png")})');
            $(reqcheck).parent().css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/checkbox-blue-border.png")})');
        
            $(check).parent().css('border','1px solid rgb(107, 172, 199)');
            $(reqcheck).parent().css('border','1px solid rgb(107, 172, 199)');
        }
        $(reportcheck).parent().css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/checkbox-blue-border.png")})');
        $(reportcheck).parent().css('border','1px solid rgb(107, 172, 199)');
        
        if( $(checkinput).prop('checked')){
            $(check).css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/green-check.png")})');
        }else{
            $(check).css('background-image','url("")');
        }
        if( $(reqcheckinput).prop('checked')){
            $(reqcheck).css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/green-check.png")})');
        }else{
            $(reqcheck).css('background-image','url("")');
        }
        if( $(reportcheckinput).prop('checked')){
            $(reportcheck).css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/green-check.png")})');
        }else{
            $(reportcheck).css('background-image','url("")');
        }
        
        
        
    } 
    
    function del(del){
        removeFunction(del);
    } 
    function check(checkid){
        var checkinput='#check'+checkid +' input';
        var checkdiv='#check'+checkid;
        if( $(checkinput).prop('checked')){
            $(checkdiv).css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/green-check.png")})');
            $(checkinput).css('cursor','pointer');
            
        }else{
            $(checkdiv).css('background-image','url("")');
            
        }
        
    }
    function reqcheck(checkid){
        var checkinput='#reqcheck'+checkid +' input';
        var checkdiv='#reqcheck'+checkid;
        if( $(checkinput).prop('checked')){
            $(checkdiv).css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/green-check.png")})');
            $(checkinput).css('cursor','pointer');
            
        }else{
            $(checkdiv).css('background-image','url("")');
            
        }
        
    }
    function showproject( divid, row ,num){
        
        document.getElementById('propick_'+divid+row+num).style.display='block';
    }
    
    function selectedproject(project){
        refpro(project);
    }
    function addproject(val ,projectid,inputid,inputidhidden,proname){
        
        
        var data= document.getElementById(inputidhidden).value;
        if(data.includes(projectid)){
            data=data.replace(projectid,'');
            val.classList.remove('colorfill');
        }else{
            data=data+','+projectid;
            val.classList.add('colorfill');
            
        }
        if(data.includes(',,')){
            data= data.replace(',,',',');
        }
        if(data.slice(-1)==','){
            data=data.slice(0, -1);
        }
        
        if(data.slice(0,1)==','){
            data=data.slice(1);
        }
        
        document.getElementById(inputid).value=ProjectIdToName(data);
        document.getElementById(inputid).title=ProjectIdToName(data);
        document.getElementById(inputidhidden).value=data;
    }
    
    function showprojectlist(divid){
        divid='#'+divid+' div.projdivholder';
        $(divid).css('display','Block');
    }
    
    function hidebox(data){
        $(data).css('display','none');
    }
    function clearvalue(inputid){
        document.getElementById(inputid).value='';
        var rr=  document.getElementById(inputid).value;
    }
    function refreshclick(action){
        
        //$(action).css("background-image","url(/resource/namespace__SFDCJiraConnector/SFDCJiraConnector/images/Refresh.gif");
        $(action).css("background-image","url(/resource/GrzSf__SFDCJiraConnector/SFDCJiraConnector/images/Refresh.gif");
        
        refreshsettings();
    }
    
    function delProFieldMapping(Obj){
        document.getElementById('alertDelDiv').style.display='Block';
        var object = document.getElementById('objName');
        object.innerText = Obj;
        $("#casenumberboxDiv").css("filter","blur(5px)");
        $("#defaultDiv").css("filter","blur(5px)");
        $("#projectMainDiv").css("filter","blur(5px)");
        $("#FieldMapDiv").css("filter","blur(5px)");
        $("#saveDiv").css("filter","blur(5px)");
        $("#leftPanelDiv").css("filter","blur(5px)");  
        $("#objLableDiv").css("filter","blur(5px)");   
    }
    
    function getProjectLabel(selObj,id){
        var showObj = document.getElementById('proLabel');
        var e = document.getElementById(id);
		var strUser = e.options[e.selectedIndex].text;
        showObj.innerText = strUser;
    }
    
    function delMappingForObject(delVar){
        
        if(delVar == 'Yes'){
            document.getElementById('alertDelDiv').style.display='None';
            deleteMapping(document.getElementById('objName').innerText);
            
        }
        if(delVar == 'No'){
            document.getElementById('alertDelDiv').style.display='None';
        }
         $("#casenumberboxDiv").css("filter","none");
        $("#defaultDiv").css("filter","none");
        $("#projectMainDiv").css("filter","none");
        $("#FieldMapDiv").css("filter","none");
        $("#saveDiv").css("filter","none");
        $("#leftPanelDiv").css("filter","none");  
        $("#objLableDiv").css("filter","none");  
    }
   
    function showFieldMapping(objMapping,object){
        
        updateVar(objMapping);
    }
    function saveJiraFields(jirafield){
        jirafieldValue(jirafield);
        console.log('jirafield--->'+jirafield);
    }
    function updatecheckboxproperty(val){
        if(sfField != null && sfField != ''){
            $('#check'+abc+' input').css('pointer-events','auto');
            $('#check'+abc+' input').css('cursor','pointer');
            $('#check'+abc+' input').parent().css('background-image','url({!URLFOR($Resource.SFDCJiraConnector,"/SFDCJiraConnector/images/checkbox-blue-border.png")})');
            $('#check'+abc+' input').parent().css('border','1px solid rgb(107, 172, 199)');
        } 
    }
    
    function configure(section,jiraFieldApi,SelectedObject){
        DefaultSectionData(jiraFieldApi,SelectedObject);
    }
    function Afterconfigure(DivToShow){
        document.getElementById(DivToShow).style.display='Block';
    }
    }