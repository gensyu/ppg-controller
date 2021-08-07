import QtQuick 2.1
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    width: 640
    height: 580
    visible: true
    title: qsTr("PPG Contoller")

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    function get_comport() {
        comboBox_comlist.model.clear()
        let device =  connect.comlist()
        for(var key in device){
            comboBox_comlist.model.append({text:device[key]});
        }
        // comboBox.currentIndex = 1;
    }


    function send_pulse_param() {
        connect.set_target(comboBox_comlist.currentText)
        let period = spinBox_period.value
        let ch1_delay = spinBox_ch1_delay.value
        let ch1_width = spinBox_ch1_width.value
        let ch2_delay = spinBox_ch2_delay.value
        let ch2_width = spinBox_ch2_width.value
        let ch3_delay = spinBox_ch3_delay.value
        let ch3_width = spinBox_ch3_width.value
        let ch4_delay = spinBox_ch4_delay.value
        let ch4_width = spinBox_ch4_width.value

        var ch_pram =  [
                ch1_width, ch1_delay,
                ch2_width, ch2_delay,
                ch3_width, ch3_delay,
                ch4_width, ch4_delay,
            ]
        connect.write_value(comboBox_comlist.currentText, period, ch_pram);
    }

    function get_fpga_param() {
        connect.set_target(comboBox_comlist.currentText)
        let data = connect.read_value(comboBox_comlist.currentText)
        let period = data[0]
        let ch_pram = data[1]
        spinBox_period.value = period
        spinBox_ch1_width.value = ch_pram[0]
        spinBox_ch1_delay.value = ch_pram[1]
        spinBox_ch2_width.value = ch_pram[2]
        spinBox_ch2_delay.value = ch_pram[3]
        spinBox_ch3_width.value = ch_pram[4]
        spinBox_ch3_delay.value = ch_pram[5]
        spinBox_ch4_width.value = ch_pram[6]
        spinBox_ch4_delay.value = ch_pram[7]
    }


    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Label {
                text: qsTr("接続先")
            }
            ComboBox {
                id: comboBox_comlist
                model: ListModel {
                   id: model
                }       
                onPressedChanged: {
                    if (pressed) { get_comport() }
                }
               
            }
            
            Button {
                id: button_check
                text: qsTr("読み出し")
                onClicked: get_fpga_param()
            }
            Button {
                id: button_write
                text: qsTr("書き込み")
                onClicked: send_pulse_param()
            }
        }
        GroupBox {
            id: groupBox
            Layout.fillHeight: true
            Layout.fillWidth: true
            font.pointSize: 13
            title: qsTr("パルス設定")
            ColumnLayout{

                RowLayout  {
                    Label {
                        id: label_period
                        text: qsTr("周期")
                        font.pointSize: 14
                    }
                    SpinBox {
                        id: spinBox_period

                    }
                }
                GroupBox {
                    id: groupBox_ch1
                    font.pointSize: 13
                    title: qsTr("CH1")

                    RowLayout  {
                        Label {
                            id: label_ch1_width

                            text: qsTr("Width")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch1_width
                        }
                        Label {
                            id: label_ch1_delay

                            text: qsTr("Delay")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch1_delay
                        }
                    }
                }
                GroupBox {
                    id: groupBox_ch2
                    font.pointSize: 13
                    title: qsTr("CH2")

                    RowLayout  {
                        Label {
                            id: label_ch2_width

                            text: qsTr("Width")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch2_width
                        }
                        Label {
                            id: label_ch2_delay

                            text: qsTr("Delay")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch2_delay
                        }
                    }
                }
                GroupBox {
                    id: groupBox_ch3
                    font.pointSize: 13
                    title: qsTr("CH3")

                    RowLayout  {
                        Label {
                            id: label_ch3_width

                            text: qsTr("Width")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch3_width
                        }
                        Label {
                            id: label_ch3_delay

                            text: qsTr("Delay")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch3_delay
                        }
                    }
                }
                GroupBox {
                    id: groupBox_ch4
                    font.pointSize: 13
                    title: qsTr("CH4")

                    RowLayout  {
                        Label {
                            id: label_ch4_width

                            text: qsTr("Width")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch4_width
                        }
                        Label {
                            id: label_ch4_delay

                            text: qsTr("Delay")
                            font.pointSize: 13
                        }
                        SpinBox {
                            id: spinBox_ch4_delay
                        }
                    }
                }
            }
        }

    }
}

