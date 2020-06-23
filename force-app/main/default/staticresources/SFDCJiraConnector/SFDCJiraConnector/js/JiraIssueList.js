 function enableButtons(){
            $("[id$=unlink]").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
            $("[id$=delete]").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
            $("[id$=create_attachment_comment]").removeClass("btnDisabled").addClass("btn");
        }
        
        function disableButtons(){
            $("[id$=unlink]").attr("disabled", "disabled").removeClass("btn").addClass("btnDisabled");
            $("[id$=delete]").attr("disabled", "disabled").removeClass("btn").addClass("btnDisabled");
            $("[id$=create_attachment_comment]").attr("disabled", "disabled").removeClass("btn").addClass("btnDisabled");
        }
        
        function toggle(source) {
            var inputCheckBox = document.getElementsByTagName("input");                  
            for(var i=0; i<inputCheckBox.length; i++){       
                inputCheckBox[i].checked = source.checked;
            }
            if(source.checked){
                enableButtons();
             }else{
                 disableButtons();
             }
        }
        
        function enableDisable(source){
            var buttonCheck;
            
            if(source.checked==false)
            document.getElementById("one").checked = false;
            var inputCheckBox = document.getElementsByTagName("input");
            console.log(inputCheckBox);
            for(var i=0; i<inputCheckBox.length; i++){
                console.log(inputCheckBox[i].checked);
                if(inputCheckBox[i].id!='one' && inputCheckBox[i].checked==true){
                    buttonCheck = true;
                    //break;
                }
            }
            if(buttonCheck){
                enableButtons();
            }else{
                disableButtons();
            }
        }