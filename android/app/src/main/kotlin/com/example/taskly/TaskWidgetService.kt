package com.example.taskly

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

class TaskWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TaskRemoteViewsFactory(this.applicationContext, intent)
    }
}

class TaskRemoteViewsFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {
    private var taskList = ArrayList<JSONObject>()
    private val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)

    override fun onCreate() {
        // No-op
    }

    override fun onDataSetChanged() {
        taskList.clear()
        val widgetData = HomeWidgetPlugin.getData(context)
        val jsonString = widgetData.getString("widget_tasks", "[]")
        
        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                taskList.add(jsonArray.getJSONObject(i))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        taskList.clear()
    }

    override fun getCount(): Int {
        return taskList.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        if (position >= taskList.size) return RemoteViews(context.packageName, R.layout.task_widget_item)

        val task = taskList[position]
        val title = task.optString("title", "Task")
        
        val views = RemoteViews(context.packageName, R.layout.task_widget_item)
        views.setTextViewText(R.id.widget_item_title, title)
        
        // Since the user asked for a circular checkbox, we just show the static icon for now.
        // If we wanted interactivity (checking/unchecking from widget), we'd need a fill-in intent.
        
        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return false
    }
}
