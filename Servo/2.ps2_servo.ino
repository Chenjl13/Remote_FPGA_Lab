#define PS2_X      15
#define PS2_Y      2
#define SW         4
#define SERVO1     13  // Y轴控制
#define SERVO2     12  // X轴控制
#define RESOLUTION 12
#define FREQ       50
#define CHANNEL1   0
#define CHANNEL2   1

// PWM宽度范围
int min_width = 0.6 / 20 * pow(2, RESOLUTION);  // 最小脉宽（0.6ms）
int max_width = 2.5 / 20 * pow(2, RESOLUTION);  // 最大脉宽（2.5ms）

// 灵敏度死区
int DEAD_ZONE = 100;

// 平滑参数
float alpha = 0.2;  // 越小越平滑

// 当前输出值（带平滑）
float smooth_x = 0;
float smooth_y = 0;

void setup() {
  pinMode(PS2_X, INPUT);
  pinMode(PS2_Y, INPUT);
  pinMode(SW, INPUT_PULLUP);

  Serial.begin(9600);

  ledcSetup(CHANNEL1, FREQ, RESOLUTION);
  ledcAttachPin(SERVO1, CHANNEL1);

  ledcSetup(CHANNEL2, FREQ, RESOLUTION);
  ledcAttachPin(SERVO2, CHANNEL2);
}

void loop() {
  int raw_x = analogRead(PS2_X);
  int raw_y = analogRead(PS2_Y);

  // 应用死区
  if (abs(raw_x - 2048) < DEAD_ZONE) raw_x = 2048;
  if (abs(raw_y - 2048) < DEAD_ZONE) raw_y = 2048;

  // 将摇杆值映射到 PWM 范围
  int target_x = map(raw_x, 0, 4095, min_width, max_width);
  int target_y = map(raw_y, 0, 4095, min_width, max_width);

  // 低通滤波平滑输出
  smooth_x = smooth_x * (1 - alpha) + target_x * alpha;
  smooth_y = smooth_y * (1 - alpha) + target_y * alpha;

  // 输出 PWM
  ledcWrite(CHANNEL1, (int)smooth_y);
  ledcWrite(CHANNEL2, (int)smooth_x);

  // 串口调试信息
  Serial.printf("Raw X: %d => %d | Raw Y: %d => %d | Button: %d\n",
                raw_x, (int)smooth_x, raw_y, (int)smooth_y, digitalRead(SW));

  delay(30);  // 控制刷新频率，防止舵机抖动
}
