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
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
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
#include <WiFiManager.h>  // https://github.com/tzapu/WiFiManager/       // Arduino IDE - board: ESP32S3 Dev Module
#include <TFT_eSPI.h>     // https://github.com/Bodmer/TFT_eSPI          // sketch for LILYGO T-QT-pro
#include <Preferences.h>  // https://github.com/vshymanskyy/Preferences  // to save the selected time zone
#include <esp_sntp.h>     // (core) needed for callback function "SNTP sync"

WiFiManager myWiFi;
TFT_eSPI tft = TFT_eSPI();
TFT_eSprite sprite = TFT_eSprite(&tft);
TFT_eSprite animat = TFT_eSprite(&tft);
Preferences prefs;
char *location[] = { "Mumbai" };
char *timeZone[] = { "IST-5:30" };

#define noconect "WiFi: no connection\nConnect to hotspot\n     T_QT_Pro\nand open a browser\n"

#define noconec2 "adress 192.168.4.1\nto enter network\nname and password."
#define connect1 "connecting"
#define connect2 "to WiFi"
#define timesync "Time sync"
#define PIN_LCD_BL 10  // display backlight pin
char *weekdays[] = { "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY" };
byte count;
struct tm tInfo;  // https://cplusplus.com/reference/ctime/tm/
bool sync_OK = false;
void setup()
{
  Serial.begin(115200);

  // tft.init();
  // tft.setRotation(4);
  // tft.fillScreen(TFT_BLACK);
  // tft.setTextColor(TFT_RED);
  // tft.setCursor (0, 5);
  // tft.setTextFont(2);
  // tft.print("FINDPIX");//tft.print(i);

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
  prefs.begin("my-clock", true);       // read from flash, true = read only
  count = prefs.getInt("counter", 0);  // retrieve the last set time zone - default to first in the array [0]
  prefs.end();
  count = count % (sizeof(timeZone) / sizeof(timeZone[0]));  // modulo (number of elements in string array) = prevent errors if number
  pinMode(47, INPUT_PULLUP);                                 // of time zones is less than the last saved time zone (code changed)
  gpio_hold_dis((gpio_num_t)PIN_LCD_BL);                     // disable backlight hold on
  pinMode(PIN_LCD_BL, OUTPUT);
  digitalWrite(PIN_LCD_BL, LOW);
  tft.init(), tft.setRotation(1);
  tft.fillScreen(TFT_BLACK);
  sprite.createSprite(128, 128);                  // sprite for faster rendering
  show_Logo_WiFi();                               // this is not really necessary but it's nicer.
  myWiFi.setAPCallback(showMessageNoConnection);  // function "showMessageNoConnection" is called when wifi was not found
  myWiFi.autoConnect("T_QT_Pro");
  showConnected();                                // when connection fails, the callback function skips this (& next 2) line
  sntp_set_time_sync_notification_cb(SNTP_Sync);  // callback for synchronization SNTP
  configTzTime(timeZone[count], "pool.ntp.org");  // set the time zone
}

