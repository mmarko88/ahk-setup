#NoEnv
#Include ActiveScript.ahk
#Include JsRT.ahk

; Unlike TrayTip, this API does not require a tray icon:
; #NoTrayIcon

; Toast notifications from desktop apps can only use local image files.
if !FileExist("sample.png")
    URLDownloadToFile https://autohotkey.com/boards/styles/simplicity/theme/images/announce_unread.png
        , % A_ScriptDir "\sample.png"
; The templates are described here:
;  http://msdn.com/library/windows/apps/windows.ui.notifications.toasttemplatetype.aspx
; toast_template := "toastImageAndText02"
toast_template =
(
    <toast>
      <visual>
        <binding template="ToastGeneric">
          <text></text>
          <text></text>
          <image />
        </binding>
      </visual>
      <actions>
        <input id="time" type="selection" defaultInput="2" >
          <selection id="1" content="Breakfast" />
          <selection id="2" content="Lunch" />
          <selection id="3" content="Dinner" />
        </input>
        <action content="Reserve" arguments="reserve" />
        <action content="Call Restaurant" arguments="call" />
      </actions>
    </toast>
)

; Image path/URL must be absolute, not relative.
toast_image := A_ScriptDir . "\sample.png"
; Text is an array because some templates have multiple text elements.
toast_text := ["Hello, world!", "This is the sub-text."]

; Only the Edge version of JsRT supports WinRT.
js := new JsRT.Edge
js.AddObject("MsgBox", Func("test"))

; Enable use of WinRT.  "Windows.UI" or "Windows" would also work.
js.ProjectWinRTNamespace("Windows.UI.Notifications")

code =
(
    function toast(template, image, text, duration, silent, app) {
        // Alias for convenience.
        var N = Windows.UI.Notifications;
        // Get the template XML as an XmlDocument.
	   // MsgBox(template);
        // var toastXml = N.ToastNotificationManager.getTemplateContent(N.ToastTemplateType[template]);
	   var toastXml = new Windows.Data.Xml.Dom.XmlDocument();
	   toastXml.loadXml(template);
	   // MsgBox(toastXml.getXml());
	   var toastNode = toastXml.selectSingleNode('/toast');
	   // Set our duration
	   if (duration == 'long')
		toastNode.setAttribute('duration', duration);
	   if (silent == 'true') {
	     var audio = toastXml.createElement('audio');
	     audio.setAttribute('silent', silent);
		toastNode.appendChild(audio);
	   }
	   var args = {'prop1':'val1', 'prop2':'val2'};
	   toastNode.setAttribute('launch', '{"test1":"1234"}');
        // Insert our content.
        var i = 0;
        for (let el of toastXml.getElementsByTagName("text")) {
            if (typeof text == 'string') {
                el.innerText = text;
                break;
            }
            el.innerText = text[++i];
        }
	   if (image) {
		toastXml.getElementsByTagName("image")[0].setAttribute("src", image);
		toastXml.getElementsByTagName("image")[0].setAttribute("placement", 'appLogoOverride');
	   }
	   // var actions = toastXml.createElement('actions');
	   // var input = toastXml.createElement('input');;
	   // input.setAttribute('id', 'time');
	   // input.setAttribute('type', 'selection');
	   // var selection1 = toastXml.createElement('selection');
	   // selection1.setAttribute('id', 'sel1');
	   // selection1.setAttribute('content', 'Breakfast');
	   // selection1.setAttribute('arguments3', 'Breakfast_args3');
	   // var selection2 = toastXml.createElement('selection');
	   // selection2.setAttribute('id', 'sel2');
	   // selection2.setAttribute('content', 'Lunch');
	   // input.appendChild(selection1);
	   // input.appendChild(selection2);
	   // var action1 = toastXml.createElement('action');
	   // action1.setAttribute('activationType', 'foreground');
	   // action1.setAttribute('id', 'action1_ID');
	   // action1.setAttribute('content', 'Action 1');
	   // action1.setAttribute('arguments', 'test arguments1');
	   // actions.appendChild(action1);
	   // var action2 = toastXml.createElement('action');
	   // action2.setAttribute('activationType', 'foreground');
	   // action2.setAttribute('id', 'action2_ID');
	   // action2.setAttribute('content', 'Action 2');
	   // action2.setAttribute('arguments', 'test arguments2');
	   // actions.appendChild(input);
	   // actions.appendChild(action1);
	   // actions.appendChild(action2);
	   // toastNode.appendChild(actions);
        // Show the notification.
        var toastNotifier = N.ToastNotificationManager.createToastNotifier(app || "AutoHotkey");
	   var toastNotification = new N.ToastNotification(toastXml);
	   // MsgBox(toastNotification.content.getXml());
	   toastNotification.onactivated = toastActivated;
	   toastNotification.ondismissed = toastDismissed;
        toastNotifier.show(toastNotification);
    }
    
    function toastActivated(a) {
	MsgBox(print_r(a));
	if (a.type == 'activated') {
		MsgBox(a.arguments);
	}
    }
    
    function toastDismissed(a) {
	if (a.reason === 0)
		MsgBox(print_r(a));
    }
    
/**
 * PHP-like print_r() & var_dump() equivalent for JavaScript Object
 *
 * @author Faisalman <movedpixel@gmail.com>
 * @license http://www.opensource.org/licenses/mit-license.php
 * @link http://gist.github.com/879208
 */
var print_r = function(obj,t){

    // define tab spacing
    var tab = t || '';
	
    // check if it's array
    var isArr = Object.prototype.toString.call(obj) === '[object Array]' ? true : false;
	
    // use {} for object, [] for array
    var str = isArr ? ('Array\n' + tab + '[\n') : ('Object\n' + tab + '{\n');

    // walk through it's properties
    for(var prop in obj){
        // if (obj.hasOwnProperty(prop)) {
            var val1 = obj[prop];
            var val2 = '';
            var type = Object.prototype.toString.call(val1);
            switch(type){
			
                // recursive if object/array
			 case '[object String]':
                    val2 = '\'' + val1 + '\'';
                    break;
                case '[object Array]':
                case '[object Object]':
                    val2 = print_r(val1, (tab + '\t'));
                    break;
			case '[object Windows.UI.Notifications.ToastNotification]':
                    val2 = print_r(val1, (tab + '\t'));
                    break;
			case '[object Windows.UI.Notifications.ToastActivatedEventArgs]':
                    val2 = print_r(val1, (tab + '\t'));
                    break;
                default:
                    val2 = val1;
            }
            str += tab + '\t' + prop + ' => ' + val2 + ',\n';
        // }
    }
	
    // remove extra comma for last property
    str = str.substring(0, str.length-2) + '\n' + tab;
	
    return isArr ? (str + ']') : (str + '}');
};
)

; Define the toast function.
js.Exec(code)
Return

#q::
js.toast(toast_template, toast_Image, toast_Text, "", "")
Return

test(a) {
	msgbox, %a%
}

test(test)
; Note: If the notification wasn't hidden, it will remain after we exit.
ExitApp