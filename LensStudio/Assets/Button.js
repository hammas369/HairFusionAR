// -----JS CODE-----
//@input Component.ScriptComponent ButtonController;
//@input number index

script.createEvent("TapEvent").bind(function () {
    
    script.ButtonController.api.ButtonClicked(script.index)
   
})
