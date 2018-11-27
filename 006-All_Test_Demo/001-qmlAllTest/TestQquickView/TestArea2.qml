import QtQuick 2.7
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.3
import QtQuick.Controls 1.3

Item {
    property alias isDateTime: id_dateTimerChecker.checked
    property alias vTimeFormat: timeFormat_12.checked
    property alias vDateFormat: yearMouthDay.checked
    property bool isStandby: false/*id_standbyChecker.checked*/
    //    property alias isAudioSel: audio_swither.checked
    property bool isAudioSel: false
    //    property alias isAudioOff: audio_off.checked
    property bool isAudioOff: false
    //    property alias vStage1Interval: id_spinStage1Interval.value
    property int vStage1Interval: 0
    //    property alias vStage1Brightness: spinbox_bright_stage1.value
    property int vStage1Brightness: 0
    //    property alias vStage2Interval: id_spinStage2Interval.value
    property int vStage2Interval: 0
    //    property alias vStage2Brightness: spinbox_bright_stage2.value
    property int vStage2Brightness: 0

    property int hasChoiceAudioSwitchFlag: 0
    property int hasChoiceTimeAreaFlag: 0
    property bool autoSelectFlag: autoSelect.checked
    Text {
        id: id_Timeanddate_text1
        x: 0
        y: 0
        width: 72
        height: 30
        text: qsTr("时间和日期")
        textFormat: Text.AutoText
    }

    Text {
        id: id_TimeFormat_text
        x: 47
        y: 36
        text: qsTr("时间格式")
    }

    Text {
        id: id_DateFormat_text
        x: 47
        y: 64
        text: qsTr("日期格式")
    }

    RadioButton {
        id: timeFormat_12
        enabled: !isDateTime
        ExclusiveGroup { id: timeFormatGroup }
        x: 170
        y: 36
        width: 89
        height: 16
        exclusiveGroup: timeFormatGroup
        text: qsTr("12上午下午")
    }

    RadioButton {
        id: timeFormat_24
        enabled: !isDateTime
        exclusiveGroup: timeFormatGroup
        checked: true
        x: 331
        y: 36
        width: 77
        height: 16
        text: qsTr("24小时")
    }

    RadioButton {
        id: yearMouthDay
        ExclusiveGroup { id: dateFormatGroup }
        enabled: !isDateTime
        checked: true
        x: 170
        y: 64
        width: 89
        height: 16
        exclusiveGroup: dateFormatGroup
        text: qsTr("yyyy:MM:dd")
    }

    RadioButton {
        id: mouthDayYear
        exclusiveGroup: dateFormatGroup
        enabled: !isDateTime
        x: 331
        y: 64
        text: qsTr("dd:MM:yyyy")
    }

    CheckBox {
        id: id_dateTimerChecker
        x: 0
        y: 98
        text: qsTr("隐藏时间和日期")
        onClicked: {
            console.log("before hasChoiceTimeAreaFlag is ", hasChoiceTimeAreaFlag);
            hasChoiceTimeAreaFlag = 1;
            console.log("after hasChoiceTimeAreaFlag is ", hasChoiceTimeAreaFlag);
        }
    }

    ApnInformation {
        id: apnInformation
        enabled: !id_ApnSwitch.checked
        x: 0
        y: 131
        width: 592
        height: 54
    }

    CheckBox {
        id: id_ApnSwitch
        checked: true
        x: 0
        y: 187
        text: qsTr("隐藏Apn")
    }

    Text {
        id: ipSettingTextId
        x: 0
        y: 216
        width: 41
        height: 12
        text: qsTr("Ip设定")
    }

    CheckBox {
        id: autoSelect
        checked: true
        x: 0
        y: 244
        ExclusiveGroup { id: selectGroup }
        exclusiveGroup: selectGroup
        text: qsTr("自动")
    }

    CheckBox {
        id: manualSelect
        exclusiveGroup: selectGroup
        x: 0
        y: 270
        text: qsTr("手动")
    }

    Text {
        id: ipAddressText
        enabled: !autoSelectFlag
        x: 0
        y: 309
        width: 50
        height: 16
        text: qsTr("IP地址:")
    }

    IpEditRect {
        id: ipTextEdit
        enabled: !autoSelectFlag
        x: 156
        y: 300
        edit1Text: MediaScreen.getIndexIpString(1)
        edit2Text: MediaScreen.getIndexIpString(2)
        edit3Text: MediaScreen.getIndexIpString(3)
        edit4Text: MediaScreen.getIndexIpString(4)
    }

    Text {
        id: maskNetTextId
        enabled: !autoSelectFlag
        x: 0
        y: 350
        width: 50
        height: 16
        text: qsTr("子网掩码:")
    }

    IpEditRect {
        id: netTextEdit
        enabled: !autoSelectFlag
        x: 156
        y: 341
        edit1Text: qsTr("255")
        edit2Text: qsTr("255")
        edit3Text: qsTr("0")
        edit4Text: qsTr("0")
    }

    Text {
        id: defaultRouteTextId
        enabled: !autoSelectFlag
        x: 0
        y: 391
        width: 50
        height: 16
        text: qsTr("默认网关:")
    }

    IpEditRect {
        id: routeTextEdit
        enabled: !autoSelectFlag
        x: 156
        y: 382
        edit1Text: qsTr("10")
        edit2Text: qsTr("200")
        edit3Text: qsTr("254")
        edit4Text: qsTr("0")
    }

    Text {
        id: dnsTextId
        enabled: !autoSelectFlag
        x: 0
        y: 437
        width: 50
        height: 16
        text: qsTr("首选DNS服务器:")
    }

    IpEditRect {
        id: dnsTextEdit
        enabled: !autoSelectFlag
        x: 156
        y: 428
        edit1Text: qsTr("10")
        edit2Text: qsTr("200")
        edit3Text: qsTr("0")
        edit4Text: qsTr("1")
    }

    Connections {
        target: Ctranslator
        onLanguageChanges: {
            translateText();
        }
    }

    function translateText()
    {
        id_Timeanddate_text1.text = qsTr("时间和日期")
        id_TimeFormat_text.text  =  qsTr("时间格式")
        timeFormat_12.text = qsTr("12上午下午  ")
        timeFormat_24.text = qsTr("24小时")
        id_DateFormat_text.text =  qsTr("日期格式")
        id_dateTimerChecker.text = qsTr("隐藏时间和日期")

        id_ApnSwitch.text = qsTr("隐藏Apn")
        ipSettingTextId.text = qsTr("Ip设定")
        autoSelect.text = qsTr("自动")
        manualSelect.text = qsTr("手动")
        ipAddressText.text = qsTr("IP地址:")
        maskNetTextId.text = qsTr("子网掩码:")
        defaultRouteTextId.text = qsTr("默认网关:")
        dnsTextId.text = qsTr("首选DNS服务器:")
        apnInformation.translateText();
    }

    function area2_parameter_timeDate()
    {
        if (!isDateTime)
        {
            ConfigureSerialer.updateDateTime(vTimeFormat ? "12" : "24",
                                                           vDateFormat? "yyyy.MM.dd":"dd.MM.yyyy");
        }
    }

    function area2_parameter_screenSaver()
    {
        if (isStandby)
        {
            ConfigureSerialer.updateStandby(vStage1Interval,vStage1Brightness,vStage2Interval,vStage2Brightness);
        }
    }

    function updateParameterSetting2()
    {
        area2_parameter_FlagSetting()
        area2_parameter_timeDate();
        apnInformation.getAPNInformation();
        getIpInformation();
    }

    function resDate()
    {
        var resDateString = "";
        if(!isDateTime)
        {
            resDateString = (vDateFormat ? "YYYY:MM:DD" : "DD:MM:YYYY");
        }
        return resDateString;
    }

    function resTime()
    {
        var resTimeString = "";
        if(!isDateTime)
        {
            resTimeString = (vTimeFormat ? "00:00" : "00:00");
        }
        return resTimeString;
    }

    function getIpInformation()
    {
        var pIpAddress = ipTextEdit.getAddress();
        var pSubnetMask = netTextEdit.getAddress();
        var pDefaultGateWay = routeTextEdit.getAddress();
        var pDnsService = dnsTextEdit.getAddress();
        ConfigureSerialer.setIpParameter(autoSelect.checked, pIpAddress, pSubnetMask, pDefaultGateWay, pDnsService)
    }

    function area2_parameter_FlagSetting()
    {
        ConfigureSerialer.setArea2ParameterAllFlag(!isDateTime, !id_ApnSwitch.checked, autoSelect.checked)
    }
}