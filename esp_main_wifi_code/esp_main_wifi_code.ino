// Firebase=================================================
// WiFi

// Firebase
#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
// Provide the token generation process info.
#include <addons/TokenHelper.h>
// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>
/* 1. Define the WiFi credentials */
#define WIFI_SSID "Neo_7"
#define WIFI_PASSWORD "12345678"
// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino
/* 2. Define the API Key */
#define API_KEY "AIzaSyDfgzl6ucMinUyZCJaj_fNYN-4A9CT5Zco"
/* 3. Define the RTDB URL */
#define DATABASE_URL "https://findpix-5c4a0-default-rtdb.asia-southeast1.firebasedatabase.app/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app
/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "device@gmail.com"
#define USER_PASSWORD "12345678"
// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
unsigned long sendDataPrevMillis = 0;
// Variable to save USER UID
String uid;
// Databse
String path;

//====time
#include "time.h"

const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = 19800;
const int   daylightOffset_sec = 3600;

//=============================================
#include <HardwareSerial.h>
#include <TinyGPS++.h>

#include <Adafruit_MPU6050.h>
#include <Wire.h>
Adafruit_MPU6050 mpu;
#define IMU_SDA      38
#define IMU_SCL      39

HardwareSerial neo(1); // Use UART 1 on ESP32
String lati = "";
String longi = "";
float speed_kmph = 0.0;
TinyGPSPlus gps;

#define pushButton 35
bool isSos = false;

HardwareSerial sim800(2);
String simRead;

//SPI DISPLAY
#include <TFT_eSPI.h> // Graphics and font library for ST7735 driver chip
#include <SPI.h>

TFT_eSPI tft = TFT_eSPI();  // Invoke library, pins defined in User_Setup.h

void setup()
{
  Serial.begin(115200);

  tft.init();
  tft.setRotation(4);
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_RED);
  tft.setCursor (0, 5);
  tft.setTextFont(2);
  tft.print("FINDPIX");//tft.print(i);

  sim800.begin(9600, SERIAL_8N1, 48, 16);

  neo.begin(9600, SERIAL_8N1, 34, 33);

  pinMode(pushButton, INPUT);

  Serial.println();
  delay(1000);
  Serial.println("Setupig MPU-6050 sensor");

  Wire.begin(IMU_SDA, IMU_SCL);

  // while (!Serial)
  //   delay(10);

  // Initialize MPU6050
  if (!mpu.begin())
  {
    Serial.println("Failed to find MPU6050 chip,Rotary module is okay, but program cannot be started");
    while (1)
      delay(10);
  }

  Serial.println("MPU6050 Found!");

  // Configure sensor settings
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_5_HZ);

  Serial.println("");
  delay(100);

  // WIFI
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  unsigned long ms = millis();
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  //Time
  // Init and get the time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  printLocalTime();

  // FIREBASE
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Limit the size of response payload to be collected in FirebaseData
  fbdo.setResponseSize(2048);

  Firebase.begin(&config, &auth);

  // Comment or pass false value when WiFi reconnection will control by your code or third party library
  Firebase.reconnectWiFi(true);

  Firebase.setDoubleDigits(5);

  config.timeout.serverResponse = 10 * 1000;

  // Getting the user UID might take a few seconds
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "")
  {
    Serial.print('.');
    delay(1000);
  }
  // Print user UID
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

  path = "devices/" + uid + "/reading";

  // SIM
  sim800.println("AT+CSQ");
  delay(100);
  simRead = sim800.read();

  test_sim800_module();
}

void updateData(bool isUpdate, float temp, bool isSos, float acl_x, float acl_y, float acl_z, float gyro_x, float gyro_y, float gyro_z)
{
  if (Firebase.ready() && (isUpdate || (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0)))
  {
    printLocalTime();
    sendDataPrevMillis = millis();
    FirebaseJson json;
    json.set("lat", lati);
    json.set("long", longi);
    json.set("speed", speed_kmph);
    json.set("temp", temp);
    json.set("sos", isSos);
    json.set("acl_x", acl_x);
    json.set("acl_y", acl_y);
    json.set("acl_z", acl_z);
    json.set("gyro_x", gyro_x);
    json.set("gyro_y", gyro_y);
    json.set("gyro_z", gyro_z);
    json.set("simRead", simRead);
    json.set(F("ts/.sv"), F("timestamp"));
    // Serial.printf("Set json... %s\n", Firebase.RTDB.set(&fbdo, path.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    Serial.printf("Set data with timestamp... %s\n", Firebase.setJSON(fbdo, path.c_str(), json) ? fbdo.to<FirebaseJson>().raw() : fbdo.errorReason().c_str());
    Serial.println("");
  }
}

