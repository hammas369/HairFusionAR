// OptimizeController.js
// Version: 0.0.2
// Event: On Awake
// Description: Optimize the hair template on low end devices based on mlPerformanceIndex and FPS




//@input SceneObject HairComponents
//@ui {"widget":"separator"}
//@input string optimizationType = mlDeviceIndex {"widget": "combobox", "values": [{"value": "deviceIndex", "label": "ML Device index"}, {"value": "fpsThreshold", "label": "FPS Threshold"}, {"value": "combined", "label": "Combined"}]}
//@ui {"widget":"separator"}
//@input int optimizationThreshold = 5 {"widget":"slider","min":"0","max":"5","label":"ml Index Threshold"}
//@ui {"widget":"separator"}
//@input int fpsThreshold = 10  {"label": "FPS Threshold", "widget":"slider","min":"0","max":"30"}
//@ui {"widget":"separator"}
//@ui {"widget":"label","label":"set OptimizeML as true will disable MLcomponent with fallback mode"}
//@input bool optimizeML {"label": "Disable ML on Fallback"}
//@input SceneObject MLComponent {"label": "ML Component"}
//@ui {"widget":"separator"}
//@input bool printInfo {"label":"Print Optimization Info"}


var hairVisuals = [];
getActiveHairVisuals(script.HairComponents, hairVisuals);


var doOptimize = false;

var fallbackModeOn = false;
var hardwareSupported = true;
var fpsFallbackCheck = createFpsFallbackCheck(script.fpsThreshold, lowFPSCheckFallback);

var Initialized = false;

script.MLComponent.enabled = script.optimizeML ? !doOptimize : true;

initialize();

function initialize() {
    for (var i = 0; i < hairVisuals.length; i++) {
        hairVisuals[i].fallbackModeEnabled = doOptimize;
        if (!hairVisuals[i].isHardwareSupported) {
            print("Hardware Unspported");
            hardwareSupported = false;
        }
    }
    
    if (script.optimizationType != "fpsThreshold") {
        setHairFallback(global.deviceInfoSystem.performanceIndexes.ml < script.optimizationThreshold);
        if(script.printInfo) {
            print("Set hair fallback based on `performanceIndex.ml`: " + global.deviceInfoSystem.performanceIndexes.ml);
        }
    }
    
    Initialized = true;
}


function onUpdate() {
    if (!hardwareSupported || !Initialized) {
        return;
    }

    //set to fallback mode if fps is lower than threshold after some number of frames
    fpsFallbackCheck();
    
}
script.createEvent("UpdateEvent").bind(onUpdate);



function createFpsFallbackCheck(threshold, lowFPSCallback) {
    var framesToSkip = 70;
    var skippedFrame = 0;
    var frameCount = 0;
    var deltaTime = 0;
    var fps = 0;
    return function() {
        //skip some number of frames to let FPS stabilize
        if (skippedFrame < framesToSkip) {
            skippedFrame ++;
        } else {
            frameCount++;
            deltaTime += getDeltaTime();
            if (deltaTime > 1.0) {
                fps = frameCount / deltaTime ;
                frameCount = 0;
                deltaTime -= 1.0;
            }
            if (fps < threshold && fps > 0) {
                lowFPSCallback();
            }
        }
    };
}


function lowFPSCheckFallback() {
    if (!fallbackModeOn) {
        setHairFallback(true);
    }
}


function setHairFallback(isFallback) {
    if(script.printInfo) {
        print("Set fallback to " + isFallback);
    }
    
    for (var i = 0; i < hairVisuals.length; i++) {
        hairVisuals[i].fallbackModeEnabled = isFallback;
    }
    if (script.optimizeML) {
        script.MLComponent.enabled = !isFallback;
    }
    fallbackModeOn = isFallback;
    // 0.0.2: catch error if blur script isn't enabled yet
    if (global.switchBlur) {
        global.switchBlur(isFallback);
    } else {
        print("ERROR: No 'Switch Blur' global variable. Please make sure Hair Blur Settings (Hair Blur Controller) is enabled.");
    }
    
}


function getActiveHairVisuals(sceneObject, hairVisualsOut) {
    if (sceneObject.enabled) {
        var currentHairVisuals = sceneObject.getComponents("Component.HairVisual");
        for (var i = 0; i < currentHairVisuals.length; i++) {
            if (currentHairVisuals[i].enabled) {
                hairVisualsOut.push(currentHairVisuals[i]);
            }
        }
        for (var j = 0; j < sceneObject.getChildrenCount(); j++) {
            getActiveHairVisuals(sceneObject.getChild(j), hairVisualsOut);
            
        }
    }
}
