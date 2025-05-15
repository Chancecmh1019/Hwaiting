package com.hwaiting

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.annotation.DrawableRes
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import es.antonborri.home_widget.HomeWidgetPlugin

class ExamCountdownWidget : AppWidgetProvider() {
    companion object {
        private const val ACTION_UPDATE_WIDGET = "com.hwaiting.ACTION_UPDATE_WIDGET"
        private const val UPDATE_INTERVAL_MS = 1000L // 每秒更新一次
    }
    private val executor = Executors.newSingleThreadExecutor()
    private lateinit var channel: MethodChannel
    private lateinit var flutterEngine: FlutterEngine

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // 設置每秒更新的鬧鐘
        setupUpdateAlarm(context)
        // 初始化Flutter引擎
        flutterEngine = FlutterEngine(context)
        
        // 使用正確的Dart入口點
        val flutterLoader = FlutterInjector.instance().flutterLoader()
        val dartEntrypoint = DartExecutor.DartEntrypoint(
            flutterLoader.findAppBundlePath(),
            "main"
        )
        flutterEngine.dartExecutor.executeDartEntrypoint(dartEntrypoint)

        // 建立與Flutter的通訊管道
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.hwaiting/widget"
        )
        
        // 設置方法調用處理器
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    // 請求更新所有小工具
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val thisAppWidgetIds = appWidgetManager.getAppWidgetIds(
                        android.content.ComponentName(context, ExamCountdownWidget::class.java)
                    )
                    
                    // 更新所有小工具
                    thisAppWidgetIds.forEach { appWidgetId ->
                        updateAppWidget(context, appWidgetManager, appWidgetId)
                    }
                    
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 更新所有小工具實例
        appWidgetIds.forEach { appWidgetId ->
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_exam_countdown)

        try {
            // 從 home_widget 套件獲取數據
            val prefs = HomeWidgetPlugin.getData(context)
            val examYear = prefs.getString("exam_year", "未設定年份")
            val examDate = prefs.getString("exam_date", "未設定日期")
            val countdownDays = prefs.getString("countdown_days", "未知天數")
            
            // 更新 UI
            views.setTextViewText(R.id.widget_title, "國中會考倒數")
            views.setTextViewText(R.id.widget_exam_year, "${examYear}國中會考")
            views.setTextViewText(R.id.widget_exam_date, examDate)
            views.setTextViewText(R.id.widget_countdown, countdownDays)
            
            // 如果點擊小工具，打開應用
            val pendingIntent = createOpenAppIntent(context)
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)
            
            // 更新小工具
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            // 更新失敗，使用 MethodChannel 獲取數據
        channel.invokeMethod("getRemainingTime", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                    val remainingTime = result as? Map<*, *>
                    val days = remainingTime?.get("days") as? Int ?: 0
                    
                    // 從 Flutter 獲取會考年份和日期
                channel.invokeMethod("formatExamDateForWidget", null, object : MethodChannel.Result {
                    override fun success(dateResult: Any?) {
                            val examInfo = dateResult as? Map<*, *>
                            val examYear = examInfo?.get("year") as? String ?: "未知年份"
                            val examDate = examInfo?.get("date") as? String ?: "未知日期"
    
                            // 更新 UI
                            views.setTextViewText(R.id.widget_title, "國中會考倒數")
                            views.setTextViewText(R.id.widget_exam_year, "${examYear}國中會考")
                        views.setTextViewText(R.id.widget_exam_date, examDate)
                        views.setTextViewText(
                            R.id.widget_countdown,
                            "${days}天"
                        )
                            
                            // 設置點擊事件
                            val pendingIntent = createOpenAppIntent(context)
                            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)
                            
                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            views.setTextViewText(R.id.widget_title, "國中會考倒數")
                            views.setTextViewText(R.id.widget_exam_year, "載入失敗國中會考")
                        views.setTextViewText(R.id.widget_exam_date, "載入日期失敗")
                        views.setTextViewText(
                            R.id.widget_countdown,
                            "${days}天"
                        )
                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    }

                    override fun notImplemented() {
                            views.setTextViewText(R.id.widget_title, "國中會考倒數")
                            views.setTextViewText(R.id.widget_exam_year, "未實現國中會考")
                        views.setTextViewText(R.id.widget_exam_date, "功能未實現")
                        views.setTextViewText(
                            R.id.widget_countdown,
                            "${days}天"
                        )
                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    }
                })
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                views.setTextViewText(R.id.widget_countdown, "載入失敗: $errorMessage")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }

            override fun notImplemented() {
                views.setTextViewText(R.id.widget_countdown, "功能未實現")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        })
        }
    }
    
    // 建立打開 App 的 Intent
    private fun createOpenAppIntent(context: Context): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
        } else {
            PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
    }

    override fun onDisabled(context: Context) {
        // 最後一個小工具被移除時，停止Flutter引擎和取消鬧鐘
        if (::flutterEngine.isInitialized) {
        flutterEngine.destroy()
        }
        executor.shutdown()
        cancelUpdateAlarm(context)
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == ACTION_UPDATE_WIDGET) {
            // 收到更新廣播時，更新所有小工具
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, ExamCountdownWidget::class.java)
            )
            
            // 更新所有小工具
            appWidgetIds.forEach { appWidgetId ->
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
            
            // 重新設置鬧鐘以繼續更新
            setupUpdateAlarm(context)
        }
    }
    
    private fun setupUpdateAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ExamCountdownWidget::class.java).apply {
            action = ACTION_UPDATE_WIDGET
        }
        
        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
        } else {
            PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
        
        // 設置精確鬧鐘，每秒觸發一次
        val triggerTime = SystemClock.elapsedRealtime() + UPDATE_INTERVAL_MS
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME_WAKEUP, triggerTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.ELAPSED_REALTIME_WAKEUP, triggerTime, pendingIntent)
        }
    }
    
    private fun cancelUpdateAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ExamCountdownWidget::class.java).apply {
            action = ACTION_UPDATE_WIDGET
        }
        
        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
        } else {
            PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
        
        alarmManager.cancel(pendingIntent)
    }
}