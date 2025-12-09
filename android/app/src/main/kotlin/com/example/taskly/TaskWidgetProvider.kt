package com.example.taskly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class TaskWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.task_widget).apply {
                val listName = widgetData.getString("list_name", "My Tasks")
                
                setTextViewText(R.id.appwidget_title, listName)

                // Open App on List Title Click (Show Lists) - using HomeWidgetLaunchIntent
                val listPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("taskly://openlists")
                )
                setOnClickPendingIntent(R.id.widget_title_container, listPendingIntent)

                // Open App on Add Click (New Task) - using HomeWidgetLaunchIntent
                val addPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("taskly://opentask")
                )
                setOnClickPendingIntent(R.id.widget_add_button, addPendingIntent)
                
                // Configure ListView
                val serviceIntent = Intent(context, TaskWidgetService::class.java)
                serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
                
                setRemoteAdapter(R.id.widget_list_view, serviceIntent)
                setEmptyView(R.id.widget_list_view, R.id.widget_empty_view)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list_view)
        }
    }
}
