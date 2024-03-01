#include <WiFiManager.h>  // https://github.com/tzapu/WiFiManager/       // Arduino IDE - board: ESP32S3 Dev Module
#include <TFT_eSPI.h>     // https://github.com/Bodmer/TFT_eSPI          // sketch for LILYGO T-QT-pro
#include <Preferences.h>  // https://github.com/vshymanskyy/Preferences  // to save the selected time zone
#include <esp_sntp.h>     // (core) needed for callback function "SNTP sync"

WiFiManager myWiFi;
TFT_eSPI tft = TFT_eSPI();
TFT_eSprite sprite = TFT_eSprite(&tft);
TFT_eSprite animat = TFT_eSprite(&tft);
Preferences prefs;

// char *location[] = { "Brussels", "Shanghai", "Auckland", "New York" };  // # of items must match # of time zones (line below)
// char *timeZone[] = { "CET-1CEST,M3.5.0,M10.5.0/3", "CST-8", "NZST-12NZDT,M9.5.0,M4.1.0/3", "EST5EDT,M3.2.0,M11.1.0" };
char *location[] = { "Mumbai" };
char *timeZone[] = { "IST-5:30" };

#define noconect "WiFi: no connection\nConnect to hotspot\n     T_QT_Pro\nand open a browser\n"

#define noconec2 "adress 192.168.4.1\nto enter network\nname and password."
#define connect1 "connecting"
#define connect2 "to WiFi"
#define timesync "Time sync"
#define PIN_LCD_BL 10  // display backlight pin
char *weekdays[] = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" };
byte count;
struct tm tInfo;  // https://cplusplus.com/reference/ctime/tm/
bool sync_OK = false;

void setup() {
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

void loop() {
  displayTime();
  if (!digitalRead(47)) switchTimeZone();
  if (!digitalRead(0)) deepSleep();
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


