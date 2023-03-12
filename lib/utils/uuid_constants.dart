import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

final Uuid cpuModuleServiceUuid =
    Uuid.parse('388a4ae7-f276-4321-b227-6cd344f0bb7d');
final Uuid modbusDevicesServiceUuid =
    Uuid.parse('2b70fc16-9e65-4d84-88b7-f501ce4ec23f');
final Uuid modbusDeviceInfoServiceUuid =
    Uuid.parse('42024ac7-84a7-4635-a57c-63a759cda43b');
final Uuid deviceInformationServiceUuid = Uuid.parse('180a');

final Uuid cpuStatusCharacteristicUuid =
    Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a00');
final Uuid rtcCharacteristicUuid =
    Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a02');
final Uuid runModeCharacteristicUuid =
    Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a03');
final Uuid commandCharacteristicUuid =
    Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a06');
final Uuid timersCharacteristicUuid =
    Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a07');
final Uuid chStatusCharacteristicUuid =
    Uuid.parse('1deb9dd3-1648-485e-be9b-ad06bc341040');
final Uuid chValuesCharacteristicUuid =
    Uuid.parse('1deb9dd3-1648-485e-be9b-ad06bc341041');
final Uuid ozValuesCharacteristicUuid =
    Uuid.parse('1deb9dd3-1648-485e-be9b-ad06bc341043');
final Uuid prValuesCharacteristicUuid =
    Uuid.parse('1deb9dd3-1648-485e-be9b-ad06bc341045');
final Uuid cpuDeviceInfoCharacteristicUuid =
    Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a04');
final Uuid uiDeviceInfoCharacteristicUuid =
    Uuid.parse('762808a9-2cb3-4c0e-be22-8fe3e34134a0');
final Uuid chDeviceInfoCharacteristicUuid =
    Uuid.parse('762808a9-2cb3-4c0e-be22-8fe3e34134a1');
final Uuid ozDeviceInfoCharacteristicUuid =
    Uuid.parse('762808a9-2cb3-4c0e-be22-8fe3e34134a2');
final Uuid prDeviceInfoCharacteristicUuid =
    Uuid.parse('762808a9-2cb3-4c0e-be22-8fe3e34134a3');
final Uuid manufacturerNameCharacteristicUuid = Uuid.parse('2a29');
final Uuid modelNumberCharacteristicUuid = Uuid.parse('2a24');
final Uuid serielNumberCharacteristicUuid = Uuid.parse('2a25');
final Uuid hardwareRevisionCharacteristicUuid = Uuid.parse('2a27');
final Uuid firmwareRevisionCharacteristicUuid = Uuid.parse('2a26');
