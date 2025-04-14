#include <ArduinoBLE.h>

BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLEBoolCharacteristic ledChar("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);

const int ledPin = 9;

void setup() {
  pinMode(ledPin, OUTPUT);
  analogWrite(ledPin, LOW);

  Serial.begin(9600);
  while (!Serial);

  if (!BLE.begin()) {
    Serial.println("BLE init failed!");
    while (1);
  }

  BLE.setLocalName("LED Controller");
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(ledChar);
  BLE.addService(ledService);

  ledChar.writeValue(false);

  BLE.advertise();
  Serial.println("BLE LED Controller ready");
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    Serial.print("Connected to: ");
    BLE.stopAdvertise();
    Serial.println(central.address());

    while (central.connected()) {
      if (ledChar.written()) {
        uint8_t brightness = 0;
        ledChar.readValue(&brightness, 1);
        Serial.print("Writing PWM to pin ");
        Serial.print(ledPin);
        Serial.print(": ");
        Serial.println(brightness);

        analogWrite(ledPin, brightness);

      }
    }

    Serial.println("Disconnected");
    BLE.advertise();
    Serial.println("Advertising restarted.");
  }
}
