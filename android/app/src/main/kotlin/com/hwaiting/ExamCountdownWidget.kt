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
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.exam_countdown_widget)

        try {
            // 從 home_widget 套件獲取數據
            val prefs = HomeWidgetPlugin.getData(context)
            val examYear = prefs.getString("exam_year", "未設定年份")
            val examDate = prefs.getString("exam_date_formatted", "未設定日期")
            val countdownDays = prefs.getString("countdown_days", "0")
            
            // 更新 UI
            views.setTextViewText(R.id.widget_main_title, "國中教育會考")
            views.setTextViewText(R.id.widget_exam_year, "${examYear}國中會考")
            views.setTextViewText(R.id.widget_exam_date, examDate)
            
            // 確保倒數天數顯示正確
            val days = countdownDays?.toIntOrNull() ?: 0
            if (days > 0) {
                views.setTextViewText(R.id.widget_countdown, days.toString())
            } else {
                views.setTextViewText(R.id.widget_countdown, "0")
            }
            
            // 如果點擊小工具，打開應用
            val pendingIntent = createOpenAppIntent(context)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            
            // 更新小工具
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            // 發生錯誤時顯示預設值
            views.setTextViewText(R.id.widget_main_title, "國中教育會考")
            views.setTextViewText(R.id.widget_exam_year, "未設定年份")
            views.setTextViewText(R.id.widget_exam_date, "未設定日期")
            views.setTextViewText(R.id.widget_countdown, "0")
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
    
    // 建立打開 App 的 Intent
    private fun createOpenAppIntent(context: Context): android.app.PendingIntent {
        val packageManager = context.packageManager
        val intent = packageManager.getLaunchIntentForPackage(context.packageName)
        return android.app.PendingIntent.getActivity(
            context,
            0,
            intent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )
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