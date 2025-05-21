# Hwaiting - 國中教育會考倒數計時器
Hwaiting（加油）是一款專為台灣國中學生設計的會考倒數計時應用程式，透過精確的倒數計時和桌面小工具功能，幫助學生更好地掌握備考時間，以積極正向的心態迎接國中教育會考。

## 功能特點

- **高精度倒數計時**：精確計算距離會考還有多少天、小時、分鐘、秒鐘
- **自訂會考年份**：支援自由選擇未來會考年份
- **桌面小工具**：無需開啟應用程式即可直接在手機桌面上顯示倒數時間
- **小工具自動更新**：每10秒自動更新一次，確保時間準確
- **應用與小工具同步**：在應用中修改年份後，小工具會立即更新
- **鼓勵提示**：根據剩餘時間提供不同的鼓勵話語
- **深色模式支援**：符合Android Material Design 3設計規範

## 🔧 技術架構

- **前端技術**：Flutter Framework
- **程式語言**：Dart & Kotlin
- **設計風格**：Material Design 3
- **小工具實現**：Home Widget 套件 + Android App Widget
- **資料儲存**：SharedPreferences
- **平台支援**：Android 5.0+

## ⚙️ 系統要求

- Android 5.0 (API Level 21) 或更高版本
- 至少 50MB 可用儲存空間
- 支援桌面小工具功能

## 📥 安裝方式

### 從原始碼構建
1. 確保已安裝 [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. 複製此專案
   ```bash
   git clone https://github.com/yourusername/hwaiting.git
   ```
3. 安裝依賴：
   ```bash
   flutter pub get
   ```
4. 運行應用：
   ```bash
   flutter run
   ```

### 關鍵技術點
- **時間計算**：使用 Dart 的 DateTime 處理複雜的日期差計算
- **小工具通訊**：透過 Home Widget 套件實現 Flutter 與原生小工具間的數據交換
- **定時更新**：使用定時器確保小工具數據定期更新
- **響應式UI**：採用 Flutter 的響應式設計保證不同螢幕尺寸的適配性

## 🤝 貢獻指南

我們歡迎任何形式的貢獻，無論是新功能、錯誤修復還是文檔改進：

1. Fork 此倉庫
2. 創建您的功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m '添加一些驚人的功能'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 開啟一個 Pull Request

## 📝 版本歷史

- **v2.0.0** (2024/03/xx)
  - 優化小工具顯示格式
  - 新增考試日期顯示
  - 改進倒數計時精確度
  - 修復小工具更新機制
  - 優化使用者介面

- **v1.0.0** (2024/01/xx)
  - 首次發布
  - 基本倒數計時功能
  - 桌面小工具支援

## 📄 授權協議

本專案採用 MIT 授權協議 - 詳見 [LICENSE](LICENSE) 文件
