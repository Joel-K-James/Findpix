//Select your modem
//SSL/TLS is currently supported only with SIM8xx series
#define TINY_GSM_MODEM_SIM800
//Increase RX buffer
#define TINY_GSM_RX_BUFFER 256
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
#include <TinyGPS++.h> //https://github.com/mikalhart/TinyGPSPlus
#include <TinyGsmClient.h> //https://github.com/vshymanskyy/TinyGSM
#include <ArduinoHttpClient.h> //https://github.com/arduino-libraries/ArduinoHttpClient
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
#include <Adafruit_MPU6050.h>
#include <Wire.h>
Adafruit_MPU6050 mpu;
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
const char FIREBASE_HOST[]  = "findpix-5c4a0-default-rtdb.asia-southeast1.firebasedatabase.app";
const String FIREBASE_AUTH  = "Ez22201X7gNLJrb8eMqAnhYi51fSm14P2KfcgsY3";
const String FIREBASE_PATH  = "/";
const int SSL_PORT          = 443;
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
// Your 

// Leave empty, if missing user or pass
char apn[]  = "WWWW";
char user[] = "";
char pass[] = "";
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
//GSM Module RX pin to ESP32 0
//GSM Module TX pin to ESP32 1
#define rxPin 0
#define txPin 1
HardwareSerial sim800(1);
TinyGsm modem(sim800);
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
//GPS Module RX pin to ESP32 17
//GPS Module TX pin to ESP32 16
#define RXD2 3
#define TXD2 2
HardwareSerial neogps(2);
TinyGPSPlus gps;
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
TinyGsmClientSecure gsm_client_secure_modem(modem, 0);
HttpClient http_client = HttpClient(gsm_client_secure_modem, FIREBASE_HOST, SSL_PORT);
//NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

unsigned long previousMillis = 0;
long interval = 10000;

//**************************************************************************************************
void setup() {
  Serial.begin(115200);
  Serial.println("esp32 serial initialize");
  
  sim800.begin(115200, SERIAL_8N1, D0, D1);
  Serial.println("SIM800L serial initialize");

  neogps.begin(9600, SERIAL_8N1, 3, 2); 
  Serial.println("neogps serial initialize");
  delay(3000);
  
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN----------------------
  //Restart takes quite some time
  //To skip it, call init() instead of restart()
  Serial.println("Initializing modem...");
  // modem.restart();
  String modemInfo = modem.getModemInfo();
  Serial.print("Modem: ");
  Serial.println(modemInfo);
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  
  // Unlock your SIM card with a PIN
  //modem.simUnlock("1234");
  
  http_client.setHttpResponseTimeout(90 * 1000); //^0 secs timeout-------------

    // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip,Rotary module is okay, but program cannot be started");
    while (1) delay(10);
  }

  // Configure sensor settings
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_5_HZ);
}
//**************************************************************************************************


//**************************************************************************************************
void loop() {
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  //Restart takes quite some time
  //To skip it, call init() instead of restart()
  //Serial.println("Initializing modem...");
  //modem.init();
  //String modemInfo = modem.getModemInfo();
  //Serial.print("Modem: ");
  //Serial.println(modemInfo);
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  //Serial.print(F("Waiting for network..."));
  if (!modem.waitForNetwork()) {
    Serial.println(" fail");
    delay(1000);
    return;
  }
  Serial.println(" OK");
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

      // gps_loop();
      // mpuLoop();
    
  // //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN------------------------------------------------------------
  // Serial.print(F("Connecting to "));
  // Serial.print(apn);
  // if (!modem.gprsConnect(apn, user, pass)) {
  //   Serial.println(" fail");
  //   delay(1000);
  //   return;
  // }
  // Serial.println(" OK");
  // //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  
  // http_client.connect(FIREBASE_HOST, SSL_PORT);
  
  // //MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
  // while (true) {
  //   if (!http_client.connected()) {
  //     Serial.println();
  //     http_client.stop();// Shutdown
  //     Serial.println("HTTP  not connect");
  //     break;
  //   }
  //   else{
  //     gps_loop();
  //   }
  // }
  // //MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM--------------------------------------------------------
}
//**************************************************************************************************

