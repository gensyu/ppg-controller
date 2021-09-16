# This Python file uses the following encoding: utf-8
import os
from pathlib import Path
import sys
from PySide6 import QtCore

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from serial.tools import list_ports
import serial
import construct as cs

import time

MOSI_FORMAT = cs.Struct (
    "cmd" /  cs.Flag,
    "addr" / cs.Int16ub,
    "data" / cs.Int16ub,
    "reseved" / cs.Const(b'\x00'),
)

MISO_FORMAT = cs.Struct(
    "status" / cs.Int8ub,
    "data" / cs.Int16ub,
    "reserved" / cs.Int24ub,
)

class Connection(QtCore.QObject):
    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self.ser = None


    @QtCore.Slot(result = 'QVariant')
    def comlist(self):
        self.ports = list_ports.comports()
        self.devices = [info.device for info in self.ports]
        return self.devices
    
    @QtCore.Slot(str)
    def connect_target(self, target):
        self.ser = serial.Serial(target, baudrate=19200)
        self.ser.flushInput()
        self.ser.flushOutput()
        self.ser.write(b"\x00\x00\x00\x00\x00\x00")
        time.sleep(200e-3)

    @QtCore.Slot()
    def disconnect_target(self):
        self.ser.close()

    @QtCore.Slot(str, int, "QVariantList")
    def write_value(self, target, period, ch_param):
        if target == "": return []
        self.ser.port = target

        senddata = [period] + ch_param
        print("-- READ VALUE --")
        for i, addr in enumerate(range(0x00, 0x12, 0x02)):
            data = {
                    "cmd": True,
                    "addr": addr,
                    "data": senddata[i]
                }
            s_frame = MOSI_FORMAT.build(
                data
            )
            self.ser.write(s_frame)
            print(f"PC -> FPGA:", " ".join([f"{i:02x}" for i in s_frame]))
            time.sleep(10e-3)
        print("-- END --")


    @QtCore.Slot(str, result = "QVariantList")
    def read_value(self, target):
        if target == "": return []
        period = 0
        ch_param = []

        print("-- READ VALUE --")
        for i, addr in enumerate(range(0x00, 0x12, 0x02)):
            data = {
                "cmd": False,
                "addr": addr,
                "data": 0
            }
            s_frame = MOSI_FORMAT.build(
                data
            )
            self.ser.write(s_frame)
            print(f"PC -> FPGA:", " ".join([f"{i:02x}" for i in s_frame]))
            r_frame = self.ser.read(6)
            print(f"FPGA -> PC:" , " ".join([f"{i:02x}" for i in r_frame]))
            recivedata = MISO_FORMAT.parse(r_frame)
            if i == 0:
                period = recivedata["data"]
            else:
                ch_param.append(recivedata["data"])
            time.sleep(10e-3)
        print("-- END --")

        return [period, ch_param]

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    connect = Connection()
    engine.rootContext().setContextProperty("connect", connect)
    engine.load(os.fspath(Path(__file__).resolve().parent / "main.qml"))
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