void loop()
{

  // Values from MPU-6050
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

  Serial.println("");

  smartDelay(1000);

  Serial.println("GPS data received");
  Serial.println("Latitude: " + lati);
  Serial.println("Longitude: " + longi);
  Serial.print("Speed: ");
  Serial.print(speed_kmph);
  Serial.println(" km/h");

  delay(1000); // Wait for one second before the next iteration

  bool buttonState = digitalRead(pushButton);
  if (buttonState)
  {
    updateData(true, temp.temperature, true, accel.acceleration.x, accel.acceleration.y, accel.acceleration.z, gyro.gyro.x, gyro.gyro.y, gyro.gyro.z);
    isSos = !isSos;
    send_SMS();
    delay(100);
  }

  updateData(false, temp.temperature, buttonState, accel.acceleration.x, accel.acceleration.y, accel.acceleration.z, gyro.gyro.x, gyro.gyro.y, gyro.gyro.z);

  updateSerial();
}

static void smartDelay(unsigned long ms)
{
  unsigned long start = millis();
  do
  {
    while (neo.available())
    {
      char c = neo.read();
      gps.encode(c);
    }
  } while (millis() - start < ms);

  // Update latitude, longitude, and speed
  lati = String(gps.location.lat(), 8);
  longi = String(gps.location.lng(), 8);
  speed_kmph = gps.speed.kmph();
}

void updateSerial()
{
  delay(500);
  while (Serial.available())
  {
    sim800.write(Serial.read()); // Forward what Serial received to Software Serial Port
  }
  while (sim800.available())
  {
    Serial.write(sim800.read()); // Forward what Software Serial received to Serial Port
  }
}

void send_SMS()
{
  // sim800.println("AT+CMGF=1"); // Configuring TEXT mode
  // sim800.println("AT+CMGS=\"+919074421279\"");//change ZZ with country code and xxxxxxxxxxx with phone number to sms
  // sim800.print("SOS! Alert!"); //text content
  // sim800.write(26);

  test_sim800_module();

  sim800.println("ATD+919074421279;"); // Configuring TEXT mode
  simRead = sim800.read();
  updateSerial();
}

void test_sim800_module()
{
  sim800.println("AT");
  updateSerial();
  Serial.println();
  sim800.println("AT+CSQ");
  updateSerial();
  sim800.println("AT+CCID");
  updateSerial();
  sim800.println("AT+CREG?");
  updateSerial();
  sim800.println("ATI");
  updateSerial();
  sim800.println("AT+CBC");
  updateSerial();
}

void printLocalTime(){
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
  Serial.print("Day of week: ");
  Serial.println(&timeinfo, "%A");
  Serial.print("Month: ");
  Serial.println(&timeinfo, "%B");
  Serial.print("Day of Month: ");
  Serial.println(&timeinfo, "%d");
  Serial.print("Year: ");
  Serial.println(&timeinfo, "%Y");
  Serial.print("Hour: ");
  Serial.println(&timeinfo, "%H");
  Serial.print("Hour (12 hour format): ");
  Serial.println(&timeinfo, "%I");
  Serial.print("Minute: ");
  Serial.println(&timeinfo, "%M");
  Serial.print("Second: ");
  Serial.println(&timeinfo, "%S");

  Serial.println("Time variables");
  char timeHour[3];
  strftime(timeHour,3, "%H", &timeinfo);
  Serial.println(timeHour);
  char timeMinute[3];
  strftime(timeMinute,3, "%M", &timeinfo);
  Serial.println(timeMinute);
  char timeSecond[3];
  strftime(timeSecond,3, "%S", &timeinfo);
  Serial.println(timeSecond);
  char timeWeekDay[10];
  strftime(timeWeekDay,10, "%A", &timeinfo);
  Serial.println(timeWeekDay);
  Serial.println();

  tft.setRotation(3);
  tft.fillScreen(TFT_BLACK);
  tft.setCursor(0, 0);
  tft.setTextColor(TFT_WHITE); 
  tft.setTextSize(2);
  tft.println(F(""));
  tft.println(F("FINDPIX"));
  tft.print(timeHour);tft.print(":");tft.print(timeMinute);tft.print(":");tft.println(timeSecond);
}