//**************************************************************************************************
void PostToFirebase(const char* method, const String & path , const String & data, HttpClient* http) {
  String response;
  int statusCode = 0;
  http->connectionKeepAlive(); // Currently, this is needed for HTTPS
  
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  String url;
  if (path[0] != '/') {
    url = "/";
  }
  url += path + ".json";
  url += "?auth=" + FIREBASE_AUTH;
  Serial.print("POST:");
  Serial.println(url);
  Serial.print("Data:");
  Serial.println(data);
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  
  String contentType = "application/json";
  http->put(url, contentType, data);
  
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  // read the status code and body of the response
  //statusCode-200 (OK) | statusCode -3 (TimeOut)
  statusCode = http->responseStatusCode();
  Serial.print("Status code: ");
  Serial.println(statusCode);
  response = http->responseBody();
  Serial.print("Response: ");
  Serial.println(response);
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  if (!http->connected()) {
    Serial.println();
    http->stop();// Shutdown
    Serial.println("HTTP POST disconnected");
  }
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
}
//**************************************************************************************************


//**************************************************************************************************
void gps_loop()
{
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  //Can take up to 60 seconds
  boolean newData = false;
  for (unsigned long start = millis(); millis() - start < 2000;){
    while (neogps.available()){
      if (gps.encode(neogps.read())){
        newData = true;
        break;
      }
    }
  }
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
  //If newData is true
  if(true){
  newData = false;
  
  String latitude, longitude;
  unsigned long speed;
  //float altitude;
  //unsigned long date, time, speed, satellites;
  
  latitude = String(gps.location.lat(), 6); // Latitude in degrees (double)
  longitude = String(gps.location.lng(), 6); // Longitude in degrees (double)
  
  //altitude = gps.altitude.meters(); // Altitude in meters (double)
  //date = gps.date.value(); // Raw date in DDMMYY format (u32)
  //time = gps.time.value(); // Raw time in HHMMSSCC format (u32)
  speed = gps.speed.kmph();
  
  Serial.print("Speed= "); 
  Serial.print(speed);
  Serial.print("Latitude= "); 
  Serial.print(latitude);
  Serial.print(" Longitude= "); 
  Serial.println(longitude);
  
      
  String gpsData = "{";
  gpsData += "\"lat\":" + latitude + ",";
  gpsData += "\"lng\":" + longitude + "";
  // gpsData += "\"speed\":" + speed + "";
  gpsData += "}";

  //PUT   Write or replace data to a defined path, like messages/users/user1/<data>
  //PATCH   Update some of the keys for a defined path without replacing all of the data.
  //POST  Add to a list of data in our Firebase database. Every time we send a POST request, the Firebase client generates a unique key, like messages/users/<unique-id>/<data>
  //https://firebase.google.com/docs/database/rest/save-data
  
  PostToFirebase("PATCH", FIREBASE_PATH, gpsData, &http_client);//-----------------------------
  

  }
  //NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
}

void mpuLoop(){
  sensors_event_t accel, gyro, temp;
  mpu.getEvent(&accel, &gyro, &temp);


    // Print accelerometer data
  // Print accelerometer data
  Serial.print("Acceleration (X,Y,Z): ");
  Serial.print(accel.acceleration.x);
  Serial.print(", ");
  Serial.print(accel.acceleration.y);
  Serial.print(", ");
  Serial.print(accel.acceleration.z);
  Serial.println(" m/s^2");

  // Print gyroscope data
  Serial.print("Rotation (X,Y,Z): ");
  Serial.print(gyro.gyro.x);
  Serial.print(", ");
  Serial.print(gyro.gyro.y);
  Serial.print(", ");
  Serial.print(gyro.gyro.z);
  Serial.println(" rad/s");

  // Print temperature data
  Serial.print("Temperature: ");
  Serial.print(temp.temperature);
  Serial.println(" degC");
}

//**************************************************************************************************