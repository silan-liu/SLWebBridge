(function () {
 if (navigator.userAgent.match(/(iPad|iPhone|iPod).*?YY/g)) {
 /**
  *  YYApiCore
  */
 YYApiCore = {
 __GLOBAL_FUNC_INDEX__: 0,
 __RETURN_VALUE__: undefined,
 /**
  * Helper: opening an URL
  * @param url
  */
 _openURL: function(url){
 	alert("openurl");
 //create an iframe to send the request
 var i = document.createElement('iframe');
 i.style.display = 'none';
 i.src = url;
 document.body.appendChild(i);
 
 //read return value
 var returnValue = YYApiCore.__RETURN_VALUE__;
 YYApiCore.__RETURN_VALUE__ = undefined;
 
 //destory the iframe
 i.parentNode.removeChild(i);
 
 return returnValue;
 },
 
 invokeClientMethod: function(module, name, parameters, callback) {
 var url = 'yyapi://' + module + '/' + name + '?p=' + encodeURIComponent(JSON.stringify(parameters || {}));
 if (callback) {
 var name;
 if (typeof callback == "function") {
 name = YYApiCore.createGlobalFuncForCallback(callback);
 } else {
 name = callback;
 }
 
 url = url + '&cb=' + name;
 }
 console.log('[API]' + url);
 var r = YYApiCore._openURL(url);
 return r ? r.result : null;
 },
 
 createGlobalFuncForCallback: function(callback){
 if (callback) {
 var name = '__GLOBAL_CALLBACK__' + (YYApiCore.__GLOBAL_FUNC_INDEX__++);
 window[name] = function(){
 var args = arguments;
 var func = (typeof callback == "function") ? callback : window[callback];
 //we need to use setimeout here to avoid ui thread being frezzen
 setTimeout(function(){ func.apply(null, args); }, 0);
 };
 return name;
 }
 return null;
 },
 
 invokeWebMethod: function(callback, returnValue) {
 YYApiCore.invokeCallbackWithArgs(callback, [returnValue]);
 },
 
 invokeCallbackWithArgs: function(callback, args) {
 if (callback) {
 var func = null;
 var tmp;
 if (typeof callback == "function") {
 func = callback;
 }
 else if((tmp = window[callback]) && typeof tmp == 'function') {
 func = tmp;
 }
 if (func) {
 setTimeout(function(){ func.apply(null, args); }, 0);
 }
 }
 }
 };
 }
 }) ();