void updateData(bool isUpdate, float temp, bool isSos, float acl_x, float acl_y, float acl_z, float gyro_x, float gyro_y, float gyro_z)
{
  if (Firebase.ready() && (isUpdate || (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0)))
  {
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
  displayTime();
  if (!digitalRead(47)) switchTimeZone();
  if (!digitalRead(0)) deepSleep();
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
void show_Logo_WiFi() {
  sprite.fillScreen(sprite.color565(100, 100, 100));
  for (int i = 0; i < 8192; i++) {  // create surface with fine texture
    byte j = random(100) + 50;
    sprite.drawPixel(random(128), random(128), sprite.color565(j, j, j));
  }
  sprite.setTextColor(TFT_WHITE);  // embossed text effect
  sprite.drawCentreString(connect1, 63, 75, 4), sprite.drawCentreString(connect2, 63, 99, 4);
  sprite.setTextColor(TFT_BLACK);
  sprite.drawCentreString(connect1, 65, 77, 4), sprite.drawCentreString(connect2, 65, 101, 4);
  sprite.setTextColor(sprite.color565(100, 100, 100));
  sprite.drawCentreString(connect1, 64, 76, 4), sprite.drawCentreString(connect2, 64, 100, 4);
  sprite.fillCircle(63, 48, 6, TFT_BLACK);
  sprite.fillCircle(65, 51, 6, TFT_WHITE);
  sprite.fillCircle(64, 50, 6, TFT_BLUE);  // engraved effect WiFi logo
  for (byte i = 0; i < 3; i++) {
    sprite.drawSmoothArc(62, 46, 40 - i * 11, 35 - i * 11, 128, 232, TFT_BLACK, TFT_BLACK, 1);
    sprite.drawSmoothArc(65, 49, 40 - i * 11, 35 - i * 11, 128, 232, TFT_WHITE, TFT_WHITE, 1);
    sprite.drawSmoothArc(64, 48, 40 - i * 11, 35 - i * 11, 128, 232, TFT_BLUE, TFT_BLUE, 1);
  }
  sprite.pushSprite(0, 0);
}

void showConnected() {
  for (byte i = 0; i < 3; i++) sprite.drawSmoothArc(64, 48, 40 - i * 11, 35 - i * 11, 128, 232, TFT_GREEN, TFT_GREEN, 1);
  sprite.fillCircle(64, 50, 6, TFT_GREEN);
  sprite.pushSprite(0, 0);
  animat.createSprite(128, 58);
  animat.fillSprite(sprite.color565(100, 100, 100));
  for (int i = 0; i < 3072; i++) {
    byte j = random(100) + 50;
    animat.drawPixel(random(128), random(58), sprite.color565(j, j, j));  // random greyscale
  }
  animat.setTextColor(TFT_GREEN);
  animat.drawCentreString("WiFi OK", 64, 5, 4);
  animat.setTextColor(TFT_YELLOW);
  animat.drawCentreString(timesync, 64, 30, 4);
  for (int i = 1024; i > 560; i--) animat.pushSprite(0, i / 8);  // high values to slow down the animation
  animat.deleteSprite();
}

void switchTimeZone() {
  for (int i = 0; i > -128; i--) sprite.pushSprite(0, i);  // short animation = UI debouncing
  count = (count + 1) % (sizeof(timeZone) / sizeof(timeZone[0]));  // increase counter modulo (number of elements in string array)
  configTzTime(timeZone[count], "pool.ntp.org");
  for (int i = 128; i > 1; i--) sprite.pushSprite(0, i);
}

void showMessageNoConnection(WiFiManager* myWiFi) {  // message on display when there is no WiFi connection
  sprite.fillScreen(TFT_NAVY);
  sprite.setTextColor(TFT_YELLOW);
  sprite.setTextFont(1), sprite.setCursor(0, 0, 2);
  sprite.print(noconect);
  sprite.print(noconec2);
  sprite.pushSprite(0, 0);
}

void displayTime() {
  getLocalTime(&tInfo);  // SNTP update every 3 hours (default ESP32) since we did not set an interval
  if (sync_OK) {         // only display the correct time = after SNTP sync
    sprite.setTextColor(TFT_CYAN, TFT_BLACK), sprite.fillSprite(TFT_BLACK);
    sprite.setFreeFont(&FreeSans18pt7b), sprite.setCursor(6, 28);
    sprite.printf("%02d:%02d", tInfo.tm_hour, tInfo.tm_min);
    sprite.setFreeFont(&FreeSans12pt7b);
    sprite.setCursor(sprite.getCursorX() + 4, 28);  // add 4 px distance between minutes & seconds
    sprite.printf("%02d", tInfo.tm_sec);
    sprite.setTextColor(TFT_YELLOW);
    sprite.drawCentreString(weekdays[tInfo.tm_wday], 64, 44, 1);                 // weekday
    sprite.drawRect(-1, 38, 130, 62, WiFi.isConnected() ? TFT_GREEN : TFT_RED);  // green lines if WiFi connection = OK
    sprite.setTextColor(TFT_CYAN), sprite.setCursor(6, 89);
    sprite.printf("%02d-%02d-%04d", tInfo.tm_mday, 1 + tInfo.tm_mon, 1900 + tInfo.tm_year);  // date
    sprite.setTextColor(TFT_RED), sprite.setFreeFont(&FreeSans9pt7b);
    sprite.drawCentreString(location[count], 64, 103, 1);
    sprite.pushSprite(0, 0);
  }
}

void deepSleep() {
  byte savedZone;
  prefs.begin("my-clock");                                 // read from flash
  savedZone = prefs.getInt("counter", 0);                  // retrieve the last set time zone - default to 0
  if (savedZone != count) prefs.putInt("counter", count);  // only write the time zone to flash when it was changed
  prefs.end();                                             // to prevent chip wear from excessive writing
  sprite.deleteSprite();
  sprite.createSprite(240, 38);
  tft.fillScreen(TFT_MAGENTA);  // background for sprite
  sprite.fillSprite(TFT_NAVY);
  sprite.setTextColor(TFT_YELLOW);
  sprite.setFreeFont(&Orbitron_Light_32);
  sprite.setCursor(1, 27);
  sprite.print("Deep Sleep");
  for (int i = 0; i > -200; i--) {  // short animation = UI debouncing
    sprite.pushSprite(i, 4);
    sprite.pushSprite(i, 86);
    sprite.pushSprite(-i, 45);
  }
  digitalWrite(PIN_LCD_BL, HIGH);        // backlight
  gpio_hold_en((gpio_num_t)PIN_LCD_BL);  // enable backlight hold on high level
  esp_wifi_stop();
  esp_sleep_enable_ext1_wakeup(GPIO_SEL_0, ESP_EXT1_WAKEUP_ALL_LOW);  // IO0 since IO47 cannot be set for awakening
  esp_deep_sleep_start();
}

void SNTP_Sync(struct timeval* tv) {  // callback time sync - we need sync_OK because in "deep sleep" mode,
  sync_OK = true;                     // the ESP32's internal clock does not run accurately.
}




