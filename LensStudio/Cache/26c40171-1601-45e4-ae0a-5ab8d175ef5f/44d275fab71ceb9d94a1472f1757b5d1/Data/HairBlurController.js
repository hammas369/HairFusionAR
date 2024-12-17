// HairBlurController.js
// Version: 0.0.2
// Event: On Awake
// Description: Enables a post effect camera to blur out the hair element
//@input float smoothness {"widget": "slider", "min": 0.0, "max": 1.0,"step":0.01}
//@input Asset.Material hairBlurHQ
//@input Asset.Material hairBlurLQ

//@ui {"widget":"separator"}
//@input bool advanced
//@input SceneObject hairComponents{"showIf":"advanced","showIfValue":"true"}
//@input Component.Camera camera{"showIf":"advanced","showIfValue":"true"}
//@input Asset.Texture finalRenderTarget{"showIf":"advanced","showIfValue":"true"}
//@input Asset.Texture tangentRenderTarget{"showIf":"advanced","showIfValue":"true"}
//@input bool printInfo {"showIf":"advanced","showIfValue":"true","label":"Print Hair Info"}

//HINT: If any object is under the blurred camera (aka Hair Camera in scene)
//they should have a second render target in order not to be blured.
//Please check out the shader node in materials labeled MaterialName_MRT
//to see how it works!

var blurEffect = null;

initialize();

// Low quality blur material used if optimization enable fallback mode. 
// Take a look OptimizationController script for details.
global.switchBlur = function(isLowQuality) {
    if (blurEffect == null) {
        return;
    }
    if (isLowQuality) {
        blurEffect.mainMaterial = script.hairBlurLQ;
        script.hairBlurLQ.mainPass["blurTerm"] = script.smoothness * 10.0;
    } else {
        blurEffect.mainMaterial = script.hairBlurHQ;
        script.hairBlurHQ.mainPass["blurTerm"] = script.smoothness * 10.0;
    }
};

function checkOrAddColorRenderTarget(colorRenderTargetsArray, colorAttachmentIndex) {
    if (colorAttachmentIndex >= colorRenderTargetsArray.length) {
        for (var i = colorRenderTargetsArray.length; i <= colorAttachmentIndex; i++) {
            colorRenderTargetsArray.push(Camera.createColorRenderTarget());
        }
    }
}

function shiftCameraOrders(sceneObject, order) {
    var cameras = sceneObject.getComponents("Component.Camera");
    for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].renderOrder >= order) {
            cameras[i].renderOrder += 1;
            if (script.printInfo) {
                print("Shifted order camera: " + cameras[i].getSceneObject().name + " : " + cameras[i].renderOrder);
            }
        }
    }

    var childrenCount = sceneObject.getChildrenCount();
    for (var j = 0; j < childrenCount; j++) {
        shiftCameraOrders(sceneObject.getChild(j), order);
    }
}

function updateCameraOrders(order) {
    var rootObjectCount = scene.getRootObjectsCount();
    for (var i = 0; i < rootObjectCount; i++) {
        shiftCameraOrders(scene.getRootObject(i), order);
    }
}

function initialize() {
    if (script.hairComponents &&
        script.camera &&
        script.finalRenderTarget &&
        script.tangentRenderTarget &&
        script.hairBlurHQ &&
        script.hairBlurLQ) {
        
        var colorRenderTargets = script.camera.colorRenderTargets;
    
        var supportedRenderTargets = Camera.getSupportedColorRenderTargetCount();
        if (supportedRenderTargets > 1) {
            checkOrAddColorRenderTarget(colorRenderTargets, 1);
            colorRenderTargets[1].clearColorOption = ClearColorOption.CustomColor;
            colorRenderTargets[1].clearColor = new vec4(0.5, 0.5, 1.0, 0.0);
            colorRenderTargets[1].targetTexture = script.tangentRenderTarget;
    
            var blurCameraRenderOrder = script.camera.renderOrder + 1;
            updateCameraOrders(blurCameraRenderOrder);
    
            var blurLayerId = 31;
            var blurLayer = LayerSet.fromNumber(blurLayerId);
    
            var blurObject = scene.createSceneObject("HairBlurEffect");
            blurObject.setRenderLayer(blurLayerId);
    
            var blurCamera = blurObject.createComponent("Component.Camera");
            blurCamera.colorRenderTargets[0].clearColorOption = ClearColorOption.None;
            blurCamera.colorRenderTargets[0].targetTexture = script.finalRenderTarget;
            blurCamera.renderLayer = blurLayer;
            blurCamera.renderOrder = blurCameraRenderOrder;
    
            blurEffect = blurObject.createComponent("Component.PostEffectVisual");
            blurEffect.addMaterial(script.hairBlurHQ);
            
            script.hairBlurHQ.mainPass["blurTerm"] = script.smoothness * 10.0;
        } else {
            if(script.printInfo) {
                print("Hair smoothing skipped");
            }
        }
    
        script.camera.colorRenderTargets = colorRenderTargets;
    }
}
